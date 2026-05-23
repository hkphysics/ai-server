#!/bin/bash

set -e
umask 000
export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin

npx playwright install chromium
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

declare -A modules
modules["hkphysics/scientific-agent-skills"]="aeon\
 astropy \
 citation-management \
 hugging-science \
 seaborn \
 simpy \
 statsmodels \
 sympy"


cd /opt/hermes
for key in "${!modules[@]}"; do
    module_list="${modules[$key]}"
    for module in $module_list; do
	install_module "npx -y skills add -y https://github.com/${key}/tree/main/skills/${module}" "5"
    done
done

