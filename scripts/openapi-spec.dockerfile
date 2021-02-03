FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS generator

ENV DOTNET_CLI_TELEMETRY_OPTOUT "true"

RUN apt update && \
    apt install -y git wget apt-transport-https

# add ms apt repo
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb \
      -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb

# install dotnet sdk for building
RUN apt update && \
    apt install -y dotnet-sdk-3.1 dotnet-sdk-2.1

ARG BW_SRV_VER
RUN git clone --depth 1 --branch ${BW_SRV_VER} \
      https://github.com/bitwarden/server.git /app

WORKDIR /app

# build essential files
# build.sh will fail due to lack of docker-cli, but we can just ignore it
RUN dotnet tool restore && \
    bash build.sh || true

# generate openapi json spec
RUN TARGETS="internal public" && \
    for target in ${TARGETS}; do \
      dotnet swagger tofile \
        --output ./${target}.json \
        --host https://api.bitwarden.com \
        ./src/Api/obj/Docker/publish/Api/Api.dll ${target} ; \
    done

FROM scratch

COPY --from=generator /app/internal.json /
COPY --from=generator /app/public.json /
