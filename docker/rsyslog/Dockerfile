FROM alpine:3.12.2
RUN apk add --no-cache rsyslog
COPY rsyslog.conf /etc
VOLUME /var/log
ENTRYPOINT ["rsyslogd", "-n", "-f", "/etc/rsyslog.conf"]