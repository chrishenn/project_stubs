FROM nvidia/cuda:12.9.1-cudnn-devel-ubuntu24.04

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV UV_LINK_MODE=copy

WORKDIR /workspace

# mise
#RUN apt-get update  \
#    && apt-get -y --no-install-recommends install sudo curl git ca-certificates build-essential \
#    && rm -rf /var/lib/apt/lists/*
#
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]
#ENV MISE_DATA_DIR="/mise"
#ENV MISE_CONFIG_DIR="/mise"
#ENV MISE_CACHE_DIR="/mise/cache"
#ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
#ENV PATH="/mise/shims:$PATH"
#
#RUN curl https://mise.run | sh
