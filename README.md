# CS312 Course Project Part 2: Automated Minecraft Server on AWS

## Background

This project automates the provisioning, configuration, and deployment of a Minecraft: Java Edition server on AWS EC2 using Terraform and Ansible. 

Terraform handles infrastructure provisioning: it creates the EC2 instance and configures the security group to allow SSH (port 22) and Minecraft (port 25565) traffic. Ansible handles server configuration: it installs Java, downloads the Minecraft server JAR, accepts the EULA, and configures a systemd service that starts the server automatically on boot and shuts it down gracefully on stop.

The entire pipeline runs from the command line with a single script. No AWS Management Console interaction is required after initial credential setup.

---

## Requirements

### Tools

| Tool | Version Used | Install |
|---|---|---|
| Terraform | 1.15.5 | [terraform.io](https://developer.hashicorp.com/terraform/install) |
| Ansible | 2.16.3 | `sudo apt install ansible` |
| AWS CLI | 2.34.58 | [aws.amazon.com/cli](https://aws.amazon.com/cli/) |
| nmap | 7.94 | `sudo apt install nmap` |
| git | 2.43.0 | `sudo apt install git` |

### Credentials

AWS Academy credentials are required. From the AWS Academy Learner Lab on Canvas:

1. Click **AWS Details**
2. Click **Show** next to AWS CLI
3. Run `aws configure` and enter the `aws_access_key_id` and `aws_secret_access_key`
4. Set the session token:

```bash
aws configure set aws_session_token <your_session_token>
```

### Key Pair

This project uses the AWS Academy default key pair (`vockey`). Download `labsuser.pem` from the AWS Details panel and place it in your WSL home directory:

```bash
chmod 400 ~/labsuser.pem
```

### Environment

These instructions assume a Linux environment or Windows with WSL (Ubuntu 24.04).

---

## Pipeline Diagram
┌─────────────────────────────────────────────────────────┐
│                        run.sh                           │
└─────────────────────────────────────────────────────────┘
             │
┌────────────▼────────────┐
│    Terraform Init       │
│  (download providers)   │
└────────────┬────────────┘
             │
┌────────────▼────────────┐
│    Terraform Apply      │
│  - Create Security Group│
│  - Launch EC2 Instance  │
│  - Output Public IP     │
└────────────┬────────────┘
             │
┌────────────▼────────────┐
│     Wait 60 seconds     │
│  (instance boot time)   │
└────────────┬────────────┘
             │
┌────────────▼────────────┐
│     Ansible Playbook    │
│  - Install Java 25      │
│  - Download MC JAR      │
│  - Accept EULA          │
│  - Configure systemd    │
│  - Enable/Start service │
└────────────┬────────────┘
             │
┌────────────▼────────────┐
│    nmap Verification    │
│  port 25565 open/active │
└─────────────────────────┘

---

## Commands

### 1. Clone the Repository

```bash
git clone https://github.com/Justin-Schenk/cs312-minecraft-server.git
cd cs312-minecraft-server
```

### 2. Configure AWS Credentials

```bash
aws configure
aws configure set aws_session_token 
```

### 3. Make the Run Script Executable

```bash
chmod +x run.sh
```

### 4. Run the Pipeline

```bash
./run.sh
```

This single command will:
- Initialize and apply Terraform to provision the EC2 instance and security group
- Wait 60 seconds for the instance to finish booting
- Generate an Ansible inventory file with the instance public IP
- Run the Ansible playbook to install Java, download the Minecraft server JAR, accept the EULA, and configure the systemd service
- Verify the server is reachable on port 25565 using nmap

### 5. Verify the Server

Once the script completes, verify the server manually at any time:

```bash
nmap -sV -Pn -p T:25565 
```

Expected output:
PORT      STATE SERVICE   VERSION
25565/tcp open  minecraft Minecraft 26.1.2 (Protocol: 127, Message: A Minecraft Server, Users: 0/20)

---

## Connecting to the Minecraft Server

### Option A: Minecraft Java Edition Client

1. Launch Minecraft: Java Edition and log in
2. Select **Multiplayer**
3. Click **Add Server**
4. Enter the instance public IP as the **Server Address**
5. Click **Done**, then **Join Server**

### Option B: nmap Verification

If the Minecraft client is not available, use nmap to confirm the server is reachable:

```bash
nmap -sV -Pn -p T:25565 <instance_public_ip>
```

---

## Auto-Start and Graceful Shutdown

The Minecraft server is configured as a systemd service with:

- `Restart=on-failure` -- restarts the server automatically if it crashes
- `WantedBy=multi-user.target` -- starts the server on every boot
- `ExecStop=/bin/kill -s SIGTERM $MAINPID` -- sends a graceful shutdown signal
- `TimeoutStopSec=60` -- gives the server 60 seconds to save and stop cleanly before forcing termination

---

## Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Minecraft Server Download](https://www.minecraft.net/en-us/download/server)
- [Mojang Version Manifest API](https://launchermeta.mojang.com/mc/game/version_manifest_v2.json)
- [systemd Service Documentation](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [nmap Reference Guide](https://nmap.org/book/man.html)
