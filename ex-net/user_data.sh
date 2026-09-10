#!/bin/bash
if command -v dnf >/dev/null 2>&1; then
  dnf install -y nginx
elif command -v apt-get >/dev/null 2>&1; then
  apt-get update -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
fi
systemctl enable nginx
systemctl start nginx
if command -v dnf >/dev/null 2>&1; then
  web_root=/usr/share/nginx/html
else
  web_root=/var/www/html
fi
mkdir -p "$web_root"
cat > "$web_root/index.html" <<'HTML'
<h1>${name} instance</h1>
<p>configured-by-terraform</p>
HTML
