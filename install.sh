#!/bin/sh

REPO_URL="https://raw.githubusercontent.com/FoRKel-c/NSHIFT-autoupdate-sub/main"

echo "=========================================="
echo "  Установка / Настройка NetShift Watchdog  "
echo "=========================================="
echo ""

# 1. Выбор домена
echo "Выберите домен для проверки доступности сети:"
echo "1) Telegram API (api.telegram.org) [По умолчанию]"
echo "2) YouTube (youtube.com)"
echo "3) Google (google.com)"
echo "4) Discord (discord.com)"
echo "5) Cloudflare (cloudflare.com)"
echo "6) Указать свой кастомный домен"
printf "Введите номер [1-6]: "
read CHOICE

case "$CHOICE" in
    2) DOMAIN="youtube.com" ;;
    3) DOMAIN="google.com" ;;
    4) DOMAIN="discord.com" ;;
    5) DOMAIN="cloudflare.com" ;;
    6)
        printf "Введите ваш домен (например, google.com): "
        read INPUT_DOMAIN
        # 1. Очищаем от протоколов, слэшей и портов
        CLEAN_DOMAIN=$(echo "$INPUT_DOMAIN" | sed -e 's|^[^/]*//||' -e 's|/.*||' -e 's|:.*||')
        # 2. Оставляем ТОЛЬКО латиницу, цифры, точки и дефисы (удаляем спецсимволы и \r)
        DOMAIN=$(echo "$CLEAN_DOMAIN" | tr -cd 'a-zA-Z0-9.-')
        
        if [ -z "$DOMAIN" ]; then
            echo "Домен не введён. Устанавливаем по умолчанию: api.telegram.org"
            DOMAIN="api.telegram.org"
        fi
        ;;
    *) DOMAIN="api.telegram.org" ;;
esac

# 2. Выбор интервала
echo ""
printf "Введите интервал проверки в минутах [по умолчанию: 5]: "
read INPUT_INTERVAL

# Очищаем интервал от любых символов, кроме цифр
CLEAN_INTERVAL=$(echo "$INPUT_INTERVAL" | tr -cd '0-9')
INTERVAL="${CLEAN_INTERVAL:-5}"

echo ""
echo "Параметры установки:"
echo " - Проверяемый домен: $DOMAIN"
echo " - Частота проверки: каждые $INTERVAL мин."
echo ""

# 3. Установка
rm -f /usr/bin/netshift_watchdog.sh 2>/dev/null

echo "Загрузка актуальной версии с GitHub..."
wget -qO /usr/bin/netshift_watchdog.sh "$REPO_URL/netshift_watchdog.sh"
chmod +x /usr/bin/netshift_watchdog.sh

# Удаление возможного остаточного мусора из скрипта
sed -i 's/\r$//' /usr/bin/netshift_watchdog.sh

# Подстановка выбранного домена и URL репозитория
sed -i "s/TARGET_DOMAIN=\".*\"/TARGET_DOMAIN=\"$DOMAIN\"/" /usr/bin/netshift_watchdog.sh
sed -i "s|REPO_URL=\".*\"|REPO_URL=\"$REPO_URL\"|" /usr/bin/netshift_watchdog.sh

# Настройка Cron
sed -i '/netshift_watchdog.sh/d' /etc/crontabs/root 2>/dev/null
echo "*/$INTERVAL * * * * /usr/bin/netshift_watchdog.sh" >> /etc/crontabs/root
/etc/init.d/cron restart

echo "=== Установка успешно завершена! ==="