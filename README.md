# Deploying to AWS EC2

## Prerequisites

- AWS Account
- EC2 Instance running Ubuntu
- Domain Name (optional)

## Step 1: Launch EC2 Instance

1. Go to AWS Console > EC2 Dashboard
2. Click "Launch Instance"
3. Choose Ubuntu Server (22.04 LTS)
4. Select t2.micro (free tier) or larger
5. Configure Security Group:
   ```
   Type        Port    Source
   SSH         22      Your IP
   HTTP        80      Anywhere
   Custom TCP  5000    Anywhere (Backend)
   Custom TCP  5173    Anywhere (Frontend)
   ```
6. Create or select an existing key pair
7. Launch Instance

## Step 2: Connect to EC2

```bash
# Download your .pem key and set permissions
chmod 400 your-key.pem

# Connect to instance (replace with your instance's public IP)
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

## Step 3: Install Dependencies

```bash
# Update package list
sudo apt update

# Install Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu
newgrp docker

# Install make
sudo apt install -y make

# Install Python3 (should be already installed on Ubuntu)
sudo apt install -y python3
```

## Step 4: Clone and Deploy Application

```bash
# Clone your repository (replace with your repo URL)
git clone https://github.com/sarathkhandavilli/practice-deployment.git
cd practice-deployment

# Build and start containers
make up

# Verify containers are running
docker ps
```

## Step 5: Verify Deployment

1. Open your browser and navigate to:
   - Frontend: http://your-ec2-public-ip:5173
   - Backend: http://your-ec2-public-ip:5000

2. Test API connection by using the frontend interface

## Troubleshooting

### If containers fail to start:
```bash
# Check container logs
docker logs simple_frontend
docker logs simple_backend

# Check if ports are in use
sudo netstat -tulpn | grep -E '5173|5000'

# Rebuild containers
make down
make up
```

### If IP detection fails:
```bash
# Check the .env file
cat frontend/.env

# Manually set the IP if needed
echo "VITE_API_URL=http://your-ec2-public-ip:5000" > frontend/.env
make up
```

## Production Considerations

1. Use HTTPS:
   - Install Nginx as reverse proxy
   - Set up SSL with Let's Encrypt
   - Update frontend to use HTTPS URLs

2. Domain Setup:
   ```nginx
   # /etc/nginx/sites-available/your-app
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:5173;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }

       location /api {
           proxy_pass http://localhost:5000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

3. Persistent Storage:
   - Mount volumes for any data that needs to persist
   - Set up database backups

4. Monitoring:
   - Set up CloudWatch monitoring
   - Configure container log rotation

## Automatic Startup

Create a systemd service to start containers on boot:

```bash
sudo nano /etc/systemd/system/docker-compose-app.service
```

Add the following content:
```ini
[Unit]
Description=Docker Compose Application Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/practice-deployment
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl enable docker-compose-app
sudo systemctl start docker-compose-app
```

## Clean Up

To remove the application and its containers:
```bash
cd practice-deployment
make down
docker system prune -f  # Removes unused containers, networks, and images
```