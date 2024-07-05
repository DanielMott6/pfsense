#!/bin/sh

#Arquivos temporarios
BACKUP_PATH="/root/config-$(date +%Y-%m-%d).xml"
EMAIL_BODY="/tmp/email_body.txt"

# Local do arquivo config
cp /cf/conf/config.xml ${BACKUP_PATH}

# Verifica localizacao do bkp
if [ ! -f "${BACKUP_PATH}" ]; then
    echo "Erro: Backup não encontrado."
    exit 1
fi

#Verifica IP do pfsense:
IP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{ print $2 }' | head -n 1)



# Parâmetros do email
EMAIL="monitoramento@tecmaissolucoes.com.br"
SUBJECT="Backup pfSense $(hostname) $(date +%Y-%m-%d)"
BODY="Segue em anexo o backup do pfSense realizado em $(date). IP: ${IP}."
ATTACHMENT="${BACKUP_PATH}"
SMTP_SERVER="smtp.office365.com"
SMTP_PORT="587"
SMTP_USER="monitoramento@tecmaissolucoes.com.br"
SMTP_PASS="Cub01301"

# Corpo do e-mail
{
    echo "From: ${SMTP_USER}"
    echo "To: ${EMAIL}"
    echo "Subject: ${SUBJECT}"
    echo "MIME-Version: 1.0"
    echo "Content-Type: multipart/mixed; boundary=\"frontier\""
    echo
    echo "--frontier"
    echo "Content-Type: text/plain"
    echo
    echo "${BODY}"
    echo
    echo "--frontier"
    echo "Content-Type: application/octet-stream; name=\"$(basename ${ATTACHMENT})\""
    echo "Content-Transfer-Encoding: base64"
    echo "Content-Disposition: attachment; filename=\"$(basename ${ATTACHMENT})\""
    echo
    base64 ${ATTACHMENT}
    echo
    echo "--frontier--"
} > ${EMAIL_BODY}

# Envia e-mail via Curl
curl --url "smtp://${SMTP_SERVER}:${SMTP_PORT}" --ssl-reqd \
    --mail-from "${SMTP_USER}" \
    --mail-rcpt "${EMAIL}" \
    --user "${SMTP_USER}:${SMTP_PASS}" \
    -T ${EMAIL_BODY}

# Remove arquivos temporarios
rm "${BACKUP_PATH}"
rm "${EMAIL_BODY}"
