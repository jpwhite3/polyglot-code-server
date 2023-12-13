FROM ghcr.io/jpwhite3/polyglot:latest

# CODER Installation
ENV CODER_VERSION 4.19.1
RUN \
	mkdir -p /config/data /config/workspace \
	&& curl -fOL https://github.com/cdr/code-server/releases/download/v${CODER_VERSION}/code-server_${CODER_VERSION}_amd64.deb \
	&& sudo dpkg -i code-server_${CODER_VERSION}_amd64.deb

# Install VSCode extentions from coder marketplace
RUN \
	code-server --install-extension eamodio.gitlens \
	&& code-server --install-extension mhutchie.git-graph \
	&& code-server --install-extension golang.go \
	&& code-server --install-extension dbaeumer.vscode-eslint \
	&& code-server --install-extension redhat.vscode-yaml \
	&& rm -rf /root/.local/share/code-server/CachedExtensionVSIXs/*

# Zsh Configuration
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# ports and volumes
EXPOSE 9000 9001

# Set entrypoint
ENTRYPOINT ["code-server", "--bind-addr", "0.0.0.0:9000", "--user-data-dir", "/config/data", "--extensions-dir", "/root/.local/share/code-server/extensions", "--disable-telemetry", "--auth", "none", "/config/workspace"]
