FROM ubuntu:22.04

LABEL maintainer="Marcus Vinicius Barros da Silva <marcus.mvbs@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \ 
    apt-get install -y --no-install-recommends \
    gnupg curl wget ca-certificates apt-utils apt-transport-https dos2unix vim \
    python3 python3-pip python3-apt \
    ansible \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --upgrade pip && \
    ansible-galaxy collection install community.general community.kubernetes

# Install Docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Storing Ansible, Kind, ArgoCD application
RUN mkdir -p /ansible /kind /charts /argocd
COPY ansible/ /ansible/
COPY kind/ /kind/
COPY charts/ /charts/
COPY application.yaml application.yaml

USER root
COPY argocd.sh /argocd/argocd.sh
RUN chmod +x argocd/argocd.sh

# COPY .credentials.txt .github_creds.txt

# Expose any necessary ports
EXPOSE 8080 6443 22 80

ENTRYPOINT ["sh", "-c", "tail -f /dev/null"]