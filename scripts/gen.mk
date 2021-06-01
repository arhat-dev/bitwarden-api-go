# Copyright 2021 The arhat.dev Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# v1.41.3 seems broken
BITWARDEN_SERVER_VERSION := master

gen.spec:
	docker build \
		-t bitwarden-openapi-spec:${BITWARDEN_SERVER_VERSION} \
		--build-arg BW_SRV_VER=${BITWARDEN_SERVER_VERSION} \
		-f scripts/openapi-spec.dockerfile .

	mkdir -p openapi
	rm -rf openapi/*.json
	sh scripts/docker-copy.sh \
		bitwarden-openapi-spec:${BITWARDEN_SERVER_VERSION} \
		/internal.json openapi/internal.json
	sh scripts/docker-copy.sh \
		bitwarden-openapi-spec:${BITWARDEN_SERVER_VERSION} \
		/public.json openapi/public.json

gen.go:
	docker build \
		-t bitwarden-openapi-go:${BITWARDEN_SERVER_VERSION} \
		-f scripts/openapi-go.dockerfile .

	rm -rf bwinternal bwpublic
	sh scripts/docker-copy.sh \
		bitwarden-openapi-go:${BITWARDEN_SERVER_VERSION} \
		/bwinternal bwinternal
	sh scripts/docker-copy.sh \
		bitwarden-openapi-go:${BITWARDEN_SERVER_VERSION} \
		/bwpublic bwpublic
	GOOS=$(shell go env GOHOSTOS) GOARCH=$(shell go env GOHOSTARCH) \
		go run ./scripts/fix-openapi-go.go
