FROM ubuntu:latest


RUN apt-get update --no-install-recommends \
	&& DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
	#**** install runtime dependencies ****
	git \
	curl \
	wget \
	sudo \
	make \
	apt-utils \
	g++ \
	gcc \
	libc6-dev \
	xz-utils \
	p7zip-full \
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
	&& rm -f packages-microsoft-prod.deb \
	&& curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -


ENV TZ='America/New_York'
RUN apt-get update --no-install-recommends \
	&& DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
	# Unbiquitous CLI tools
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
	nodejs \
	# CLEAN UP
 	&& apt-get purge --auto-remove -y \
	&& apt-get clean \
 	&& rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*


# Install zshell configuration
RUN zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
  #&& git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k \
  #&& sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /root/.zshrc \
  && sed -i 's/# DISABLE_AUTO_UPDATE="true"/DISABLE_AUTO_UPDATE="true"/' /root/.zshrc \
  && sed -i 's/export ZSH="\/config\/.oh-my-zsh"/export ZSH="~\/.oh-my-zsh"/' /root/.zshrc



# NODE SETUP
RUN node --version \
    && npm --version \
	&& npm install -g yarn \
	&& yarn --version


# PYTHON SETUP
RUN cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip setuptools wheel \
  && python3 --version \
  && pip --version


ENV PATH /usr/local/go/bin:$PATH
ENV GOLANG_VERSION 1.15.1
RUN set -eux; \
	\
	arch='linux-amd64'; \
	url="https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz"; \
	sha256='70ac0dbf60a8ee9236f337ed0daa7a4c3b98f6186d4497826f68e97c0c0413f6'; \
	wget -O go.tgz.asc "$url.asc" --progress=dot:giga; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum --strict --check -; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC EC91 7721 F63B D38B 4796'; \
	gpg --batch --verify go.tgz.asc go.tgz; \
	rm -rf "$GNUPGHOME" go.tgz.asc; \
	\
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"


# CODER LATEST
RUN \
 mkdir -p /config && mkdir -p /data; \
 echo "**** install code-server ****" && \
 if [ -z ${CODE_RELEASE+x} ]; then \
	CODE_RELEASE=$(curl -sX GET "https://api.github.com/repos/cdr/code-server/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 CODE_VERSION=$(echo "$CODE_RELEASE" | awk '{print substr($1,2); }') && \
 yarn --production --frozen-lockfile global add code-server@"$CODE_VERSION" && \
 yarn cache clean && \
 echo "**** clean up ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*


# ports and volumes
EXPOSE 9000
EXPOSE 8443
EXPOSE 8080
EXPOSE 8000


WORKDIR /root


ENTRYPOINT /usr/local/bin/code-server \
	--bind-addr 0.0.0.0:9000 \
	--user-data-dir /config/data \
	--extensions-dir /config/extensions \
	--disable-telemetry \
	--auth "none" \
	/config/workspace