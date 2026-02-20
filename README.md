# gotify-server-status

Este repositório contém um script Bash planejado para **ser executado em servidores Proxmox**. Ele coleta informações do host e de seus guests (CPU, memória, disco, ZFS, VMs, LXC, versão do Proxmox, etc.) e envia uma mensagem formatada para o serviço Gotify.

## Funcionamento

O script (`gotify.sh`) lê variáveis de configuração de um arquivo `.gotify.env`, compõe uma mensagem em Markdown com o estado do servidor e publica para um servidor Gotify usando a API HTTP.

## Dependências

O servidor onde o script é executado precisa ter os seguintes programas instalados:

- `bash` (como interpretador do script)
- `curl` (para enviar a requisição HTTP ao Gotify)
- `jq` (para montar o JSON da mensagem)
- `lscpu`, `nproc`, `top`, `free`, `df` (ferramentas padrão de análise de sistema)
- `zpool` (caso utilize ZFS na máquina Proxmox)
- `qm` e `pct` (para Proxmox VMs e containers, essenciais no ambiente Proxmox)
- `/usr/bin/pveversion` (proxmox, para coletar a versão do PVE)

> Observação: a maioria dessas ferramentas já vem em distribuições Linux com Pacotes padrão ou Proxmox.

## Instalação

1. Clone ou copie o script para um diretório de sua preferência:
   ```bash
   git clone <seu-repo> gotify-server-status
   cd gotify-server-status
   ```
2. Crie um arquivo de variáveis copiando o exemplo:
   ```bash
   cp gotify.env.exemple .gotify.env
   ```
3. Edite `.gotify.env` com sua URL do Gotify, token e prioridade:
   ```ini
   GOTIFY_URL="https://gotify.seudominio.com/message"
   GOTIFY_TOKEN="SEU_TOKEN_AQUI"
   GOTIFY_PRIORITY=5
   ```
4. Dê permissão de execução ao script:
   ```bash
   chmod +x gotify.sh
   ```
5. Teste executando manualmente:
   ```bash
   ./gotify.sh
   ```
   Caso tudo esteja correto, você receberá uma notificação no cliente Gotify configurado.

## Uso

Agende a execução periódica usando `cron` ou `systemd` para enviar atualizações regulares do status do servidor.

```cron
*/5 * * * * /path/to/gotify.sh
```

## Licença

Sinta-se à vontade para utilizar e adaptar este script conforme necessário. Não há licença específica definida.
