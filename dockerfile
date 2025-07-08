# Dockerfile
FROM bash:5.3

WORKDIR /app
COPY ./bash/acme-set.sh .

RUN chmod +x /app/acme-set.sh

ENTRYPOINT ["bash"]
CMD ["-i"]
