#!/bin/bash

# Caminhos dos arquivos
ARQUIVO_NORMAL="/etc/nginx/sites-available/essencia-gourmet-normal"
ARQUIVO_ERRO="/etc/nginx/sites-available/essencia-gourmet-erro"
ARQUIVO_DESTINO="/etc/nginx/sites-available/essencia-gourmet"
LOG_FILE="/var/log/meu_script.log"

# Webhook do Discord
[ -f /usr/local/bin/.env ] && export $(grep -v '^#' /usr/local/bin/.env | xargs)

# Função para enviar notificação ao Discord
enviar_webhook() {
  DATA_HORA=$(date '+%Y-%m-%d %H:%M:%S')
  MENSAGEM="$1"
  curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"[$DATA_HORA] $MENSAGEM\"}" "$DISCORD_WEBHOOK"
}


# Verifica status do servidor
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)


#Será gerado números aleatório  de 0 a 9, cada número tem 10% de ser sorteado, quando for menor que 2 o segundo if entra em ação
CHANCE=$(( RANDOM % 10 ))


if [ "$STATUS" -eq 200 ]; then
  echo "[INFO] Servidor disponível. Código HTTP: $STATUS" >> "$LOG_FILE"
 

  if [ "$CHANCE" -lt 3 ]; then
    cp "$ARQUIVO_ERRO" "$ARQUIVO_DESTINO"
    sudo systemctl reload nginx
    echo "[INFO] Forçando erro 503..." >> "$LOG_FILE"
  fi

  elif [ "$STATUS" -eq 503 ]; then
   echo "[ERROR] Servidor indisponível! Código HTTP: $STATUS" >> "$LOG_FILE"
   enviar_webhook "⚠️ **Servidor indisponível!** :( \nCódigo HTTP: $STATUS"

  sleep 20 

# Restaura o site
  cp "$ARQUIVO_NORMAL" "$ARQUIVO_DESTINO"
  sudo systemctl reload nginx
  echo "[INFO] Restaurando o servidor..." >> "$LOG_FILE"
 fi


