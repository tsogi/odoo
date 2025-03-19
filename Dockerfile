# Update to use Odoo 18.0 as the base image
FROM odoo:18.0

# Set the working directory
WORKDIR /usr/lib/python3/dist-packages/odoo

# Install additional dependencies if needed
USER root
RUN apt-get update && apt-get install -y \
    python3-pip \
    postgresql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install additional Python packages if required
# RUN pip3 install some-package

# Copy custom modules if you have any
# COPY ./custom_addons /mnt/extra-addons/

# Expose the Odoo port
EXPOSE 8069 8072

# The command will be inherited from the base image
# CMD ["odoo"]