FROM debian:13 AS base

RUN apt update && apt upgrade -y

RUN apt install -y curl zip nodejs npm

FROM base

RUN useradd -m -s /bin/bash coder -d /projects
USER coder
WORKDIR /projects

RUN curl -fsSL https://bun.sh/install | bash
ENV BUN_INSTALL=/projects/.bun
ENV PATH=$BUN_INSTALL/bin:$PATH
RUN bun install -g opencode-ai

ENV OPENCODE_SERVER_HOSTNAME=0.0.0.0
ENV OPENCODE_SERVER_PORT=4096
ENV OPENCODE_SERVER_MDNS=false
ENV OPENCODE_SERVER_CORS=[]

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh"]

