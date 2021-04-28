FROM golang:1.15.8-alpine

# ENV:
# RTLAMR_FORMAT=json
# RTLAMR_FILTERID=000000000
# COLLECT_LOGLEVEL=Debug
# COLLECT_INFLUXDB_DRYRUN=true
# COLLECT_INFLUXDB_HOSTNAME=https://localhost:8086/
# COLLECT_INFLUXDB_BUCKET=database/retention_policy
# COLLECT_INFLUXDB_MEASUREMENT=utilities
# COLLECT_STRICTIDM=1
# RTLAMR_MSGTYPE=scm,scm+
# RTLAMR_FORMAT=json
# RTLAMR_FILTERID=000000000

RUN apk add --no-cache git rtl-sdr

RUN go get -v github.com/bemasher/rtlamr
RUN go get -v github.com/bemasher/rtlamr-collect

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]