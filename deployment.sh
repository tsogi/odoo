# Copy envs
cp .env.production.local .env.production.local

# Build the app
npm run build

# Create docker image .tar for intel
docker buildx build --platform linux/amd64 -t tsogi_manager:1.0 --output "type=docker,dest=./tsogi_manager.tar" .

# Upload docker image .tar to ssh
scp -i /users/nika/.ssh/id_rsa_ubuntu_server ./tsogi_manager.tar nika@tsogi.net:/var/projects

# Connect to the machine and run docker image
ssh -i /users/nika/.ssh/id_rsa_ubuntu_server nika@tsogi.net << EOF

    # Navigating to the directory
    cd /var/projects
    
    # Executing the commands
    docker-compose stop tsogi_manager
    docker-compose rm -f tsogi_manager
    docker load -i tsogi_manager.tar
    docker-compose up -d tsogi_manager
    docker system prune -f

    # docker-compose rm -f tsogi_manager
    # docker load -i tsogi_manager.tar
    # docker-compose up -d tsogi_manager
EOF