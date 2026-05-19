#!/bin/bash
set -e

#This turns out to be complicated since you have to make this work with
#local proxies.

# also consider removing the directory /opt/tljh before starting
# this clears out all of the old state. 

#Need to shut down caddy since installation requires
#port 80

# Initialize error counter
errors=0

# Change to the directory where the script exists
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd $script_dir

# Common error checking function
set_error() {
    echo "Error: $1"
    errors=$((errors + 1))
}

# Check if running as superuser
[ $EUID -ne 0 ] && set_error "Error: This script must be run as root"
if [ -d "/opt/tljh" ]; then
  echo "Directory /opt/tljh exists. Would you like to remove it? (yes/no)"
  read -r response
  if [[ $response =~ ^[Yy]es$ ]]; then
    echo -n "Removing /opt/tljh ..."
    rm -rf "/opt/tljh"
    echo " done"
  else
    echo "Exiting without removing /opt/tljh."
    exit 0
  fi
fi
[ ! -f "config.yaml" ] && set_error "Error: config.yaml does not exist"

# If any errors were found, exit
if [[ $errors -gt 0 ]]; then
   echo "Errors found: $errors"
   exit 1
fi




# If we reach here, all checks passed
echo "All checks passed. Continuing with script..."

systemctl stop caddy
systemctl stop jupyterhub
apt install python3 python3-dev git curl npm texlive texlive-fonts-extra texlive-science texlive-bibtex-extra biber
python3  ./bootstrap.py
cp config.yaml /opt/tljh/config
/opt/tljh/user/bin/pip install -r requirements.txt

# The mcp server interferes with port 3001
cp jupyter_server_config.json /opt/tljh/user/etc/jupyter
pushd /opt/tljh/hub/lib/python*/site-packages
patch -p1 < $script_dir/badname.patch
popd

# use caddy instead of traefik
tljh-config set http.port 3002
tljh-config set https.enabled false
tljh-config reload proxy
tljh-config reload

systemctl start caddy
systemctl restart jupyterhub


