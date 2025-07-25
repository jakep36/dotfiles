#!/usr/bin/env zsh
# AWS Utility Functions for zsh
# =============================

# Colors for better readability
export AWS_COLOR_RED='\033[0;31m'
export AWS_COLOR_GREEN='\033[0;32m'
export AWS_COLOR_YELLOW='\033[0;33m'
export AWS_COLOR_BLUE='\033[0;34m'
export AWS_COLOR_GRAY='\033[0;90m'
export AWS_COLOR_NC='\033[0m' # No Color

# Check if required tools are installed
aws_check_prereqs() {
  local tools=("aws" "jq")
  local missing=()

  for tool in "${tools[@]}"; do
    if ! command -v $tool &>/dev/null; then
      missing+=($tool)
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "${AWS_COLOR_RED}Missing required tools: ${missing[*]}${AWS_COLOR_NC}"
    return 1
  fi
  
  echo -e "${AWS_COLOR_GREEN}All prerequisites are installed.${AWS_COLOR_NC}"
  return 0
}

# Find EC2 instance by name pattern
aws_find_instance() {
  local name_pattern="${1:-*}"
  local state="${2:-running}"

  echo -e "${AWS_COLOR_GRAY}Finding EC2 instance with pattern: $name_pattern...${AWS_COLOR_NC}" >&2

  local instance=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$name_pattern" "Name=instance-state-name,Values=$state" \
    --query "Reservations[].Instances[0].InstanceId" \
    --output text)

  if [[ -z "$instance" ]]; then
    echo -e "${AWS_COLOR_YELLOW}No matching instance found.${AWS_COLOR_NC}" >&2
    return 1
  fi

  echo -e "${AWS_COLOR_GREEN}Found instance: $instance${AWS_COLOR_NC}" >&2
  echo "$instance"
}

# Find ECS cluster by name pattern
aws_find_cluster() {
  local name_pattern="${1:-*}"

  echo -e "${AWS_COLOR_GRAY}Finding ECS cluster with pattern: $name_pattern...${AWS_COLOR_NC}" >&2

  local clusters=$(aws ecs list-clusters --query "clusterArns[?contains(@, '$name_pattern')]" --output text)

  if [[ -z "$clusters" ]]; then
    echo -e "${AWS_COLOR_YELLOW}No matching cluster found. Getting all clusters...${AWS_COLOR_NC}" >&2
    clusters=$(aws ecs list-clusters --query "clusterArns" --output text)
  fi

  if [[ -z "$clusters" ]]; then
    echo -e "${AWS_COLOR_RED}No ECS clusters found.${AWS_COLOR_NC}" >&2
    return 1
  fi

  local cluster=$(echo $clusters | tr " " "\n" | head -n 1)
  echo -e "${AWS_COLOR_GREEN}Using cluster: $cluster${AWS_COLOR_NC}" >&2
  echo "$cluster"
}

# Find ECS service by pattern in a cluster
aws_find_service() {
  local cluster="$1"
  local name_pattern="${2:-*}"

  if [[ -z "$cluster" ]]; then
    echo -e "${AWS_COLOR_RED}Cluster ARN is required.${AWS_COLOR_NC}" >&2
    return 1
  fi

  echo -e "${AWS_COLOR_GRAY}Finding service with pattern: $name_pattern in cluster: $cluster...${AWS_COLOR_NC}" >&2

  local services=$(aws ecs list-services --cluster $cluster --query "serviceArns[?contains(@, '$name_pattern')]" --output text)
  
  if [[ -z "$services" ]]; then
    echo -e "${AWS_COLOR_RED}No matching services found.${AWS_COLOR_NC}" >&2
    return 1
  fi

  local service=$(echo $services | tr " " "\n" | head -n 1)
  local service_name=$(basename $service)
  echo -e "${AWS_COLOR_GREEN}Using service: $service_name${AWS_COLOR_NC}" >&2
  echo "$service"
}

# Find IPs of ECS tasks for a service
aws_find_task_ips() {
  local cluster="$1"
  local service="$2"

  if [[ -z "$cluster" || -z "$service" ]]; then
    echo -e "${AWS_COLOR_RED}Cluster ARN and service ARN/name are required.${AWS_COLOR_NC}" >&2
    return 1
  fi

  # Extract service name if full ARN was provided
  local service_name
  if [[ "$service" == *"/"* ]]; then
    service_name=$(basename $service)
  else
    service_name=$service
  fi

  echo -e "${AWS_COLOR_GRAY}Finding task IPs for service: $service_name in cluster: $cluster...${AWS_COLOR_NC}" >&2

  local tasks=$(aws ecs list-tasks --cluster $cluster --service-name $service_name --query "taskArns" --output text)
  
  if [[ -z "$tasks" ]]; then
    echo -e "${AWS_COLOR_RED}No tasks found for service.${AWS_COLOR_NC}" >&2
    return 1
  fi

  local task_ips=$(aws ecs describe-tasks --cluster $cluster --tasks $tasks \
    --query "tasks[].attachments[0].details[?name=='privateIPv4Address'].value" \
    --output text)

  if [[ -z "$task_ips" ]]; then
    echo -e "${AWS_COLOR_RED}Could not extract IP addresses from tasks.${AWS_COLOR_NC}" >&2
    return 1
  fi

  echo -e "${AWS_COLOR_GREEN}Found task IPs: $task_ips${AWS_COLOR_NC}" >&2
  echo "$task_ips"
}

