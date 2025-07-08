docker build -t acme-set-script .

docker run -it --rm \
    -e DRY_RUN="true" \
    -e ACME_HOME="/opt/acme" \
    -e DOMAIN="test1.dyuzha.ru" \
  acme-script
