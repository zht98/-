#!/bin/bash

LOG_FILE="/opt/oracle_create/run.log"
MAX_LOG_SIZE=524288   # 512 KB
FAIL_COUNT=0

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

clean_log_if_needed() {
    if [ -f "$LOG_FILE" ]; then
        LOG_SIZE=$(stat -c%s "$LOG_FILE")
        if [ "$LOG_SIZE" -gt "$MAX_LOG_SIZE" ]; then
            mv "$LOG_FILE" "${LOG_FILE}.bak"
            echo "" > "$LOG_FILE"
            log "日志文件过大，已自动清理。"
        fi
    fi
}

log "开始循环抢机..."

while true; do
    clean_log_if_needed

    log "开始尝试创建实例（轮询 AD2/AD3/AD1）..."

    bash /opt/oracle_create/create_instance.sh
    RESULT=$?

    if [ $RESULT -eq 0 ]; then
        log "抢机成功，退出循环。"
        exit 0
    fi

    FAIL_COUNT=$((FAIL_COUNT + 1))
    log "创建失败（累计失败次数：$FAIL_COUNT），等待 10 秒后重试..."

    sleep 10
done