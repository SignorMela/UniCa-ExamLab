# ==============================================================================
# UniCa-ExamLab: VS Code C/C++ Container for Computerized University Exams
# ==============================================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CODESERVER_VERSION=4.98.2
ENV SERVICE_URL=https://open-vsx.org/vscode/gallery
ENV ITEM_URL=https://open-vsx.org/vscode/item
ENV CPPTOOLS_VERSION=v1.12.4
ENV SUDO_FORCE_REMOVE=yes

# Non-root container user configuration
ARG USER=examlab
ARG UID=1010
ARG VSCODE_SRV_DIR=/vscode
ENV VSCODE_SRV_DIR=${VSCODE_SRV_DIR}

# 1. Install base system tools, C/C++ compilers, and code-server
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        build-essential \
        cmake \
        gdb \
        make \
        zip \
        unzip \
        ca-certificates && \
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODESERVER_VERSION} && \
    apt-get clean

# 2. Create non-root examlab user and set up workspace directories
RUN useradd -ms /bin/bash -u ${UID} $USER && \
    usermod -d ${VSCODE_SRV_DIR} $USER && \
    mkdir -p ${VSCODE_SRV_DIR}/extensions && \
    mkdir -p ${VSCODE_SRV_DIR}/data/User && \
    mkdir -p ${VSCODE_SRV_DIR}/workspace && \
    mkdir -p /example_project/.vscode && \
    cp /root/.bashrc ${VSCODE_SRV_DIR}/.bashrc && \
    cp /root/.profile ${VSCODE_SRV_DIR}/.profile && \
    echo 'alias code=code-server' >> ${VSCODE_SRV_DIR}/.bashrc && \
    echo 'export PS1="\[\033[01;32m\]\u@unica-examlab\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> ${VSCODE_SRV_DIR}/.bashrc

# 3. Copy configuration files, C/C++ exam template, and startup entrypoint
COPY ./settings.json ${VSCODE_SRV_DIR}/data/User/settings.json
COPY ./project/ /example_project/
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh

# 4. Download architecture-specific C/C++ extension (amd64 or arm64 for Apple Silicon)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ]; then \
        VSIX_FILE="cpptools-linux-aarch64.vsix"; \
    else \
        VSIX_FILE="cpptools-linux.vsix"; \
    fi && \
    curl -fsSL "https://github.com/microsoft/vscode-cpptools/releases/download/${CPPTOOLS_VERSION}/${VSIX_FILE}" -o /tmp/cpptools.vsix

# 5. Exam security hardening: remove sudo and apt package manager
# Prevents students from installing unauthorized tools or escalating privileges in the web terminal
RUN apt-get remove --autoremove --purge -y sudo apt --allow-remove-essential && \
    rm -rf /var/lib/apt/lists/*

# 6. Set directory ownership and permissions
RUN chown -R $USER:$USER ${VSCODE_SRV_DIR} && \
    chown -R $USER:$USER /example_project && \
    chown $USER:$USER /tmp/cpptools.vsix

# Switch to non-root exam user
USER $USER

# 7. Install pre-configured VS Code extensions
RUN code-server --extensions-dir ${VSCODE_SRV_DIR}/extensions --install-extension /tmp/cpptools.vsix && \
    code-server --extensions-dir ${VSCODE_SRV_DIR}/extensions --install-extension formulahendry.code-runner && \
    rm -f /tmp/cpptools.vsix

WORKDIR ${VSCODE_SRV_DIR}/workspace
EXPOSE 8080

ENTRYPOINT [ "/docker-entrypoint.sh" ]