# Set up SSM tunnel to a remote host via an EC2 instance
aws_setup_tunnel() {
  local instance_id="$1"
  local target_host="$2"
  local remote_port="${3:-80}"
  local local_port="${4:-8080}"
  local background="${5:-true}"

  if [[ -z "$instance_id" || -z "$target_host" ]]; then
    echo -e "${AWS_COLOR_RED}Instance ID and target host are required.${AWS_COLOR_NC}" >&2
    return 1
  fi

  echo -e "${AWS_COLOR_GRAY}Setting up tunnel: localhost:$local_port -> $target_host:$remote_port via $instance_id${AWS_COLOR_NC}" >&2

  local cmd="aws ssm start-session --target \"$instance_id\" \
    --document-name \"AWS-StartPortForwardingSessionToRemoteHost\" \
    --parameters \"host=$target_host,portNumber=$remote_port,localPortNumber=$local_port\""

  if [[ "$background" == "true" ]]; then
    eval "$cmd &"
    sleep 2  # Allow a moment for the tunnel to establish
    echo -e "${AWS_COLOR_GREEN}Tunnel started in background${AWS_COLOR_NC}" >&2
  else
    eval "$cmd"
  fi
}

# Clean up all SSM tunnels
aws_cleanup_tunnels() {
  echo -e "${AWS_COLOR_GRAY}Cleaning up SSM tunnels...${AWS_COLOR_NC}" >&2
  pkill -f "aws ssm start-session --target" || true
  echo -e "${AWS_COLOR_GREEN}Tunnels cleaned up${AWS_COLOR_NC}" >&2
}

# Convert AWS timestamp to human readable format
aws_convert_timestamp() {
  local timestamp=$1

  if [[ "$timestamp" =~ ^[0-9]+$ ]]; then
    # Try macOS date format first, then Linux
    date -r $((timestamp / 1000)) "+%Y-%m-%d %H:%M:%S" 2>/dev/null ||
      date -d @$((timestamp / 1000)) "+%Y-%m-%d %H:%M:%S" 2>/dev/null ||
      echo "Timestamp: $timestamp"
  else
    echo "Invalid timestamp"
  fi
}

# Monitor logs from a specific CloudWatch log group
aws_monitor_logs() {
  local log_group="$1"
  local minutes_ago="${2:-5}"
  local limit="${3:-50}"
  local region="${4:-us-west-2}"

  if [[ -z "$log_group" ]]; then
    echo -e "${AWS_COLOR_RED}Log group name is required.${AWS_COLOR_NC}" >&2
    return 1
  fi

  local start_time=$(($(date +%s) - minutes_ago * 60))000
  echo -e "${AWS_COLOR_GRAY}Monitoring logs since $(aws_convert_timestamp $start_time)...${AWS_COLOR_NC}" >&2

  aws logs filter-log-events \
    --log-group-name "$log_group" \
    --start-time "$start_time" \
    --region "$region" \
    --limit "$limit" | \
  jq -r ".events[] | \"[\(.timestamp | tostring | .[0:10] | tonumber | strftime(\"%Y-%m-%d %H:%M:%S\")) - \(.logStreamName)] \(.message)\""
}

# Test HTTP endpoint with simple GET request
aws_test_endpoint() {
  local endpoint="$1"
  local timeout="${2:-5}"
  
  if [[ -z "$endpoint" ]]; then
    echo -e "${AWS_COLOR_RED}Endpoint URL is required.${AWS_COLOR_NC}" >&2
    return 1
  fi

  echo -e "${AWS_COLOR_GRAY}Testing endpoint: $endpoint...${AWS_COLOR_NC}" >&2
  
  local response=$(curl -s -m $timeout -w "\n%{http_code}" "$endpoint")
  local http_code=$(echo "$response" | tail -n1)
  local body=$(echo "$response" | sed '$d')

  if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
    echo -e "${AWS_COLOR_GREEN}Endpoint is healthy (HTTP $http_code)${AWS_COLOR_NC}" >&2
    echo "$body" | grep -q '{' && echo "$body" | jq '.' || echo "$body"
    return 0
  else
    echo -e "${AWS_COLOR_RED}Endpoint returned HTTP $http_code${AWS_COLOR_NC}" >&2
    echo "$body"
    return 1
  fi
}

