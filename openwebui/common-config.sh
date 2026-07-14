#!/bin/bash

# Common configuration for openclaw and hermes
# Contains common functions and installation logic

install_module() {
    local module_name=$1
    local max_retries=$2
    local attempts=0
    local backoff=1
    local max_backoff=30
    local success=false

    echo "========================================================="
    echo "--> Installing module: ${module_name}"

    while [ $attempts -lt $max_retries ]; do
        attempts=$((attempts + 1))
        echo -e "\n[Attempt $attempts of $max_retries] "

        if eval "$module_name"; then
            success=true
            break
        else
            echo "FAILURE: Installation failed for module $module_name (Exit code: $?)"

            if [ $attempts -eq $max_retries ]; then
                echo "No more retries available."
                break
            fi

            local sleep_time=$backoff
            if [ $sleep_time -gt $max_backoff ]; then
                sleep_time=$max_backoff
            fi

            echo "Waiting $sleep_time seconds before retry..."
            sleep $sleep_time

            backoff=$((backoff * 2))
        fi
    done

    if [ "$success" = true ]; then
        echo "SUCCESS"
        echo "========================================================="
        return 0
    else
        echo "FAILURE: Failed to install module '${module_name}' after ${max_retries} attempts."
        echo "========================================================="
        return 1
    fi

}

install_github_modules() {
    local workdir=$1
    local gh_key=$2
    local module_list=$3

    cd "$workdir"
    for module in $module_list; do
        install_module "npx skills add https://github.com/${gh_key}/tree/main/skills/${module} -y" "5"
        rm -f skills/${module}
        mv .agents/skills/${module} skills
    done
}

install_cli_anything() {
    local workdir=$1

    cd "$workdir"
    $UV pip install cli-anything-hub
    npx skills add HKUDS/CLI-Anything --skill cli-hub-meta-skill -y
    rm -f skills/cli-hub-meta-skill
    mv .agents/skills/cli-hub-meta-skill skills
}
