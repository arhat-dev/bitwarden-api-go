FROM golang:1.16 AS builder

# install oapi-codegen
COPY scripts/install.sh /install-tools.sh
RUN bash /install-tools.sh

COPY openapi/*.json /app/
COPY scripts/openapi-gen.sh /openapi-gen.sh

RUN sh /openapi-gen.sh

FROM scratch

COPY --from=builder /app/bwinternal /bwinternal
COPY --from=builder /app/bwpublic /bwpublic