# Wrapper to set up tunnels to multiple tasks
aws_tunnel_to_service() {
  local service_pattern="$1"
  local port="$2"
  local local_start_port="${3:-8080}"
  
  if [[ -z "$service_pattern" || -z "$port" ]]; then
    echo -e "${AWS_COLOR_RED}Service pattern and port are required.${AWS_COLOR_NC}" >&2
    return 1
  fi
  
  # Check prerequisites
  aws_check_prereqs || return 1
  
  # Find instance for tunneling
  local instance=$(aws_find_instance "*")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  # Find cluster and service
  local cluster=$(aws_find_cluster)
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  local service=$(aws_find_service "$cluster" "$service_pattern")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  # Get task IPs
  local task_ips=$(aws_find_task_ips "$cluster" "$service")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  # Set up tunnels to each task
  local endpoints=()
  local current_port=$local_start_port
  
  for ip in $task_ips; do
    aws_setup_tunnel "$instance" "$ip" "$port" "$current_port" true
    endpoints+=("http://localhost:$current_port")
    ((current_port++))
  done
  
  echo -e "${AWS_COLOR_GREEN}Set up tunnels to endpoints: ${endpoints[*]}${AWS_COLOR_NC}" >&2
  echo "${endpoints[*]}"
}

# Register cleanup to run when terminal session exits
aws_register_cleanup() {
  trap aws_cleanup_tunnels EXIT HUP INT TERM
  echo -e "${AWS_COLOR_BLUE}Registered cleanup handler for AWS tunnels${AWS_COLOR_NC}" >&2
}

# Display help information about these utilities
aws_utils_help() {
  echo -e "${AWS_COLOR_BLUE}AWS Utility Functions${AWS_COLOR_NC}"
  echo -e "${AWS_COLOR_GRAY}====================${AWS_COLOR_NC}"
  echo
  echo -e "${AWS_COLOR_YELLOW}aws_find_instance${AWS_COLOR_NC} [name_pattern] [state]"
  echo "  Find EC2 instance by name pattern"
  echo
  echo -e "${AWS_COLOR_YELLOW}aws_find_cluster${AWS_COLOR_NC} [name_pattern]"
  echo "  Find ECS cluster by name pattern"
  echo
  echo -e "${AWS_COLOR_YELLOW}aws_find_service${AWS_COLOR_NC} <cluster> [service_pattern]"
  echo "  Find ECS service in a cluster"
  echo
  echo -e "${AWS_COLOR_YELLOW}aws_find_task_ips${AWS_COLOR_NC} <cluster> <service>"
  echo "  Find IP addresses of tasks for an ECS service"
  echo
  echo -e "${AWS_COLOR_YELLOW}aws_setup_tunnel${AWS_COLOR_NC} <instance_id> <target_host> [remote_port] [local_port] [background]"
  echo "  Set up an SSM tunnel to a remote host"
  echo
  echo -e "${AWS_COLOR_YELLOW}aws_cleanup_tunnels${AWS_COLOR_NC}"
  echo "  Clean up all SSM tunnels"
  echo
  echo -e "${AWS_COLOR_YELLOW}aws_monitor_logs${AWS_COLOR_NC} <log_group> [minutes_ago] [limit] [region]"
  echo "  Monitor logs from a CloudWatch log group"
  echo
  echo -e "${AWS_COLOR_YELLOW}aws_test_endpoint${AWS_COLOR_NC} <endpoint> [timeout]"
  echo "  Test an HTTP endpoint"
  echo
  echo -e "${AWS_COLOR_YELLOW}aws_tunnel_to_service${AWS_COLOR_NC} <service_pattern> <port> [local_start_port]"
  echo "  Set up tunnels to all tasks in an ECS service"
  echo
  echo -e "${AWS_COLOR_YELLOW}aws_register_cleanup${AWS_COLOR_NC}"
  echo "  Register automatic cleanup of tunnels when session ends"
}

# Display an example workflow 
aws_utils_example() {
  echo -e "${AWS_COLOR_BLUE}AWS Utils Example Workflow${AWS_COLOR_NC}"
  echo -e "${AWS_COLOR_GRAY}========================${AWS_COLOR_NC}"
  echo 
  echo -e "# Find and tunnel to an API service"
  echo -e "${AWS_COLOR_GRAY}cluster=\$(aws_find_cluster \"api\")${AWS_COLOR_NC}"
  echo -e "${AWS_COLOR_GRAY}service=\$(aws_find_service \"\$cluster\" \"api\")${AWS_COLOR_NC}"
  echo -e "${AWS_COLOR_GRAY}task_ips=\$(aws_find_task_ips \"\$cluster\" \"\$service\")${AWS_COLOR_NC}"
  echo -e "${AWS_COLOR_GRAY}instance=\$(aws_find_instance)${AWS_COLOR_NC}"
  echo -e "${AWS_COLOR_GRAY}for ip in \$task_ips; do${AWS_COLOR_NC}"
  echo -e "${AWS_COLOR_GRAY}  aws_setup_tunnel \"\$instance\" \"\$ip\" 8080 8000${AWS_COLOR_NC}"
  echo -e "${AWS_COLOR_GRAY}done${AWS_COLOR_NC}"
  echo
  echo -e "# Or use the all-in-one wrapper function"
  echo -e "${AWS_COLOR_GRAY}endpoints=\$(aws_tunnel_to_service \"api\" 8080)${AWS_COLOR_NC}"
  echo -e "${AWS_COLOR_GRAY}aws_test_endpoint \"\${endpoints%% *}\"${AWS_COLOR_NC}"
  echo -e "${AWS_COLOR_GRAY}aws_register_cleanup${AWS_COLOR_NC}"
}
