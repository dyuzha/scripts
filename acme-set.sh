#!/bin/bash

ACME_HOME="/opt/acme.sh"
CF_Token="ваш_токен"
DOMAIN="example.com"
DRY_RUN=false # Для теста без реального выпуска сертификатов


# Проверка зависимостей
if ! command -v curl &> /dev/null; then
  echo "Ошибка: curl не установлен" >&2
  exit 1
fi


# Подготовка окружения
echo "Настройка окружения в ${ACME_HOME}..."
mkdir -p "$ACME_HOME" || { echo "Не удалось создать ${ACME_HOME}" >&2; exit 1; }
chown "$USER:$USER" "$ACME_HOME"



# Установить acme.sh
echo "Установка acme.sh..."
if ! curl https://get.acme.sh | sh -s -- --install \
                --home $ACME_HOME \
                --config-home $ACME_HOME \
                --cert-home $ACME_HOME \
                --accountkey $ACME_HOME/account.key \
                # --accountemail "не задан" \
                # --useragent "acme.sh" \
                --accountconf $ACME_HOME/account.conf; then
  echo "Ошибка установки acme.sh" >&2
  exit 1
fi


# Установить Let's Encrypt в качестве CA
echo "Настройка Let's Encrypt..."
acme.sh --set-default-ca --server letsencrypt


# Проверка
echo "Проверка установки:"
"$ACME_HOME/acme.sh" --info



# Тестовый выпуск сертификата (staging)
echo "Пробный выпуск staging сертификата..."
if ! acme.sh --issue --dns dns_cf \
          -d "$DOMAIN" \
          -d "*.$DOMAIN" \
          --keylength ec-384 \
          --staging; then
  echo "Ошибка тестового выпуска сертификата" >&2
  exit 1
fi


# Выпуск production сертификата
if [ "$DRY_RUN" = false ]; then
  echo "Выпуск production сертификата..."
  if ! acme.sh --issue --dns dns_cf \
          -d "$DOMAIN" \
          -d "*.$DOMAIN" \
          --keylength ec-384; then
  echo "Ошибка выпуска сертификата" >&2
  exit 1
  fi
fi


# Итоговая информация
echo -e "\nСертификаты успешно выпущены:"
"$ACME_HOME/acme.sh" --list

echo -e "\nГотово! Сертификаты находятся в:"
find "$ACME_HOME" -name "${DOMAIN}*" -type d
