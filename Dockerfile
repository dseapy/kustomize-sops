ARG GO_VERSION="1.17"

FROM dseapy/sops-aws-v2:latest as sops

#--------------------------------------------#
#--------Build KSOPS and Kustomize-----------#
#--------------------------------------------#

FROM golang:$GO_VERSION

ARG TARGETPLATFORM
ARG PKG_NAME=ksops

# Match Argo CD's build
ENV GO111MODULE=on

# Define kustomize config location
ENV XDG_CONFIG_HOME=$HOME/.config

# Export templated Go env variables
RUN export GOOS=$(echo ${TARGETPLATFORM} | cut -d / -f1) && \
    export GOARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) && \
    export GOARM=$(echo ${TARGETPLATFORM} | cut -d / -f3 | cut -c2-)

COPY --from=sops /go/src/go.mozilla.org/sops /go/src/go.mozilla.org/sops

WORKDIR /go/src/github.com/viaduct-ai/kustomize-sops

ADD . .

# Perform the build
RUN make install

# Install kustomize via Go
RUN make kustomize

CMD ["kustomize", "version"]
