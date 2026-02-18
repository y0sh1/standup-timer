FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# Install nginx and curl for healthcheck
RUN microdnf install -y nginx curl && \
    microdnf clean all && \
    rm -rf /var/cache/yum

# Create nginx user and set permissions
RUN groupadd -r nginx && \
    useradd -r -g nginx -s /sbin/nologin -c "nginx user" nginx && \
    chown -R nginx:nginx /var/lib/nginx /etc/nginx /usr/share/nginx/html

# Copy the HTML file to nginx html directory
COPY standup-timer.html /usr/share/nginx/html/index.html
RUN chown nginx:nginx /usr/share/nginx/html/index.html && \
    chmod 644 /usr/share/nginx/html/index.html

# Create custom nginx config for port 8080 with security headers
RUN cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 8080;
    listen [::]:8080;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
    
    # Hide nginx version
    server_tokens off;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/html text/css application/javascript;
    gzip_comp_level 6;
    
    # Cache headers
    location ~* \.(html)$ {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
    }
    
    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
    
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# Optimize nginx main config and send logs to stdout/stderr
RUN sed -i 's/worker_processes auto;/worker_processes 1;/' /etc/nginx/nginx.conf && \
    sed -i 's/# server_tokens/server_tokens/' /etc/nginx/nginx.conf && \
    sed -i '/server_tokens/c\    server_tokens off;' /etc/nginx/nginx.conf && \
    sed -i 's|access_log /var/log/nginx/access.log;|access_log /dev/stdout;|' /etc/nginx/nginx.conf && \
    sed -i 's|error_log /var/log/nginx/error.log;|error_log /dev/stderr;|' /etc/nginx/nginx.conf

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Expose port 8080
EXPOSE 8080

# Switch to non-root user
USER nginx

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
