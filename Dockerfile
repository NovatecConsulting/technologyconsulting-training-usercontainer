FROM nestybox/ubuntu-bionic-systemd-docker:latest


RUN apt-get update && \ 
    apt install -y --no-install-recommends \
    nano \
    iputils-ping \
    docker-compose \
    && rm -rf /var/lib/apt/lists/*

# Config SSH-Server
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' \
    /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
    && rm -rf /var/lib/apt/lists/*


# Install curl & kubectl
RUN apt install -y --no-install-recommends curl  && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    chmod +x kubectl && \
    mkdir -p ~/.local/bin/kubectl && \
    mv ./kubectl ~/.local/bin/kubectl && \
    kubectl version --client \
    && rm -rf /var/lib/apt/lists/*
