# syntax=docker/dockerfile:1

# ---------- build ----------
# The project pins Flutter 3.44.8 (Dart ^3.12.2). Prebuilt community images lag
# that version, so we install the exact SDK from the Flutter git repo — Flutter
# "installs" by checking out its repo at a version tag.
#
# API_HOST is baked into the web bundle at build time (Flutter reads it via
# String.fromEnvironment). It must be an address the USER'S BROWSER can reach —
# i.e. the backend port published to the host (localhost:8080), not the compose
# service name.
FROM debian:bookworm-slim AS build

ARG FLUTTER_VERSION=3.44.8
ARG API_HOST=localhost:8080

RUN apt-get update && apt-get install -y --no-install-recommends \
      git curl unzip xz-utils zip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git /flutter && \
    git config --global --add safe.directory /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter --version && flutter config --enable-web && flutter precache --web

WORKDIR /app
# cache deps first
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
# then the rest of the source
COPY . .
RUN flutter build web --release --dart-define=API_HOST=${API_HOST}

# ---------- runtime ----------
FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
