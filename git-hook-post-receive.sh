#!/bin/bash
# Git post-receive hook per auto-deploy
# Da salvare come: /home/dhwp/proxy.dh.unica/.git/hooks/post-receive

echo "🚀 Git hook triggered! Starting auto-deploy..."

# Naviga nella directory di lavoro
cd /home/dhwp/proxy.dh.unica

# Reset al nuovo commit
git --git-dir=/home/dhwp/proxy.dh.unica/.git --work-tree=/home/dhwp/proxy.dh.unica checkout -f

# Reload nginx
echo "🔄 Reloading Nginx configuration..."
chmod +x nginx-reload.sh
./nginx-reload.sh

echo "✅ Auto-deploy completed successfully!"