#!/bin/bash

# Экспорт переменных для Cloudflare
export CF_Token="ваш токен"
# export CF_Account_ID="ваш_account_id"

ACME_HOME="/opt/acme.sh"
DOMAIN="srv.dyuzha.com"
DRY_RUN=true    # Тестовый режим (true - staging, false - production)


# Проверка зависимостей
echo "Проверка необходимых компонентов..."
if ! command -v curl &> /dev/null; then
  echo "Ошибка: curl не установлен. Установите его командой:"
  echo "  apt-get install curl || yum install curl"
  exit 1
fi

# Подготовка окружения
echo "Подготовка рабочей директории ${ACME_HOME}..."
mkdir -p "$ACME_HOME" || {
  echo "Не удалось создать директорию ${ACME_HOME}"
  echo "Попробуйте запустить с sudo или изменить ACME_HOME"
  exit 1
}
chown "$USER:$USER" "$ACME_HOME"

# Установка acme.sh
echo "Устанавливаем acme.sh в ${ACME_HOME}..."
if ! curl https://get.acme.sh | sh -s --install \
  --home "$ACME_HOME" \
  --config-home "$ACME_HOME" \
  --cert-home "$ACME_HOME" \
  --accountkey "$ACME_HOME/account.key" \
  --accountconf "$ACME_HOME/account.conf"; then
  echo "Ошибка при установке acme.sh"
  exit 1
fi

# Добавляем acme.sh в PATH
echo "Добавляем acme.sh в PATH..."
export PATH="$ACME_HOME:$PATH"
source ~/.bashrc 2>/dev/null || source ~/.zshrc 2>/dev/null

# Настройка Let's Encrypt
echo "Настраиваем Let's Encrypt как CA по умолчанию..."
"$ACME_HOME/acme.sh" --set-default-ca --server letsencrypt

# Проверка установки
echo "Проверяем установку..."
"$ACME_HOME/acme.sh" --version || {
  echo "acme.sh не работает после установки"
  exit 1
}

# Тестовый выпуск сертификата (staging)
echo "Пробуем выпустить тестовый сертификат (staging)..."
if ! "$ACME_HOME/acme.sh" --issue --dns dns_cf \
  -d "$DOMAIN" \
  -d "*.$DOMAIN" \
  --keylength ec-384 \
  --staging; then
  echo "Ошибка при тестовом выпуске сертификата"
  exit 1
fi

# Выпуск production сертификата (если DRY_RUN=false)
if [ "$DRY_RUN" = false ]; then
  echo "Выпускаем production сертификат..."
  if ! "$ACME_HOME/acme.sh" --issue --dns dns_cf \
    -d "$DOMAIN" \
    -d "*.$DOMAIN" \
    --keylength ec-384; then
    echo "Ошибка при выпуске production сертификата"
    exit 1
  fi
else
  echo "Режим DRY_RUN=true - production сертификат не выпускается"
fi

# Итоговая информация
echo -e "\nРезультат:"
"$ACME_HOME/acme.sh" --list

echo -e "\nСертификаты находятся в:"
find "$ACME_HOME" -name "${DOMAIN}*" -type d

echo -e "\nГотово! Для автоматического обновления сертификатов ничего дополнительно делать не нужно - acme.sh настроит автоматическое обновление."
