#!/bin/sh

# Custom logging function to match Supervisord style
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') [INIT_SSH] INFO $1"
}

# Prepare the SSH directories
mkdir -p /root/.ssh/host_keys
chmod 700 /root/.ssh

# --- Inject the Public Key from the Environment Variable ---
if [ ! -z "$PROXMOX_PUB_KEY" ]; then
    log_info "Environment variable found. Injecting Proxmox public key..."
    # Create or Overwrite the authorized_keys file with the provided public key
    echo "$PROXMOX_PUB_KEY" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# --- Handle Passwords ---
if [ ! -z "$NEW_ROOT_PASSWORD" ]; then
    log_info "Password environment variable found. Setting root password and enabling password auth..."
    echo "root:${NEW_ROOT_PASSWORD}" | chpasswd

    # Dynamically rewrite sshd_config to allow password logins
    sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
else
    log_info "No password variable found. Enforcing strict key-based authentication."
    sed -i 's/.*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
fi

# --- Handle the Host Keys ---
ssh-keygen -A

if [ -z "$(ls -A /root/.ssh/host_keys)" ]; then
    log_info "First run detected. Storing container host keys to persistent volume..."
    # Copy host keys to the backup directory for persistence, if they don't already exist in the backup directory.
    cp /etc/ssh/ssh_host_* /root/.ssh/host_keys/
else
    log_info "Persistent host keys found. Restoring them to /etc/ssh..."
    # Copy the persistent host keys back to /etc/ssh, if they exist in the backup directory.
    cp /root/.ssh/host_keys/ssh_host_* /etc/ssh/
    chmod 600 /etc/ssh/ssh_host_*_key
fi

log_info "Initialization complete. Handing over to Supervisord..."

# --- 4. Execute the Docker CMD ---
# This line is crucial. It executes Supervisord and makes it PID 1.
exec "$@"
