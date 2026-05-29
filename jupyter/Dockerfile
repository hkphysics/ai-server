ARG BASE_IMAGE=jupyterhub/jupyterhub
FROM $BASE_IMAGE
WORKDIR /app
RUN  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3-dev git curl npm texlive texlive-fonts-extra texlive-science texlive-bibtex-extra biber && \
       rm -rf /usr/lib/python3.*/EXTERNALLY-MANAGED && \
       apt-get clean && \
       mkdir -p /etc/jupyterhub && \
       cd /etc/skel && \
       ln -s /mnt/shared shared && \
   rm -rf /var/cache/apt/* /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install oauthenticator
RUN pip install -r requirements.txt
