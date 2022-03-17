# FROM nestybox/alpine-docker
FROM nestybox/ubuntu-bionic-systemd-docker:latest


RUN apt-get update && \ 
    apt install -y --no-install-recommends \
    nano \
    iputils-ping \
    docker-compose \
    && rm -rf /var/lib/apt/lists/*

# Config SSH-Server
RUN mkdir /var/run/sshd \
    && useradd --create-home --shell /bin/bash novatec && echo "novatec:Schulung2022" | chpasswd && adduser novatec sudo \
    && echo 'root:root' | chpasswd \
    && sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin no/' \
    /etc/ssh/sshd_config \
    && usermod -aG docker novatec \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
    && rm -rf /var/lib/apt/lists/*


# Install curl & kubectl
RUN apt install -y --no-install-recommends curl  && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    chmod +x kubectl && \
    mkdir -p ~/.local/bin/kubectl && \
    mv ./kubectl ~/.local/bin/kubectl && \
    kubectl version --client \
    && mkdir -p home/novatec/.kube \
    && chown -R novatec home/novatec/.kube/ \
    && rm -rf /var/lib/apt/lists/*

RUN echo alias k=kubectl >> home/novatec/.bashrc \
    && echo alias k=kubectl >> /root/.bashrc


# docker build --no-cache -t ratzel921/remote-server:ubuntu .
# docker push ratzel921/remote-server:ubuntu

# docker build -t novatec/technologyconsulting-training-usercontainer .
# docker push novatec/technologyconsulting-training-usercontainer:lastest
