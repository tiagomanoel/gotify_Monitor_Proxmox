Perfeito.
Segue o **README.md corrigido**, considerando que o script principal se chama `gotify.sh`.

Você pode substituir o conteúdo atual por este.

---

# 🖥️ Gotify Monitor Proxmox

![Proxmox](https://img.shields.io/badge/Proxmox-VE-E57000?logo=proxmox\&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Script-121011?logo=gnubash)
![Systemd](https://img.shields.io/badge/Systemd-Timer-ffcc00?logo=linux)
![License](https://img.shields.io/badge/License-MIT-blue)

Script de monitoramento para **Proxmox VE**, com envio automático de status do servidor via **Gotify** em formato Markdown.

---

## 📌 Funcionalidades

O script coleta e envia:

* 🖥️ Modelo, uso e temperatura da CPU
* 💾 Uso real de memória
* 💽 Uso total de disco
* 📊 Uso individual de cada pool ZFS
* 📦 VMs (QEMU) em execução
* 📦 Containers LXC em execução
* 🔄 Pacotes pendentes de atualização
* 🔧 Versão do Proxmox

---

## 📸 Exemplo de saída no Gotify

```markdown
## 🖥️ STATUS DO SERVIDOR

Host: proxmox-home
Uptime: up 3 hours

### 🔹 CPU
- Modelo: Intel Xeon
- Núcleos: 8
- Uso atual: 12%
- Temperatura: 42°C

### 🔹 Memória
- Total: 32768MB
- Usada real: 10432MB

### 📊 ZFS
- rpool → 120G usado de 512G (23%)

### 📦 VMs Rodando
- VM 100 (OPNsense)
- VM 101 (Home Assistant)
```

---

# 📦 Requisitos

* Proxmox VE
* `curl`
* `jq`
* `git`
* (Opcional) `lm-sensors`

Instalação:

```bash
apt update
apt install curl jq git lm-sensors -y
```

---

# 📁 Estrutura do Projeto

```text
gotify_Monitor_Proxmox/
 ├── gotify.sh
 ├── gotify.env
 └── README.md
```

---

# 🔐 Configuração

## 1️⃣ Criar arquivo de credenciais

```bash
nano gotify.env
```

Conteúdo:

```bash
GOTIFY_URL="https://gotify.seudominio.com/message"
GOTIFY_TOKEN="SEU_TOKEN_AQUI"
GOTIFY_PRIORITY=5
```

Proteger:

```bash
chmod 600 gotify.env
```

O script detecta automaticamente o `gotify.env` no mesmo diretório.

---

# ▶ Execução Manual

```bash
chmod +x gotify.sh
./gotify.sh
```

---

# ⏰ Execução Automática (Systemd Timer)

## 1️⃣ Criar serviço

```bash
nano /etc/systemd/system/gotify-monitor.service
```

Conteúdo:

```ini
[Unit]
Description=Monitoramento Proxmox via Gotify
After=network.target

[Service]
Type=oneshot
ExecStart=/root/gotify_Monitor_Proxmox/gotify.sh
User=root
```

> Ajuste o caminho se necessário.

---

## 2️⃣ Criar timer

```bash
nano /etc/systemd/system/gotify-monitor.timer
```

Executando diariamente às 08:00:

```ini
[Unit]
Description=Executa o monitor Gotify uma vez ao dia

[Timer]
OnCalendar=*-*-* 08:00:00
Persistent=true
AccuracySec=1min
Unit=gotify-monitor.service

[Install]
WantedBy=timers.target
```

---

## 3️⃣ Ativar

```bash
systemctl daemon-reload
systemctl enable gotify-monitor.timer
systemctl start gotify-monitor.timer
```

---

## 🔎 Verificar

```bash
systemctl list-timers | grep gotify
```

---

## 🧪 Testar manualmente

```bash
systemctl start gotify-monitor.service
journalctl -u gotify-monitor.service -n 50 --no-pager
```

---

# 🔄 Atualizar no Servidor

Se o projeto foi clonado via Git:

```bash
git fetch origin
git reset --hard origin/main
```

---

# 🔐 Segurança

* Credenciais ficam no `gotify.env`
* Permissão recomendada: `chmod 600`
* Token não fica no script
* Compatível com execução via systemd

---

## 📜 Licença

Este projeto está licenciado sob a licença MIT.  
Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 🤝 Contribuição

Contribuições são bem-vindas!

Se você quiser contribuir:

1. Faça um fork do repositório
2. Crie uma branch para sua modificação:
