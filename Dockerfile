FROM nestybox/ubuntu-bionic-systemd-docker:latest

ARG arg_ssh_user
ENV env_ssh_user=$arg_ssh_user

ARG arg_ssh_user_pw
ENV env_ssh_user_pw=$arg_ssh_user_pw

ARG arg_ssh_root_pw
ENV env_ssh_root_pw=$arg_ssh_root_pw



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
# Add user ssh_user
    && useradd --create-home --shell /bin/bash ${env_ssh_user} \
# Set password for user ${ssh_user
    && echo "${env_ssh_user}:${env_ssh_user_pw}" | chpasswd \
# Add user ssh_user to the sudo group
    && adduser ${env_ssh_user} sudo \
# Set password for root user --> user can change to root with 'su' and in
    && echo "root:${env_ssh_root_pw}" | chpasswd \
# Disables login via root user with ssh
    && sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
# Give the ssh_user user permissions to exec docker
    && usermod -aG docker ${env_ssh_user} \
# Activates login via ssh with username and password
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
# Create .kube dir for ssh_user user and add permission to access the Kubeconfig in there
    && mkdir -p home/${env_ssh_user}/.kube \
    && chown -R ${env_ssh_user} home/${env_ssh_user}/.kube/ \
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
