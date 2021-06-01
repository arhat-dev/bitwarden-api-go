FROM golang:1.16 AS builder

# install oapi-codegen
COPY scripts/install.sh /install-tools.sh
RUN bash /install-tools.sh

COPY openapi/internal.json /app/
COPY openapi/public.json /app/

RUN TARGETS="internal public" && \
    for target in ${TARGETS}; do \
      mkdir -p "/app/bw${target}" && \
      oapi-codegen \
        -package "bw${target}" \
        -o "/app/bw${target}/openapi.go" \
        -generate types,client \
        "/app/${target}.json" ; \
    done

FROM scratch

COPY --from=builder /app/bwinternal /bwinternal
COPY --from=builder /app/bwpublic /bwpublic
