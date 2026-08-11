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
    "@ivangdavila/word-docx"
    "@ivangdavila/powerpoint-pptx"
    "@ivangdavila/excel-xlsx"
    "@ivangdavila/data-analysis"
    "@ivangdavila/memory"
    "@shaharsha/google-maps"
    "@oswalpalash/ontology"
    "@spiceman161/playwright-mcp"
    "@jaaneek/x-search"
    "@pskoett/self-improving-agent"
    "@strykragent/realtime-crypto-price-api"
    "@steipete/goplaces"
    "@ivangdavila/baidu"
    "@ivangdavila/image"
    "@spclaudehome/skill-vetter"
    "@whyhit2005/zhipu-web-search"
    "@baidu-maps/baidu-ai-map"
    "@ricardodpalmeida/annas-archive"
    "@terwox/zotero"
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

