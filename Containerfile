FROM registry.altlinux.org/sisyphus/base:latest AS altbase

ARG YEAR=""
ARG MONTH=""
ARG DAY=""

ENV REPO_YEAR=$YEAR
ENV REPO_MONTH=$MONTH
ENV REPO_DAY=$DAY

# Выполняем все шаги в одном RUN для минимизации слоёв
RUN --mount=type=bind,source=./src,target=/src \
    /src/main.sh

# Стадия 2: Переход к пустому образу
FROM scratch

# Копируем всё содержимое из предыдущего образа
COPY --from=altbase / /

WORKDIR /

# Помечаем образ как bootc совместимый
LABEL containers.bootc=1

CMD ["/sbin/init"]
