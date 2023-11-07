FROM ghcr.io/jpwhite3/polyglot:latest

# Zsh Configuration
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# CODER Installation
ENV CODER_VERSION 4.18.0
RUN \
	mkdir -p /config/data /config/workspace \
	&& curl -fOL https://github.com/cdr/code-server/releases/download/v${CODER_VERSION}/code-server_${CODER_VERSION}_amd64.deb \
	&& sudo dpkg -i code-server_${CODER_VERSION}_amd64.deb


# Download & install cached VSCode extensions
ENV VSCODE_DOTNET_RUNTIME_VERSION 2.0.0
ENV VSCODE_CSHARP_VERSION 2.9.20
ENV VSCODE_INTELLICODE 1.2.30
ENV VSCODE_INTELLICODE_CSHARP 0.1.26
ENV VSCODE_CSHARP_DEV_KIT 1.1.5
ENV REDHAT_JAVA 1.25.2023110703
ENV VSCODE_JAVA_DEBUG 0.55.0
ENV VSCODE_JAVA_TEST 0.40.2023101002
ENV VSCODE_MAVEN 0.43.0
ENV VSCODE_JAVA_DEP 0.23.2023100802
ENV VSCODE_JAVA_PACK 0.25.2023100708
ENV VSCODE_PYTHON 2023.21.13101009
ENV VSCODE_PYLANCE 2023.11.11
RUN \
	curl -o /tmp/vscode-dotnet-runtime-${VSCODE_DOTNET_RUNTIME_VERSION}.vsix -fL https://coder-extensions.s3.amazonaws.com/ms-dotnettools.vscode-dotnet-runtime-${VSCODE_DOTNET_RUNTIME_VERSION}.vsix \
	&& curl -o /tmp/csharp-${VSCODE_CSHARP_VERSION}.vsix -fL https://coder-extensions.s3.amazonaws.com/ms-dotnettools.csharp-${VSCODE_CSHARP_VERSION}%40linux-x64.vsix \
	&& curl -o /tmp/intellicode-${VSCODE_INTELLICODE}.vsix https://coder-extensions.s3.amazonaws.com/VisualStudioExptTeam.vscodeintellicode-${VSCODE_INTELLICODE}.vsix \
	&& curl -o /tmp/intellicode-csharp-${VSCODE_INTELLICODE_CSHARP}.vsix -fL https://coder-extensions.s3.amazonaws.com/ms-dotnettools.vscodeintellicode-csharp-${VSCODE_INTELLICODE_CSHARP}%40linux-x64.vsix \
	&& curl -o /tmp/csharp-dev-kit-${VSCODE_CSHARP_DEV_KIT}.vsix -fL https://coder-extensions.s3.amazonaws.com/ms-dotnettools.csdevkit-${VSCODE_CSHARP_DEV_KIT}%40linux-x64.vsix \
	&& curl -o /tmp/redhat-java-${REDHAT_JAVA}.vsix -fL https://coder-extensions.s3.amazonaws.com/redhat.java-${REDHAT_JAVA}%40linux-x64.vsix \
	&& curl -o /tmp/vscode-java-debug-${VSCODE_JAVA_DEBUG}.vsix -fL https://coder-extensions.s3.amazonaws.com/vscjava.vscode-java-debug-${VSCODE_JAVA_DEBUG}.vsix \
	&& curl -o /tmp/vscode-java-test-${VSCODE_JAVA_TEST}.vsix -fL https://coder-extensions.s3.amazonaws.com/vscjava.vscode-java-test-${VSCODE_JAVA_TEST}.vsix \
	&& curl -o /tmp/vscode-maven-${VSCODE_MAVEN}.vsix -fL https://coder-extensions.s3.amazonaws.com/vscjava.vscode-maven-${VSCODE_MAVEN}.vsix  \
	&& curl -o /tmp/vscode-java-dependency-${VSCODE_JAVA_DEP}.vsix -fL https://coder-extensions.s3.amazonaws.com/vscjava.vscode-java-dependency-${VSCODE_JAVA_DEP}.vsix \
	&& curl -o /tmp/vscode-java-pack-${VSCODE_JAVA_PACK}.vsix -fL https://coder-extensions.s3.amazonaws.com/vscjava.vscode-java-pack-${VSCODE_JAVA_PACK}.vsix \
	&& curl -o /tmp/vscode-python-${VSCODE_PYTHON}.vsix -fL https://coder-extensions.s3.amazonaws.com/ms-python.python-${VSCODE_PYTHON}.vsix \
	&& curl -o /tmp/vscode-pylance-${VSCODE_PYLANCE}.vsix-fL https://coder-extensions.s3.amazonaws.com/ms-python.vscode-pylance-${VSCODE_PYLANCE}.vsix \
	&& find /tmp/ -name '*.vsix' -exec code-server --verbose --install-extension {} \; \
	&& rm -rf /tmp/vscode*


# Install VSCode extentions from coder marketplace
RUN \
	code-server --install-extension eamodio.gitlens \
	&& code-server --install-extension mhutchie.git-graph \
	&& code-server --install-extension golang.go \
	&& code-server --install-extension dbaeumer.vscode-eslint \
	&& code-server --install-extension richardwillis.vscode-gradle \
	&& code-server --install-extension redhat.vscode-yaml \
	&& code-server --install-extension alexkrechik.cucumberautocomplete \
	&& rm -rf /root/.local/share/code-server/CachedExtensionVSIXs/*


# Install local scripts
COPY scripts/lvlup-git-setup /usr/bin/lvlup-git-setup
COPY scripts/lvlup-git-sync /usr/bin/lvlup-git-sync
COPY scripts/lvlup-git-reset /usr/bin/lvlup-git-reset
RUN \
	chmod +x /usr/bin/lvlup-git-setup \
	&& chmod +x /usr/bin/lvlup-git-sync \
	&& chmod +x /usr/bin/lvlup-git-reset


# ports and volumes
EXPOSE 9000 9001


# Set entrypoint
ENTRYPOINT ["code-server", "--bind-addr", "0.0.0.0:9000", "--user-data-dir", "/config/data", "--extensions-dir", "/root/.local/share/code-server/extensions", "--disable-telemetry", "--auth", "none", "/config/workspace"]
