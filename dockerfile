# Dockerfile
FROM bash:5.3

RUN apk add --no-cache curl

WORKDIR /app
COPY ./bash/acme-set.sh .

RUN chmod +x /app/acme-set.sh

ENTRYPOINT ["bash"]
CMD ["-i"]
