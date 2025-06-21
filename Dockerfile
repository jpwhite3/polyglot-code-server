FROM ghcr.io/jpwhite3/polyglot:latest

# CODER Installation
ENV CODER_VERSION 4.101.1
RUN \
	mkdir -p /config/data /config/workspace \
	&& curl -fOL https://github.com/cdr/code-server/releases/download/v${CODER_VERSION}/code-server_${CODER_VERSION}_amd64.deb \
	&& sudo dpkg -i code-server_${CODER_VERSION}_amd64.deb

# Install VSCode extentions from coder marketplace
RUN \
	code-server --install-extension eamodio.gitlens \
	&& code-server --install-extension mhutchie.git-graph \
	&& code-server --install-extension ms-python.python \
	&& code-server --install-extension rebornix.ruby \
	&& code-server --install-extension golang.go \
	&& code-server --install-extension dbaeumer.vscode-eslint \
	&& code-server --install-extension redhat.vscode-yaml \
	&& code-server --install-extension oderwat.indent-rainbow \
	&& code-server --install-extension rust-lang.rust \
	&& code-server --install-extension redhat.java \
	&& code-server --install-extension ms-azuretools.vscode-docker \
	&& rm -rf /root/.local/share/code-server/CachedExtensionVSIXs/*

# ports and volumes
EXPOSE 9000 9001

# Set entrypoint
ENTRYPOINT ["code-server", "--bind-addr", "0.0.0.0:9000", "--user-data-dir", "/config/data", "--extensions-dir", "/root/.local/share/code-server/extensions", "--disable-telemetry", "--auth", "none", "/config/workspace"]
