FROM ubuntu:latest


RUN apt update \
    && apt upgrade -y \
	&& apt install software-properties-common -y \
    && add-apt-repository ppa:deadsnakes/ppa \
	&& DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
	#**** install runtime dependencies ****
	curl \
	wget \
	sudo \
	apt-utils \
	apt-transport-https \
	g++ \
	gcc \
	git \
	make \
	p7zip-full \
	xz-utils \
	jq \
	vim \
	tree \
	less \
	libc6-dev \
	dirmngr \
	gpg gpg-agent \
	ca-certificates \
	# CLEAN UP
    && apt-get purge --auto-remove -y \
	&& apt-get clean \
    && rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/* \
	&& wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb --no-check-certificate \
    && dpkg -i packages-microsoft-prod.deb \
	&& rm -f packages-microsoft-prod.deb

ENV TZ='America/New_York'
RUN apt-get update --no-install-recommends \
	&& DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
	# PYTHON LATEST
	python3 python3-dev python3-venv python3-pip \
	# JAVA LATEST
	openjdk-11-jdk-headless maven gradle \
	# .NET-CORE LATEST
	dotnet-sdk-6.0 \
	# CLEAN UP
    && apt-get purge --auto-remove -y \
	&& apt-get clean \
    && rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*


# NODE Installation with nvm 
ENV NODE_VERSION lts/gallium
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . ~/.nvm/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# NODE Configuration
ENV NVM_DIR ~/.nvm
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/v$NODE_VERSION/bin:$PATH


# PYTHON Configuration
RUN \
python3 -m pip install --upgrade pip setuptools wheel poetry

# GO Installation
RUN \
curl -OL https://go.dev/dl/go1.18.linux-amd64.tar.gz \
&& tar -C /usr/local -xvf go1.18.linux-amd64.tar.gz \
&& echo "export PATH=/usr/local/go/bin:$PATH" >> /root/.profile \
&& /usr/local/go/bin/go version

# CODER Installation
ENV CODER_VERSION 4.1.0
RUN \
mkdir -p /config/data /config/workspace \
&& curl -fOL https://github.com/cdr/code-server/releases/download/v${CODER_VERSION}/code-server_${CODER_VERSION}_amd64.deb \
&& sudo dpkg -i code-server_${CODER_VERSION}_amd64.deb

# Install VSCode extentions
RUN \
code-server --install-extension eamodio.gitlens \
&& code-server --install-extension mhutchie.git-graph \
&& code-server --install-extension ms-python.python \
&& code-server --install-extension golang.go \
&& code-server --install-extension dbaeumer.vscode-eslint \
&& code-server --install-extension vscjava.vscode-java-pack \
&& code-server --install-extension richardwillis.vscode-gradle \
&& code-server --install-extension formulahendry.code-runner \
&& code-server --install-extension muhammad-sammy.csharp \
&& code-server --install-extension patcx.vscode-nuget-gallery \
&& code-server --install-extension github.vscode-pull-request-github \
&& code-server --install-extension redhat.vscode-yaml \
&& code-server --install-extension bierner.markdown-mermaid \
&& rm -rf /root/.local/share/code-server/CachedExtensionVSIXs/*

# ports and volumes
EXPOSE 9000 9001 9002 9003 9004

# Set entrypoint
ENTRYPOINT ["code-server", "--bind-addr", "0.0.0.0:9000", "--user-data-dir", "/config/data", "--extensions-dir", "/root/.local/share/code-server/extensions", "--disable-telemetry", "--auth", "none", "/config/workspace"]
