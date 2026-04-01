ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install bash and jq for Home Assistant app options parsing
RUN apk add --no-cache bash jq

# Copy app run script
COPY run.sh /app/run.sh
RUN chmod a+x /app/run.sh

ENTRYPOINT []
CMD ["/app/run.sh"]
