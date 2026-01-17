# Proxmox Qdevice usage instruction

## Install:

This container is designed to run from either Docker Compose or a container manager, like Portainer.

## Configuration:

Modify the docker-compose.yml file.   Make sure to change:

* Environment Variable NEW_ROOT_PASSWORD.
* Location of your corosync-data (so you can keep your configuration between restarts, etc.).
* Hostname.
* Local network information.
   parent (the ethernet device to bind macvlan)  
   ipv4_address  
   subnet  
   ip_range  
   gateway

## Running / Deploying:

You can either run the command:

`docker compose up -d`

Or cut and paste the docker-compose.yml into portainer.io as a stack and then deploy.

The very first time that you run the container, this will _seemingly_ fail. It runs, but corosync-qnetd will fail to start. Refer to [issue 5](https://github.com/unixerius/proxmox-qdevice/issues/5), or the "Completing setup" section below.

## Completing setup:

1. Build your Proxmox cluster.
2. Run the `proxmox-qdevice` container via Docker Compose.

Then fFollow the [setup instructions on the Proxmox site](https://pve.proxmox.com/wiki/Cluster_Manager#_corosync_external_vote_support), which means:

3. Install the `corosync-qdevice` package on all real cluster nodes.
4. Ensure that all cluster nodes can SSH to the container; I did `ssh_copy_id root@${qdeviceIP}`.
5. Run `pvecm qdevice setup ${IPAddress}` on one of the real cluster nodes.
6. Once that is done, restart the `proxmox-qdevice` container. This time, corosync-qnetd will startup correctly as it now has a full database and configuration.


## Security Implications:

This container installs and configures a sshd server that permits root logins.  Proxmox runs in the same configuration.  Upon startup, if the environment variable **NEW_ROOT_PASSWORD** exists the root password will be set to the value of that variable upon boot.   You can specify what the root password should be setting the value of **NEW_ROOT_PASSWORD** to a password in one of the following ways:

1) If you are using a container manager, such as portainer, set the environment variable **NEW_ROOT_PASSWORD** to your specified root password.  This variable should get passed to the container.
2) Follow one of the Docker provided ways documented in how to ["Set environment variables within your container's environment"](https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/).  Please note that one of the ways described is setting the password in the docker-compose.yml (or the stack) in the environment section (i.e. hardcoding it).   If you hardcode the password like this, you can expose the password.  You have been warned.

Please note that all of the ways listed above to set the environment above should survive the recreation of the container.

> [!IMPORTANT]
>
> ## A note on `latest` and `beta`:
>
> It is not recommended to use the `latest` (`unixerius/proxmox-qdevice`, `unixerius/proxmox-qdevice:latest`) tag for production setups.
>
> [Those tags point](https://hub.docker.com/r/unixerius/proxmox-qdevice/tags) might not point to the latest commit in the `master` branch. They do not carry any promise of stability, and using them will probably put your proxmox-qdevice setup at risk of experiencing uncontrolled updates to non backward compatible versions (or versions with breaking changes). You should always specify the version you want to use explicitly to ensure your setup doesn't break when the image is updated.

## Security Implications:

This container installs and configures a sshd server that permits root logins.  Proxmox runs in the same configuration.  Upon startup, if the environment variable **NEW_ROOT_PASSWORD** exists the root password will be set to the value of that variable upon boot.   You can specify what the root password should be setting the value of **NEW_ROOT_PASSWORD** to a password in one of the following ways:

1) If you are using a container manager, such as portainer, set the environment variable **NEW_ROOT_PASSWORD** to your specified root password.  This variable should get passed to the container.
2) Follow one of the Docker provided ways documented in how to ["Set environment variables within your container's environment"](https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/).  Please note that one of the ways described is setting the password in the docker-compose.yml (or the stack) in the environment section (i.e. hardcoding it).   If you hardcode the password like this, you can expose the password.  You have been warned.

Please note that all of the ways listed above to set the environment above should survive the recreation of the container.

