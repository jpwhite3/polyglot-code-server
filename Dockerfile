FROM ghcr.io/jpwhite3/polyglot:latest

# CODER Installation
ENV CODER_VERSION 4.9.0
RUN \
	mkdir -p /config/data /config/workspace \
	&& curl -fOL https://github.com/cdr/code-server/releases/download/v${CODER_VERSION}/code-server_${CODER_VERSION}_amd64.deb \
	&& sudo dpkg -i code-server_${CODER_VERSION}_amd64.deb

# Install VSCode extentions
RUN \
	code-server --install-extension eamodio.gitlens \
	&& code-server --install-extension mhutchie.git-graph \
	&& code-server --install-extension ms-python.python \
	&& code-server --install-extension LittleFoxTeam.vscode-python-test-adapter \
	&& code-server --install-extension golang.go \
	&& code-server --install-extension dbaeumer.vscode-eslint \
	&& code-server --install-extension vscjava.vscode-java-pack \
	&& code-server --install-extension vscjava.vscode-java-debug \
	&& code-server --install-extension richardwillis.vscode-gradle \
	&& code-server --install-extension patcx.vscode-nuget-gallery \
	&& code-server --install-extension redhat.vscode-yaml \
	&& code-server --install-extension bierner.markdown-mermaid \
	&& code-server --install-extension formulahendry.code-runner \
	&& code-server --install-extension hbenl.vscode-test-explorer \
	&& code-server --install-extension hbenl.vscode-mocha-test-adapter \
	&& code-server --install-extension kavod-io.vscode-jest-test-adapter \
	&& code-server --install-extension hbenl.vscode-jasmine-test-adapter \
	&& code-server --install-extension ethan-reesor.vscode-go-test-adapter \
	&& code-server --install-extension alexkrechik.cucumberautocomplete \
	&& code-server --install-extension hbenl.test-adapter-converter \
	&& rm -rf /root/.local/share/code-server/CachedExtensionVSIXs/*

# ports and volumes
EXPOSE 9000 9001

# Set entrypoint
ENTRYPOINT ["code-server", "--bind-addr", "0.0.0.0:9000", "--user-data-dir", "/config/data", "--extensions-dir", "/root/.local/share/code-server/extensions", "--disable-telemetry", "--auth", "none", "/config/workspace"]
