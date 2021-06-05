#!/bin/sh

set -ex

OUTPUT_DIR="/output"

mkdir -p "${OUTPUT_DIR}"

# build essential files
dotnet tool restore

ENDPOINTS="Api"
# ENDPOINTS="Api Events Icons Identity Notifications"

for e in ${ENDPOINTS}; do
  dotnet restore "/app/src/${e}/${e}.csproj"

  dotnet clean "/app/src/${e}/${e}.csproj" \
    -c "Release" -o "/app/src/${e}/obj/build-output/publish/${e}"

  dotnet publish "/app/src/${e}/${e}.csproj" \
    -c "Release" -o "/app/src/${e}/obj/build-output/publish/${e}"
done

# NORMAL_ENDPOINT="Events Icons Identity Notifications"

# for e in ${NORMAL_ENDPOINT}; do
#   dotnet swagger tofile \
#     --output "/output/${e}.json" \
#     --host https://bitwarden.com \
#     "/app/src/${e}/obj/build-output/publish/${e}/${e}.dll" "${e}"
# done

TARGETS="internal public"
for target in ${TARGETS}; do
  dotnet swagger tofile \
    --output "/output/Api.${target}.json" \
    --host "https://api.bitwarden.com" \
    "/app/src/Api/obj/build-output/publish/Api/Api.dll" "${target}"
done
