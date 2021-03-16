.DEFAULT_GOAL := build

.PHONY: build build-image lint test

build:
	mkdir -p ${name}/build
	@rm -rf ${name}/build/${name}-go.wasm
	tinygo build -o ./${name}/build/${name}-go.wasm \
	-scheduler=none -target=wasi ./${name}/main/main.go

build-image:
	@rm -rf ./${name}/build
	mkdir -p ${name}/build
	docker run -v $(shell pwd):/tmp/build-proxy-wasm-go -w /tmp/build-proxy-wasm-go \
	-e GOPROXY=https://goproxy.cn -it tinygo/tinygo-dev:latest \
	tinygo build -o /tmp/build-proxy-wasm-go/${name}/build/${name}-go.wasm \
	-scheduler=none -target=wasi /tmp/build-proxy-wasm-go/${name}/main/main.go

lint:
	golangci-lint run --build-tags proxytest

test:
	go test -tags=proxytest $(shell go list ./... | grep -v e2e | sed 's/github.com\/zonghaishang\/proxy-wasm-sdk-go/./g')
