find_log_groups() {
    local substring=$1
    aws logs describe-log-groups --query "logGroups[?contains(logGroupName, '$substring')].logGroupName"
}

aws_tail_service_logs() {
    # Select the cluster
    local cluster=$(aws ecs list-clusters --query 'clusterArns[*]' --output text | tr '\t' '\n' | fzf --prompt="Select Cluster> ")
    if [[ -z "$cluster" ]]; then
        echo "No cluster selected, exiting."
        return
    fi

    # Select the service
    local service=$(aws ecs list-services --cluster $cluster --query 'serviceArns[*]' --output text | tr '\t' '\n' | fzf --prompt="Select Service> ")
    if [[ -z "$service" ]]; then
        echo "No service selected, exiting."
        return
    fi

    # Get all tasks for the selected service
    local tasks=$(aws ecs list-tasks --cluster $cluster --service-name $(basename $service) --query 'taskArns[*]' --output text)
    if [[ -z "$tasks" ]]; then
        echo "No tasks found for service, exiting."
        return
    fi

    # Extract task definition ARN
    local task_definition_arn=$(aws ecs describe-services --cluster $cluster --services $service --query 'services[0].taskDefinition' --output text)

    # Extract log group and log stream prefix from task definition
    local log_group_name=$(aws ecs describe-task-definition --task-definition $task_definition_arn --query 'taskDefinition.containerDefinitions[0].logConfiguration.options."awslogs-group"' --output text)
    local log_stream_prefix=$(aws ecs describe-task-definition --task-definition $task_definition_arn --query 'taskDefinition.containerDefinitions[0].logConfiguration.options."awslogs-stream-prefix"' --output text)

    # Extract container name from task definition
    local container_name=$(aws ecs describe-task-definition --task-definition $task_definition_arn --query 'taskDefinition.containerDefinitions[0].name' --output text)

    if [[ -z "$log_group_name" ]]; then
        echo "No log group found, exiting."
        return
    fi

    if [[ -z "$log_stream_prefix" ]]; then
        echo "No log stream prefix found, exiting."
        return
    fi

    if [[ -z "$container_name" ]]; then
        echo "No container name found, exiting."
        return
    fi

    echo "Tailing logs for service: $service (Container: $container_name)"

    # Combine log stream prefix and container name for the log stream prefix
    local full_log_stream_prefix="${log_stream_prefix}/${container_name}"

    # Tail logs using the combined log stream prefix
    aws logs tail $log_group_name --log-stream-name-prefix $full_log_stream_prefix --follow
}

aws_search_service_logs() {
    # Select the cluster
    local cluster=$(aws ecs list-clusters --query 'clusterArns[*]' --output text | tr '\t' '\n' | fzf --prompt="Select Cluster> ")
    if [[ -z "$cluster" ]]; then
        echo "No cluster selected, exiting."
        return
    fi

    # Select the service
    local service=$(aws ecs list-services --cluster $cluster --query 'serviceArns[*]' --output text | tr '\t' '\n' | fzf --prompt="Select Service> ")
    if [[ -z "$service" ]]; then
        echo "No service selected, exiting."
        return
    fi

    local task_definition_arn=$(aws ecs describe-services --cluster $cluster --services $service --query 'services[0].taskDefinition' --output text)

    local log_group_name=$(aws ecs describe-task-definition --task-definition $task_definition_arn --query 'taskDefinition.containerDefinitions[0].logConfiguration.options."awslogs-group"' --output text)
    local log_stream_prefix=$(aws ecs describe-task-definition --task-definition $task_definition_arn --query 'taskDefinition.containerDefinitions[0].logConfiguration.options."awslogs-stream-prefix"' --output text)
    local container_name=$(aws ecs describe-task-definition --task-definition $task_definition_arn --query 'taskDefinition.containerDefinitions[0].name' --output text)

    if [[ -z "$log_group_name" || -z "$log_stream_prefix" || -z "$container_name" ]]; then
        echo "Missing logging information, exiting."
        return
    fi

    echo "Fetching last 1000 log events for service: $service (Container: $container_name)"

    local full_log_stream_prefix="${log_stream_prefix}/${container_name}"

    aws logs filter-log-events --log-group-name $log_group_name --log-stream-name-prefix $full_log_stream_prefix --limit 1000 --query 'events[*].message' --output text | fzf --height 40% --layout=reverse --ansi --preview "echo {}"
}

select_cluster() {
    aws ecs list-clusters --query 'clusterArns[*]' --output text | tr '\t' '\n' | fzf --prompt="Select Cluster> "
}

select_service() {
    local cluster=$1
    aws ecs list-services --cluster $cluster --query 'serviceArns[*]' --output text | tr '\t' '\n' | fzf --prompt="Select Service> "
}

