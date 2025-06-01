# n8n Course Project

This project sets up n8n with PostgreSQL and cloudflared for production use.

## System Requirements

- Docker
- Docker Compose
- Git
- [ngrok](https://ngrok.com/) (for webhook testing)
- [Cloudflare](https://cloudflare.com/) (for tunnel) !!!required domain for this

## Installation

1. Clone repository:
```bash
git clone <repository-url>
cd n8n-workflow-template
```

2. Create .env file from .env.example:
```bash
cp .env.example .env
```

3. Edit the .env file to match your environment:
```env
POSTGRES_USER=your_postgres_user
POSTGRES_PASSWORD=your_postgres_password
N8N_ENCRYPTION_KEY=your_encryption_key
N8N_USER_MANAGEMENT_JWT_SECRET=your_jwt_secret
```

4. Create directories for data storage:
```bash
mkdir -p data/{n8n,postgres,npm,letsencrypt}
```

5. Run Docker Compose:
```bash
docker-compose up -d
```

## Access

- n8n: http://localhost:5678

## Using ngrok for Webhook Testing

1. Install ngrok:
```bash
# macOS (using Homebrew)
brew install ngrok

# or download from https://ngrok.com/download
```

2. Register and configure ngrok:
```bash
ngrok config add-authtoken your_ngrok_auth_token
```

3. Create tunnel for n8n:
```bash
ngrok http 5678
```

4. After running ngrok, it will display a URL that allows external access to n8n, for example:
```
Forwarding  https://xxxx-xx-xx-xxx-xx.ngrok.io -> http://localhost:5678
```

5. Configure Webhook URL in n8n:
   - Go to Settings > Workflows
   - Edit Webhook URL to the URL from ngrok
   - Example: `https://xxxx-xx-xx-xxx-xx.ngrok.io`

6. Update .env file:
```env
WEBHOOK_URL=https://xxxx-xx-xx-xxx-xx.ngrok.io
```

7. Restart n8n service:
```bash
docker-compose restart n8n
```

Note:
- ngrok URL changes every time you restart (unless using a paid account)
- Use ngrok only for testing purposes
- For production use, use your own domain through Nginx Proxy Manager

## Cloudflare Tunnel Configuration

1. Install Cloudflare Tunnel:
   - Go to Cloudflare Zero Trust > Access > Tunnels
   - Click "Create a tunnel"
   - Choose tunnel name and click "Create tunnel"

2. Configure Token:
   - After creating tunnel, Cloudflare will display a token
   - Copy the token and add it to .env file:
   ```env
   CLOUDFLARE_TOKEN=your_cloudflare_tunnel_token
   ```

3. Configure DNS:
   - Go to Cloudflare Zero Trust > Access > Tunnels
   - Select the created tunnel
   - Click "Configure" > "Public Hostname"
   - Add hostname for n8n:
     - Subdomain: n8n
     - Domain: your-domain.com
     - Service: http://localhost:5678

4. Restart cloudflared service:
```bash
docker-compose restart cloudflared
```

Note:
- Cloudflare Tunnel creates a secure connection between Cloudflare and local server
- No need to open port 5678 to the internet
- You can access n8n via URL: https://n8n.your-domain.com

## Project Structure

```
.
├── data/                    # Docker volumes data
│   ├── n8n/                # n8n data
│   ├── postgres/           # PostgreSQL data
├── docker-compose.yml      # Docker Compose configuration
├── .env                    # Environment variables
├── .env.example           # Environment variables example
└── .gitignore             # Git ignore rules
```

## Data Backup

All data is stored in the `data/` folder, which includes:
- n8n data
- PostgreSQL database


### Updates

```bash
docker-compose pull
docker-compose up -d
```

### View logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f n8n
docker-compose logs -f postgres
```

### Stop services

```bash
docker-compose down
```

## Basic Troubleshooting

1. **Cannot access n8n**
   - Check that port 5678 is not being used
   - Check n8n service logs
   - Verify Docker containers are running: `docker-compose ps`

2. **Database not working**
   - Check postgres service logs
   - Check connection settings in .env file
   - Verify PostgreSQL container is healthy: `docker-compose exec postgres pg_isready`

3. **Cloudflared not working**
   - Check cloudflared service status: `docker-compose ps cloudflared`
   - View cloudflared logs: `docker-compose logs -f cloudflared`
   - Verify token is correct in .env file
   - Check if tunnel exists in Cloudflare dashboard:
     - Go to Cloudflare Zero Trust > Access > Tunnels
     - Verify tunnel status shows "Healthy"
   - Test tunnel connection:
     ```bash
     # Check if cloudflared is connecting
     docker-compose logs cloudflared | grep -i "connection"
     
     # Restart cloudflared service
     docker-compose restart cloudflared
     ```
   - Common cloudflared issues:
     - **Invalid token**: Check CLOUDFLARE_TOKEN in .env file
     - **Network connectivity**: Ensure server can reach Cloudflare
     - **Firewall blocking**: Check if outbound HTTPS (443) is allowed
     - **DNS not propagated**: Wait for DNS changes to propagate (up to 24 hours)
   - Verify tunnel configuration:
     ```bash
     # Check tunnel configuration
     docker-compose exec cloudflared cloudflared tunnel info your-tunnel-name
     ```

4. **ngrok not working**
   - Check if ngrok is running: `ps aux | grep ngrok`
   - Verify auth token: `ngrok config check`
   - Check ngrok logs for errors
   - Ensure port 5678 is accessible: `curl http://localhost:5678`
   - Try restarting ngrok with verbose logging: `ngrok http 5678 --log=stdout`

5. **Webhook not receiving data**
   - Verify webhook URL is correctly set in n8n
   - Check if external URL (ngrok/Cloudflare) is accessible from outside
   - Test webhook endpoint manually:
     ```bash
     curl -X POST https://your-webhook-url/webhook-test \
          -H "Content-Type: application/json" \
          -d '{"test": "data"}'
     ```
   - Check n8n workflow execution logs

6. **Docker services not starting**
   - Check Docker daemon is running: `docker info`
   - Verify docker-compose.yml syntax: `docker-compose config`
   - Check available disk space: `df -h`
   - Check Docker logs: `docker-compose logs`
   - Remove and recreate containers:
     ```bash
     docker-compose down
     docker-compose up -d --force-recreate
     ```

7. **Environment variables not loading**
   - Verify .env file exists and has correct format
   - Check for spaces around = in .env file
   - Restart services after .env changes:
     ```bash
     docker-compose down
     docker-compose up -d
     ```

## License