#!/bin/sh

VERSION="1.0.0"
TARGET_DOMAIN="api.telegram.org"
REPO_URL="https://raw.githubusercontent.com/FoRKel-c/NSHIFT-autoupdate-sub/main"

# 1. Проверка работы процесса NetShift
if ! pgrep -f "/usr/bin/netshift" > /dev/null 2>&1 && ! pgrep -x "netshift" > /dev/null 2>&1; then
    exit 0
fi

# 2. Проверка наличия новой версии на GitHub
REMOTE_VERSION=$(wget -qO- --timeout=3 "$REPO_URL/version.txt" 2>/dev/null)
if [ -n "$REMOTE_VERSION" ] && [ "$REMOTE_VERSION" != "$VERSION" ]; then
    logger -t netshift_watchdog "Обнаружена новая версия ($REMOTE_VERSION). Обновление скрипта..."
    wget -qO /usr/bin/netshift_watchdog.sh "$REPO_URL/netshift_watchdog.sh" && chmod +x /usr/bin/netshift_watchdog.sh
    exit 0
fi

# 3. Проверка доступности выбранного домена
if ! wget -q --spider --timeout=5 "https://$TARGET_DOMAIN" > /dev/null 2>&1; then
    sleep 5
    # Повторный запрос для исключения случайного сбоя
    if ! wget -q --spider --timeout=5 "https://$TARGET_DOMAIN" > /dev/null 2>&1; then
        logger -t netshift_watchdog "Домен $TARGET_DOMAIN недоступен. Обновляем подписку NetShift..."
        /usr/bin/netshift subscription_update
    fi
fi