get_logging_info() {
    local cluster=$1
    local service=$2

    local task_definition_arn=$(aws ecs describe-services --cluster $cluster --services $service --query 'services[0].taskDefinition' --output text)

    local log_group_name=$(aws ecs describe-task-definition --task-definition $task_definition_arn --query 'taskDefinition.containerDefinitions[0].logConfiguration.options."awslogs-group"' --output text)
    local log_stream_prefix=$(aws ecs describe-task-definition --task-definition $task_definition_arn --query 'taskDefinition.containerDefinitions[0].logConfiguration.options."awslogs-stream-prefix"' --output text)
    local container_name=$(aws ecs describe-task-definition --task-definition $task_definition_arn --query 'taskDefinition.containerDefinitions[0].name' --output text)

    echo "$log_group_name $log_stream_prefix/$container_name"
}

fetch_logs() {
    local log_group_name=$1
    local log_stream_name_prefix=$2

    local current_time=$(date +%s)
    local start_time=$((current_time - 900))
    local start_time_ms=$((start_time * 1000))

    local all_logs=""
    local next_token=""

    while true; do
        local token_option=""
        if [[ -n "$next_token" ]]; then
            token_option="--next-token $next_token"
        fi

        local response=$(aws logs filter-log-events \
            --log-group-name "$log_group_name" \
            --log-stream-name-prefix "$log_stream_name_prefix" \
            --start-time "$start_time_ms" \
            --limit 10000 \
            $token_option \
            --output json)

        if [[ -z "$response" || "$response" == "null" ]]; then
            break
        fi

        local logs=$(echo $response | jq -r '.events[] | "\(.timestamp) \(.message)"')
        all_logs+=$'\n'"$logs"

        next_token=$(echo $response | jq -r '.nextForwardToken // empty')
        if [[ -z "$next_token" ]]; then
            break
        fi
    done

    echo "$all_logs"
}

display_logs() {
    echo "$1" | while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local timestamp=$(echo "$line" | awk '{print $1}')
            local message=$(echo "$line" | cut -d' ' -f2-)
            if [[ "$timestamp" =~ ^[0-9]+$ ]]; then
                local epoch_seconds=$((timestamp / 1000))
                local formatted_date=$(date -u -d "@$epoch_seconds" "+%Y-%m-%d %H:%M:%S")
                echo "$formatted_date $message"
            fi
        fi
    done | fzf --ansi --no-sort --height=100% --layout=reverse --preview 'echo {} | cut -d" " -f2-' --preview-window=right:50%:wrap
}

aws_search_logs_with_preview() {
    local cluster=$(select_cluster)
    if [[ -z "$cluster" ]]; then
        return
    fi

    local service=$(select_service $cluster)
    if [[ -z "$service" ]]; then
        return
    fi

    local logging_info=$(get_logging_info $cluster $service)
    local log_group_name=$(echo $logging_info | awk '{print $1}')
    local log_stream_name_prefix=$(echo $logging_info | awk '{print $2}')

    if [[ -z "$log_group_name" || -z "$log_stream_name_prefix" ]]; then
        echo "Logging information could not be retrieved."
        return
    fi

    local logs=$(fetch_logs $log_group_name $log_stream_name_prefix)
    display_logs "$logs"
}

select_ec2_instance() {
    local instances=$(aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query "Reservations[].Instances[].[join('\t', [(Tags[?Key=='Name'].Value | [0]), InstanceId, InstanceType])]" \
        --output text)

    local selected_instance=$(printf "%s\n" $instances | fzf --prompt="Select an EC2 instance> ")

    if [[ -z "$selected_instance" ]]; then
        echo "No instance selected."
        return
    fi

    local instance_id=$(echo $selected_instance | awk '{print $2}')
    echo "$instance_id"
}

select_route53_host() {
    local domains=$(aws route53 list-hosted-zones --query "HostedZones[].[Name]" --output text)
    local selected_domain=$(printf "%s\n" $domains | fzf --prompt="Select a domain> ")
    
    local hosted_zone_id=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$selected_domain'] | [0].Id" --output text | sed 's|/hostedzone/||')
    
    local records=$(aws route53 list-resource-record-sets --hosted-zone-id "$hosted_zone_id" --query "ResourceRecordSets[].[Name,Type]" --output text)
    local selected_record=$(printf "\n%s" $records | fzf --prompt="Select a host record> ")
    
    local host_record=$(echo $selected_record | awk '{print $1}')
    echo "$host_record"
}

aws_setup_tunnel() {
    local ec2_instance_id=$(select_ec2_instance)
    if [[ -z "$ec2_instance_id" ]]; then
        echo "No EC2 instance selected."
        return
    fi

    local host_record=$(select_route53_host)
    if [[ -z "$host_record" ]]; then
        echo "No host record selected."
        return
    fi

    echo "Setting up SSM tunnel through instance $ec2_instance_id to $host_record"
    echo -n "Enter local port to bind e.g., 8090: "
    read local_port
    echo -n "Enter remote port to connect e.g., 8090: "
    read remote_port

    aws ssm start-session \
        --target "$ec2_instance_id" \
        --document-name "AWS-StartPortForwardingSessionToRemoteHost" \
        --parameters host="$host_record",portNumber="$remote_port",localPortNumber="$local_port" &
}


aws_ssm_session() {
    local ec2_instance_id=$(select_ec2_instance)
    if [[ -z "$ec2_instance_id" ]]; then
        echo "No EC2 instance selected."
        return
    fi

    aws ssm start-session --target "$ec2_instance_id"
}
