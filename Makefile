.PHONY: clean build run
.DEFAULT_GOAL := build

clean:
	docker image prune -af

clean-all:
	docker system prune -f

run:
	docker run -it -p 9000:9000 polyglot-code-server:latest

build:
	export VERSION=`cat VERSION` && \
	docker build . -t polyglot-code-server:latest -t polyglot-code-server:$$VERSION --platform linux/amd64 --progress=plain