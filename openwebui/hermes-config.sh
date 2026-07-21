#!/bin/bash

set -e
umask 000
export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin
export UV=uv
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source $SCRIPT_DIR/common-config.sh

modules=(
    "@steipete/weather"
    "@gpyangyoujun/multi-search-engine"
    "word-docx"
    "powerpoint-pptx"
    "@ivangdavila/excel-xlsx"
    "@ivangdavila/data-analysis"
    "google-maps"
    "@oswalpalash/ontology"
    "playwright-mcp"
    "x-search"
    "@pskoett/self-improving-agent"
    "realtime-crypto-price-api"
    "goplaces"
    "baidu"
    "image"
    "productivity"
    "@spclaudehome/skill-vetter"
    "zhipu-web-search"
    "baidu-ai-map"
    "annas-archive"
    "zotero"
)

for module in "${modules[@]}"; do
    if [ -d "/opt/hermes/skills/${module}" ]; then
        echo "Skipping ${module}, already installed";
    else
	install_module "npx clawhub install --workdir /opt/hermes  ${module}" "5"
    fi
done

gh_key="K-Dense-AI/scientific-agent-skills"
gh_modules="aeon \
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

install_github_modules /opt/hermes "$gh_key" "$gh_modules"
install_cli_anything /opt/hermes

