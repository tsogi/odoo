#!/bin/bash


# Build the Odoo docker image for intel architecture
docker buildx build --platform linux/amd64 -t odoo_tsogi:1.0 --output "type=docker,dest=./odoo_tsogi.tar" .

# Upload docker image .tar to ssh
scp -i /users/nika/.ssh/id_rsa_ubuntu_server ./odoo_tsogi.tar nika@tsogi.net:/var/projects

# If you have a local database dump to upload
# pg_dump -U postgres khinkali_tsogi > khinkali_tsogi.sql
# scp -i /users/nika/.ssh/id_rsa_ubuntu_server ./khinkali_tsogi.sql nika@tsogi.net:/var/projects

# Connect to the machine and run docker image
ssh -i /users/nika/.ssh/id_rsa_ubuntu_server nika@tsogi.net << EOF

    # Navigating to the directory
    cd /var/projects
    
    # Executing the commands
    docker-compose stop odoo_tsogi
    docker-compose rm -f odoo_tsogi
    docker load -i odoo_tsogi.tar
    docker-compose up -d odoo_tsogi
    docker system prune -f
EOF