ARG VARIANT="3.0"
FROM mcr.microsoft.com/vscode/devcontainers/ruby:0-${VARIANT}

ARG DIRENV_VERSION=2.32.1

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends jq vim direnv yamllint python3-pip python3-setuptools git less python3-dev

COPY requirements.txt /tmp/
RUN pip3 install --requirement /tmp/requirements.txt

RUN curl --location-trusted https://github.com/direnv/direnv/releases/download/v${DIRENV_VERSION}/direnv.linux-amd64 --output /usr/local/bin/direnv --silent \
    && chmod +x /usr/local/bin/direnv

RUN echo -e "setlocal noautoindent\nsetlocal nocindent\nsetlocal nosmartindent\nsetlocal indentexpr=\"\n" > /home/${USER}/.vimrc \
    && echo 'alias awsume="source awsume"' >> /home/${USER}/.bashrc \
    && echo 'eval "$(direnv hook bash)"' >> /home/${USER}/.bashrc \
    && mkdir /home/${USER}/.aws
