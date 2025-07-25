aws_env() {
    export AWS_PROFILE=$(cat ~/.aws/config | grep '\[profile' | awk '{print $2}' | sed 's/]//g' | fzf)
}

debug_nexus_users() {
    local results=$(curl -X POST http://localhost:8090/fdb/flureehub/main/query \
        -H "Content-Type: application/json" \
        -d '{"select": ["*"], "from": "_user", "opts": {"compact": true}}')

    echo "Raw Results:"
    echo $results | jq '.'

    echo "\nParsed Usernames:"
    echo $results | jq -r '.[] | .["username"]'

    echo "\nFull User Info:"
    echo $results | jq -r '.[] | "\(.["username"]) (\(.["name"])) - Full Record: \(.)"'

    echo "\nPreview Command Test:"
    local first_user=$(echo $results | jq -r '.[0]["username"]')
    echo "Testing preview for user: $first_user"
    echo $results | jq --arg user "$first_user" '.[] | select(.["username"] == $user)'
}

show_nexus_users() {
    local results=$(curl -X POST http://localhost:8095/fdb/flureehub/main/query \
        -H "Content-Type: application/json" \
        -d '{"select": ["*"], "from": "_user", "opts": {"compact": true}}')

    echo $results | jq -r '.[] | "\(._id) | \(.username) | \(.email) | \(.name)"' | \
        fzf --preview-window=right:60%:wrap \
            --preview '
                line={}
                id=$(echo "$line" | cut -d"|" -f1 | tr -d " ")

                # Fetch detailed info for this specific ID
                curl -s -X POST http://localhost:8095/fdb/flureehub/main/query \
                    -H "Content-Type: application/json" \
                    -d "{\"select\": [\"*\"], \"from\": $id, \"opts\": {\"compact\": true}}" | \
                jq ".[] |
                    .createdAt |= (if . then (. / 1000 | strftime(\"%Y-%m-%d %H:%M:%S\")) else \"Not set\" end) |
                    .updatedAt |= (if . then (. / 1000 | strftime(\"%Y-%m-%d %H:%M:%S\")) else \"Not set\" end) |
                    .accounts |= (
                        if . then map(
                            .createdAt |= (if . then (. / 1000 | strftime(\"%Y-%m-%d %H:%M:%S\")) else \"Not set\" end) |
                            .updatedAt |= (if . then (. / 1000 | strftime(\"%Y-%m-%d %H:%M:%S\")) else \"Not set\" end) |
                            .accessTokenExpires |= (if . then (. | strftime(\"%Y-%m-%d %H:%M:%S\")) else \"Not set\" end)
                        ) else . end
                    ) |
                    .currentPlan.startDate |= (if . then (. / 1000 | strftime(\"%Y-%m-%d %H:%M:%S\")) else \"Not set\" end)"
            ' \
            --height=80%
}

start_local_ledger() {
    docker start -d -a $(docker ps -a --filter "name=current_ledger" --format "{{.ID}}")
}
