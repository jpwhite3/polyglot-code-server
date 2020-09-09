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
	p7zip-full p7zip-rar \
	dirmngr \
	gpg gpg-agent \
	# CLEAN UP
 	&& apt-get purge --auto-remove -y \
	&& apt-get clean \
 	&& rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*


ENV TZ='America/New_York'
RUN apt-get update --no-install-recommends \
	&& DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
	# Unbiquitous CLI tools
	jq \
	vim \
	less \
	# ZSHELL LATEST
	zsh \
	fonts-powerline \
	# PYTHON LATEST
	python3-pip python3-dev \
	# JAVA LATEST
	openjdk-11-jdk-headless maven gradle \
	# CLEAN UP
 	&& apt-get purge --auto-remove -y \
	&& apt-get clean \
 	&& rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*


# Install zshell configuration
RUN zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
  && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k \
  && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /root/.zshrc \
  && sed -i 's/# DISABLE_AUTO_UPDATE="true"/DISABLE_AUTO_UPDATE="true"/' /root/.zshrc \
  && sed -i 's/export ZSH="\/config\/.oh-my-zsh"/export ZSH="~\/.oh-my-zsh"/' /root/.zshrc


# NODE LATEST
RUN apt-get update --no-install-recommends \
	&& DEBIAN_FRONTEND="noninteractive" && curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
    && apt-get install -y nodejs \
	# CLEAN UP
 	&& apt-get purge --auto-remove -y \
	&& apt-get clean \
 	&& rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/* \
	# smoke tests
    && node --version \
    && npm --version \
	&& npm install -g yarn \
	&& yarn --version


# PYTHON LATEST
RUN cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip \
  # smoke tests
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
	\
# https://github.com/golang/go/issues/14739#issuecomment-324767697
	export GNUPGHOME="$(mktemp -d)"; \
# https://www.google.com/linuxrepositories/
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC EC91 7721 F63B D38B 4796'; \
	gpg --batch --verify go.tgz.asc go.tgz; \
	rm -rf "$GNUPGHOME" go.tgz.asc; \
	\
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	if [ "$arch" = 'src' ]; then \
		savedAptMark="$(apt-mark showmanual)"; \
		apt-get update; \
		apt-get install -y --no-install-recommends golang-go; \
		\
		goEnv="$(go env | sed -rn -e '/^GO(OS|ARCH|ARM|386)=/s//export \0/p')"; \
		eval "$goEnv"; \
		[ -n "$GOOS" ]; \
		[ -n "$GOARCH" ]; \
		( \
			cd /usr/local/go/src; \
			./make.bash; \
		); \
		\
		apt-mark auto '.*' > /dev/null; \
		apt-mark manual $savedAptMark > /dev/null; \
		apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
		rm -rf /var/lib/apt/lists/*; \
		\
# pre-compile the standard library, just like the official binary release tarballs do
		go install std; \
# go install: -race is only supported on linux/amd64, linux/ppc64le, linux/arm64, freebsd/amd64, netbsd/amd64, darwin/amd64 and windows/amd64
#		go install -race std; \
		\
# remove a few intermediate / bootstrapping files the official binary release tarballs do not contain
		rm -rf \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
		; \
	fi; \
	\
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


# add local files
COPY /root /


# ports and volumes
EXPOSE 8443


WORKDIR /root
