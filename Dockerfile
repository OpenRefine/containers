FROM scratch AS sources
ARG VERSION=master
ADD https://github.com/OpenRefine/OpenRefine.git#$VERSION /opt/openrefine

FROM registry.opensuse.org/opensuse/bci/openjdk-devel:21 AS backend
WORKDIR /opt/openrefine
COPY --from=sources /opt/openrefine .
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B process-resources compile test-compile

FROM registry.opensuse.org/opensuse/bci/nodejs:22 AS frontend
WORKDIR /opt/openrefine/main/webapp
COPY --from=sources /opt/openrefine/main/webapp .
RUN --mount=type=cache,target=/root/.npm \
    npm install

FROM registry.opensuse.org/opensuse/bci/openjdk:21
# which is needed as command by old versions:
# - https://github.com/OpenRefine/OpenRefine/pull/5332
RUN zypper --non-interactive install gettext-tools which
WORKDIR /opt/openrefine
COPY --from=backend /opt/openrefine/server server/
COPY --from=backend /opt/openrefine/main main/
COPY --from=frontend /opt/openrefine/main/webapp/modules main/webapp/modules
COPY --from=backend /opt/openrefine/refine .
COPY entrypoint.sh refine.ini.template ./

EXPOSE 3333/TCP
ENV REFINE_MEMORY=1400M
ENV REFINE_MIN_MEMORY=1400M

HEALTHCHECK --start-period=10s CMD curl -sSf -o /dev/null http://localhost:3333

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
CMD ["/opt/openrefine/refine", "-i", "0.0.0.0", "-d", "/workspace", "run"]
