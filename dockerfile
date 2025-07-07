# Dockerfile
FROM bash:5.2

# Устанавливаем Bats и другие утилиты
RUN apk add --no-cache bats coreutils tar gzip

WORKDIR /app
COPY . .

# Запуск тестов при старте контейнера
CMD ["bats", "tests/"]
