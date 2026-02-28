#!/bin/bash

log() {
    echo "$(date '+%F %T') $1" | tee -a "$LOG_FILE"
}

check_oci() {
    if ! command -v oci >/dev/null 2>&1; then
        log "错误：OCI CLI 未安装或不可用。"
        exit 1
    fi
}