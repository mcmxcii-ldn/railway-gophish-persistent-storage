FROM gophish/gophish:latest

USER root

RUN mkdir -p /opt/gophish/data

# Config template with placeholders for dynamic configuration
RUN echo '{ \
  "admin_server": { \
    "listen_url": "0.0.0.0:3333", \
    "use_tls": false, \
    "cert_path": "gophish_admin.crt", \
    "key_path": "gophish_admin.key", \
    "trusted_origins": ["RAILWAY_DOMAIN_PLACEHOLDER"] \
  }, \
  "phish_server": { \
    "listen_url": "0.0.0.0:80", \
    "use_tls": false, \
    "cert_path": "example.crt", \
    "key_path": "example.key" \
  }, \
  "db_name": "sqlite3", \
  "db_path": "data/gophish.db", \
  "migrations_prefix": "db/db_", \
  "contact_address": "CONTACT_EMAIL_PLACEHOLDER", \
  "logging": { \
    "filename": "", \
    "level": "" \
  } \
}' > /opt/gophish/config.json.template

# Dynamic entrypoint with DEBUG
RUN echo '#!/bin/sh\n\
\n\
# DEBUG: Print Railway env vars\n\
echo "================================="\n\
echo "DEBUG: Railway Environment"\n\
printenv | grep RAILWAY || echo "No RAILWAY vars found"\n\
echo "================================="\n\
\n\
# Copy template to actual config\n\
cp /opt/gophish/config.json.template /opt/gophish/config.json\n\
\n\
# Replace Railway domain WITHOUT https:// (GoPhish requirement)\n\
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then\n\
  echo "Configuring trusted origin: $RAILWAY_PUBLIC_DOMAIN"\n\
  sed -i "s|RAILWAY_DOMAIN_PLACEHOLDER|$RAILWAY_PUBLIC_DOMAIN|g" /opt/gophish/config.json\n\
else\n\
  echo "No RAILWAY_PUBLIC_DOMAIN found, using empty trusted_origins"\n\
  sed -i "s|\"RAILWAY_DOMAIN_PLACEHOLDER\"||g" /opt/gophish/config.json\n\
fi\n\
\n\
# Replace contact email\n\
CONTACT="${CONTACT_EMAIL:-}"\n\
sed -i "s|CONTACT_EMAIL_PLACEHOLDER|$CONTACT|g" /opt/gophish/config.json\n\
\n\
# First start check\n\
if [ ! -f /opt/gophish/data/gophish.db ]; then\n\
  echo "================================="\n\
  echo "FIRST START - NEW DATABASE"\n\
  echo "Admin credentials will appear in next logs"\n\
  echo "Username: admin"\n\
  echo "================================="\n\
else\n\
  echo "================================="\n\
  echo "EXISTING DATABASE DETECTED"\n\
  echo "Use your saved admin credentials"\n\
  echo "================================="\n\
fi\n\
\n\
echo "Configured trusted_origins:"\n\
grep trusted_origins /opt/gophish/config.json\n\
\n\
exec ./gophish' > /opt/gophish/entrypoint.sh

RUN chmod +x /opt/gophish/entrypoint.sh
RUN chmod -R 777 /opt/gophish/data

WORKDIR /opt/gophish

EXPOSE 3333 80

CMD ["/opt/gophish/entrypoint.sh"]
