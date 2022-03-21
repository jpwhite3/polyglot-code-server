FROM ubuntu:latest


RUN apt-get update --no-install-recommends \
	&& DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
	#**** install runtime dependencies ****
	curl \
	wget \
	sudo \
	apt-utils \
	g++ \
	gcc \
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
	# Unbiquitous CLI tools
	git \
	make \
	p7zip-full \
	xz-utils \
	jq \
	vim \
	less \
	# ZSHELL LATEST
	zsh \
	# PYTHON LATEST
	python3-pip python3-dev \
	# JAVA LATEST
	openjdk-11-jdk-headless maven gradle \
	# .NET-CORE LATEST
	apt-transport-https dotnet-sdk-3.1 \
	# NODE LATEST
	nodejs yarn npm \
	# GO LATEST
	golang-go \
	# CLEAN UP
 	&& apt-get purge --auto-remove -y \
	&& apt-get clean \
 	&& rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# Install zshell configuration
RUN zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
  && sed -i 's/# DISABLE_AUTO_UPDATE="true"/DISABLE_AUTO_UPDATE="true"/' /root/.zshrc \
  && sed -i 's/export ZSH="\/config\/.oh-my-zsh"/export ZSH="~\/.oh-my-zsh"/' /root/.zshrc

# NODE SETUP
RUN node --version \
    && npm --version

# PYTHON SETUP
RUN cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip setuptools wheel poetry \
  && python3 --version \
  && pip --version

# GO SETUP
RUN go version

# CODER LATEST
ENV CODER_VERSION 4.1.0
RUN \
mkdir -p /config/data /config/extensions /config/workspace \
&& curl -fOL https://github.com/cdr/code-server/releases/download/v${CODER_VERSION}/code-server_${CODER_VERSION}_amd64.deb \
&& sudo dpkg -i code-server_${CODER_VERSION}_amd64.deb

# Install VSCode extentions
RUN \
code-server --install-extension eamodio.gitlens \
&& code-server --install-extension mhutchie.git-graph \
&& code-server --install-extension streetsidesoftware.code-spell-checker \
&& code-server --install-extension oderwat.indent-rainbow \
&& code-server --install-extension VisualStudioExptTeam.vscodeintellicode \
&& code-server --install-extension ms-python.python \
&& code-server --install-extension golang.go \
&& code-server --install-extension dbaeumer.vscode-eslint \
&& code-server --install-extension vscjava.vscode-java-pack \
&& code-server --install-extension ms-dotnettools.csharp \
&& code-server --install-extension redhat.vscode-yaml \
&& code-server --install-extension bierner.markdown-mermaid \
&& rm -rf /root/.local/share/code-server/CachedExtensionVSIXs/*

# ports and volumes
EXPOSE 9000 9001 9002 9003 9004

# Set entrypoint
ENTRYPOINT ["code-server", "--bind-addr", "0.0.0.0:9000", "--user-data-dir", "/config/data", "--extensions-dir", "/root/.local/share/code-server/extensions", "--disable-telemetry", "--auth", "none", "/config/workspace"]
