FRONTEND_DIR = ./web
BACKEND_DIR = .

NAME=new-api
DISTDIR=dist
WEBDIR=web
VERSION=$(shell git describe --tags || echo "dev")
GO := /usr/local/go/bin/go
export GOPROXY=https://goproxy.cn,direct
GOBUILD=$(GO) build -ldflags "-s -w -extldflags '-static'"
IMAGE="registry.tydic.com/ai-studio/new-api:20250310"

.PHONY: all build-frontend start-backend

all: build-frontend start-backend

build-frontend:
	@echo "Building frontend..."
	@cd $(FRONTEND_DIR) && bun install && DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat VERSION) bun run build

start-backend:
	@echo "Starting backend dev server..."
	@cd $(BACKEND_DIR) && go run main.go &

all: new-api

web: $(WEBDIR)/build

$(WEBDIR)/build:
	cd $(WEBDIR) && burn run build && cp -rp dist $(DISTDIR)/llmapi

new-api: web
	$(GOBUILD) -o $(DISTDIR)/$(NAME)

clean:
	rm -rf $WEBDIR/$(DISTDIR)

image:
	docker build --no-cache -t $(IMAGE) -f Dockerfile-tydic .

push: push
	docker push $(IMAGE)