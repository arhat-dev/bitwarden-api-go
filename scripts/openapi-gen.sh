#!/bin/sh

# Generates api objects

TARGETS="internal public"

for target in ${TARGETS}; do
  mkdir -p "/app/bw${target}"
  oapi-codegen \
    -package "bw${target}" \
    -o "/app/bw${target}/openapi.go" \
    -generate types,client \
    "/app/api.${target}.json"
done
