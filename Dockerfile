FROM nestybox/ubuntu-bionic-systemd-docker:latest

# Install nano, ping & docker-compose
RUN apt-get update \
    && apt install -y --no-install-recommends \
    nano \
    iputils-ping \
    docker-compose \
# Remove files necessary for installation, to cut the image size
    && rm -rf /var/lib/apt/lists/*

# Config SSH-Server
RUN mkdir /var/run/sshd \
# Add user novatec
    && useradd --create-home --shell /bin/bash novatec \
# Set password for user novatec
    && echo "novatec:Schulung2022" | chpasswd \
# Add user novatec to the sudo group
    && adduser novatec sudo \
# Set password for root user --> user can change to root with 'su' and in
    && echo 'root:root' | chpasswd \
# Disables login via root user with ssh
    && sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config \
# Give the novatec user permissions to exec docker
    && usermod -aG docker novatec \
# Activates login via ssh with username and password
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
# Create .kube dir for novatec user and add permission to access the Kubeconfig in there
    && mkdir -p home/novatec/.kube \
    && chown -R novatec home/novatec/.kube/ \
# Remove files necessary for installation, to cut the image size
    && rm -rf /var/lib/apt/lists/*


# Install curl & kubectl
RUN apt install -y --no-install-recommends curl \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && chmod +x kubectl \
    && mkdir -p ~/.local/bin/kubectl \
    && mv ./kubectl ~/.local/bin/kubectl \
    && kubectl version --client \
# Remove files necessary for installation, to cut the image size
    && rm -rf /var/lib/apt/lists/*


# Create alias for kubectl command
RUN echo alias k=kubectl >> home/novatec/.bashrc \
    && echo alias k=kubectl >> /root/.bashrc


# docker build --no-cache -t ratzel921/remote-server:ubuntu .
# docker build -t ratzel921/remote-server:ubuntu .
# docker push ratzel921/remote-server:ubuntu

# docker build -t novatec/technologyconsulting-training-usercontainer .
# docker push novatec/technologyconsulting-training-usercontainer:lastest
