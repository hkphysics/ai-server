#!/bin/bash

set -e
umask 000
export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin

brew install \
    openclaw/tap/goplaces \
   steipete/tap/gifgrep himalaya \
   steipete/tap/spogo \
   steipete/tap/songsee
brew install --cask 1password-cli
brew cleanup --prune=all

openclaw config set --json "models.providers.ollama" '{
            "baseUrl": "http://host.docker.internal:11434",
            "apiKey": "ollama-local",
            "api": "ollama", "models": [{
            "id": "gemma4",
            "name": "gemma4",
            "reasoning": false,
            "input": [
              "text"
            ],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "contextWindow": 128000,
            "maxTokens": 8192
          }]}'
openclaw config set --json "agents.defaults" '{
"model": {
"primary": "openrouter/openrouter/free",
"fallbacks": [
          "openrouter/openrouter/free",
          "openrouter/openrouter/auto",
          "ollama/glm-4.7-flash",
          "ollama/gemma4",
          "ollama/rnj-1",
          "ollama/olmo-3.1",
          "ollama/qwen3.6",
          "ollama/llama3.2"
]
},
"models": {
        "openrouter/openrouter/free": {},
        "ollama/gemma4:latest": {},
        "ollama/rnj-1:latest": {},
        "ollama/qwen3.6:latest": {},
        "ollama/translategemma:27b": {},
        "ollama/glm-4.7-flash:latest": {},
        "ollama/gpt-oss:latest": {},
        "openrouter/google/gemma-4-26b-a4b-it:free": {},
        "openrouter/google/gemma-4-31b-it:free": {},
        "openrouter/qwen/qwen3-coder:free": {},
        "openrouter/openai/gpt-oss-20b:free": {},
        "openrouter/minimax/minimax-m2.5:free": {}
},
      "workspace": "/home/node/.openclaw/workspace",
      "compaction": {
        "mode": "safeguard"
      },
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      },
      "thinkingDefault": "adaptive"
}'

openclaw config set --json "env" '{
    "shellEnv": {
      "enabled": true,
      "timeoutMs": 5000
    }
  }'

openclaw config set --json "plugins" '{
    "entries": {
      "openrouter": {
        "enabled": true
      },
      "ollama": {
        "enabled": true
      },
      "searxng": {
         "enabled": true,
         "config": {
            "webSearch": {
                "baseUrl": "http://searxng-core:8080"
             }
         }
      }
    }
  }'

openclaw config set --json "auth" '{
    "profiles": {
      "ollama:default": {
        "provider": "ollama",
        "mode": "api_key"
      },
      "openrouter:default": {
        "provider": "openrouter",
        "mode": "api_key"
      }
}
}'

openclaw config set --batch-json '[
{"path": "gateway.mode", "value": "local"},
{"path": "gateway.http.endpoints.chatCompletions.enabled", "value": true},
{"path": "gateway.http.endpoints.responses.enabled", "value": true},
{"path": "gateway.auth.mode", "value": "token"},
{"path": "gateway.auth.token", "value": "your-secure-key-fob!"},
{"path": "tools.web.search.provider", "value": "searxng"},
{"path": "models.mode", "value": "merge"},
{"path": "browser.enabled", "value": true},
{"path": "browser.headless", "value": true},
{"path": "browser.noSandbox", "value": true},
{"path": "browser.defaultProfile", "value": "openclaw"},
{"path": "browser.executablePath", "value": "/usr/bin/chromium-headless-shell"}
]'


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

[[ -n $CLAWHUB_API_KEY ]] && {
    pnpm dlx clawhub login --token $CLAWHUB_API_KEY
}

modules=(
    "weather"
    "multi-search-engine"
    "word-docx"
    "powerpoint-pptx"
    "excel-xlsx"
    "google-maps"
    "ontology"
    "playwright-mcp"
    "x-search"
    "self-improving-agent"
    "realtime-crypto-price-api"
    "goplaces"
    "google-maps"
    "baidu"
    "data-analysis"
    "image"
    "productivity"
    "skill-vetter"
    "zhipu-web-search"
    "baidu-ai-map"
    "annas-archive"
    "zotero"
)

for module in "${modules[@]}"; do
    install_module "npx clawhub install --workdir /app --force ${module}" "5"
done

declare -A gh_modules
gh_modules["hkphysics/scientific-agent-skills"]="aeon\
 astropy \
 citation-management \
 fluidsim \
 hugging-science \
 matplotlib \
 markitdown \
 pyzotero \
 scientific-brainstorming \
 scientific-critical-thinking \
 scientific-visualization \
 seaborn \
 simpy \
 statsmodels \
 sympy"

cd /app
for key in "${!gh_modules[@]}"; do
    module_list="${gh_modules[$key]}"
    for module in $module_list; do
	install_module "npx -y skills add -y https://github.com/${key}/tree/main/skills/${module}" "5"
	rm -f skills/${module}
	mv .agents/skills/${module} skills
    done
done

openclaw skills update --all
# load in npm libraries
openclaw doctor
npm cache clean --force
pip cache purge
