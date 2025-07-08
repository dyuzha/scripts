docker build -t acme-set-script .

# export CF_Token="ваш токен"
# export CF_Account_ID="ваш_account_id"

docker run -it --rm \
    -e DRY_RUN="true" \
    -e ACME_HOME="/opt/acme" \
    -e DOMAIN="test1.dyuzha.ru" \
  acme-set-script

