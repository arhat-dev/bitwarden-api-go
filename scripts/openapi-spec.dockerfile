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

COPY scripts/dotnet-gen.sh /dotnet-gen.sh
RUN sh /dotnet-gen.sh

FROM scratch

COPY --from=generator /output /
