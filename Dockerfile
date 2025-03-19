# Start with a Python base image
FROM python:3.10-bullseye

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    ODOO_USER=odoo \
    ODOO_GROUP=odoo

# Install system dependencies required for Odoo
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    build-essential \
    libxml2-dev \
    libxslt1-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    libjpeg-dev \
    libpq-dev \
    libjpeg62-turbo \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    libpng-dev \
    nodejs \
    npm \
    git \
    curl \
    wget \
    wkhtmltopdf \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create Odoo user and group
RUN groupadd -r ${ODOO_GROUP} && useradd -r -g ${ODOO_GROUP} ${ODOO_USER}

# Set up directories with correct permissions
RUN mkdir -p /var/lib/odoo /usr/lib/python3/dist-packages/odoo /var/log/odoo /mnt/extra-addons /etc/odoo \
    && chown -R ${ODOO_USER}:${ODOO_GROUP} /var/lib/odoo /usr/lib/python3/dist-packages/odoo /var/log/odoo /mnt/extra-addons /etc/odoo

# Copy local Odoo source code (excluding unnecessary files using .dockerignore)
COPY --chown=${ODOO_USER}:${ODOO_GROUP} . /usr/lib/python3/dist-packages/odoo/

# Create entrypoint script to configure Odoo dynamically
RUN echo '#!/bin/bash\n\
# Create or update odoo.conf using environment variables\n\
cat > /etc/odoo/odoo.conf << EOF\n\
[options]\n\
addons_path = /usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons\n\
data_dir = /var/lib/odoo\n\
logfile = /var/log/odoo/odoo.log\n\
admin_passwd = admin\n\
db_host = \${HOST:-postgres}\n\
db_user = \${USER:-odoo}\n\
db_password = \${PASSWORD:-odoo}\n\
db_port = 5432\n\
db_name = \${DATABASE:-khinkali_tsogi}\n\
EOF\n\
\n\
# Start Odoo with generated config\n\
exec python3 /usr/lib/python3/dist-packages/odoo/odoo-bin -c /etc/odoo/odoo.conf "$@"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

# Install Python dependencies
WORKDIR /usr/lib/python3/dist-packages/odoo
RUN pip3 install -r requirements.txt

# Expose Odoo ports
EXPOSE 8069 8072

# Set the default user
USER ${ODOO_USER}

# Run the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]