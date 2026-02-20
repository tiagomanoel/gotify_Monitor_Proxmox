#!/usr/bin/env bash

# Diretório real do script (funciona via cron, symlink, etc.)
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

ENV_FILE="$SCRIPT_DIR/gotify.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Arquivo gotify.env não encontrado em $ENV_FILE"
    exit 1
fi

# Carrega variáveis do env
set -o allexport
source "$ENV_FILE"
set +o allexport


TITLE="Status do Servidor"
HOST=$(hostname)
UPTIME=$(uptime -p)

# ================= CPU =================
CPU_MODEL=$(lscpu | grep "Model name" | sed 's/Model name:\s*//')
CPU_CORES=$(nproc)

CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {print int(100 - $8)}')

# Temperatura (funciona em Intel/AMD se existir thermal_zone0)
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    CPU_TEMP=$(awk '{print int($1/1000)}' /sys/class/thermal/thermal_zone0/temp)
    CPU_TEMP="${CPU_TEMP}°C"
else
    CPU_TEMP="Não disponível"
fi

# ================= MEMÓRIA =================
read MEM_TOTAL MEM_USED MEM_AVAIL <<< $(free -m | awk '/Mem:/ {print $2, $3, $7}')
MEM_USED_REAL=$((MEM_TOTAL - MEM_AVAIL))

# ================= DISCO =================
DISK_TOTAL=$(df -h --total | awk '/total/ {print $2}')
DISK_USED=$(df -h --total | awk '/total/ {print $3}')
DISK_PERC=$(df -h --total | awk '/total/ {print $5}')

# ================= ZFS =================
ZFS_POOLS=$(zpool list 2>/dev/null | awk 'NR>1 {printf "- %s → %s usado de %s (%s)\n", $1, $3, $2, $8}')
[ -z "$ZFS_POOLS" ] && ZFS_POOLS="Sem pool ativo"

# ================= VMs =================
VM_LIST=$(qm list 2>/dev/null | awk 'NR>1 && $3=="running" {printf "- VM %s (%s)\n", $1, $2}')
[ -z "$VM_LIST" ] && VM_LIST="Nenhuma VM rodando"

# ================= LXC =================
LXC_LIST=$(pct list 2>/dev/null | awk 'NR>1 && $2=="running" {printf "- CT %s (%s)\n", $1, $3}')
[ -z "$LXC_LIST" ] && LXC_LIST="Nenhum LXC rodando"

# ================= PROXMOX =================
PVE_VERSION=$(/usr/bin/pveversion 2>/dev/null)

# ================= ATUALIZAÇÕES =================

UPDATES_RAW=$(apt list --upgradable 2>/dev/null | tail -n +2)

if [ -n "$UPDATES_RAW" ]; then
    UPDATE_COUNT=$(echo "$UPDATES_RAW" | wc -l)
    UPDATE_LIST=$(echo "$UPDATES_RAW" | awk -F/ '{print "- " $1}')
else
    UPDATE_COUNT=0
    UPDATE_LIST="Sistema atualizado"
fi

# ================= MENSAGEM =================
MESSAGE=$(
echo "## 🖥 STATUS DO SERVIDOR"
echo ""
echo "**Host:** $HOST"
echo "**Uptime:** $UPTIME"
echo ""
echo "### 🔹 CPU"
echo "- Modelo: ${CPU_MODEL:-N/A}"
echo "- Núcleos: $CPU_CORES"
echo "- Uso atual: ${CPU_USAGE:-0}%"
echo "- Temperatura: $CPU_TEMP"
echo ""
echo "### 🔹 Memória"
echo "- Total: ${MEM_TOTAL}MB"
echo "- Usada real: ${MEM_USED_REAL}MB"
echo ""
echo "### 🔹 Disco"
echo "- Uso total: $DISK_USED / $DISK_TOTAL ($DISK_PERC)"
echo ""
echo "### 📊 ZFS"
echo "$ZFS_POOLS"
echo ""
echo "### 📦 VMs Rodando"
echo "$VM_LIST"
echo ""
echo "### 📦 LXC Rodando"
echo "$LXC_LIST"
echo ""
echo "### 🔹 Proxmox"
echo "$PVE_VERSION"
echo ""
echo "### 📦 Atualizações"
echo "- Pacotes pendentes: $UPDATE_COUNT"
echo "$UPDATE_LIST"
)

curl -sS \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
        --arg title "Status Servidor" \
        --arg msg "$MESSAGE" \
        --argjson priority "$GOTIFY_PRIORITY" \
        '{title:$title,message:$msg,priority:$priority,extras:{"client::display":{"contentType":"text/markdown"}}}')" \
  "${GOTIFY_URL}?token=${GOTIFY_TOKEN}"
