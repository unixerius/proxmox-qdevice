# Proxmox Qdevice usage instruction

## Install:

This container is designed to run from either Docker Compose or a container manager, like Portainer.

## Configuration:

Modify the docker-compose.yml file.   Make sure to change:

* Environment variable TZ : change Europe/Paris with your timezone (sets the right time for logs).
* Location of your corosync-data (to retain configuration across restarts, etc.).
* Location of your root homedir (to retain Proxmox SSH keys in authorized_keys).
* Hostname.
* Local network information.
   parent (the ethernet device to bind macvlan)  
   ipv4_address  
   subnet  
   ip_range  
   gateway

Copy the `.env.example` file as `.env` and edit it to put your public ssh keys to allow the proxmox nodes to connect to the qdevice (the qdevice does not need to connect to the nodes through ssh). One ssh key per line.

If you are defining, the ssh keys directly in the compose instead, you can use the pipe : 
```yaml
environment:
   PROXMOX_PUB_KEY: |
      ssh-rsa key1 comment
      ssh-rsa key2 comment
```

In the location for your persistent storage, make sure to create the directories for the root homedir and the corosync-data. (or use volumes)

### Special note for Synology

For the storage location of "corosync-data" and "roothome", DO NOT use a path in /opt, /usr etc. Create a separate directory for proxmox-qdevice under one of your storage volumes.

Directories like /opt get erased across Synology DSM updates. Ask me how I know. ;)

## Running / Deploying:

You can either run the command:

`docker compose up -d`

Or cut and paste the docker-compose.yml into portainer.io as a stack and then deploy.

The very first time that you run the container, this will _seemingly_ fail. It runs, but corosync-qnetd will fail to start. Refer to [issue 5](https://github.com/unixerius/proxmox-qdevice/issues/5), or the "Completing setup" section below.

### building

You can also run the container by building it :

In the docker-compose.yml file :

* Uncomment the line `dockerfile: Dockerfile-trixie` in build.
* Edit this line to set either trixie or bookworm.

Then you can run the command :

`docker compose up -d --build`

## Completing setup:

1. Build your Proxmox cluster.
2. Run the `proxmox-qdevice` container via Docker Compose.

Then fFollow the [setup instructions on the Proxmox site](https://pve.proxmox.com/wiki/Cluster_Manager#_corosync_external_vote_support), which means:

3. Install the `corosync-qdevice` package on all real cluster nodes.
4. Ensure that all cluster nodes can SSH to the container; I did `ssh_copy_id root@${qdeviceIP}`.
5. Run `pvecm qdevice setup ${IPAddress}` on one of the real cluster nodes.
6. Once that is done, restart the `proxmox-qdevice` container. This time, corosync-qnetd will startup correctly as it now has a full database and configuration.


## Security Implications:

This container installs and configures a sshd server that permits root logins.  Proxmox runs in the same configuration.  Upon startup, if the environment variable **PROXMOX_PUB_KEY** exists the ssh keys will be set in the authorized_hosts, allowing a login.   You can specify what the ssh keys should be by setting the value of **PROXMOX_PUB_KEY** to the public ssh keys in one of the following ways:

1) If you are using a container manager, such as portainer, set the environment variable **PROXMOX_PUB_KEY** to your specified ssh keys.  This variable should get passed to the container. (Not sure if this works with more than 1  public key).
2) Follow one of the Docker provided ways documented in how to ["Set environment variables within your container's environment"](https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/).  Please note that one of the ways described is setting the ssh keys in the docker-compose.yml (or the stack) in the environment section (i.e. hardcoding it).   If you hardcode the ssh keys like this, you can expose the keys. It is however, less critical than exposing a password, as it's not private keys.

Please note that all of the ways listed above to set the environment above should survive the recreation of the container.

> [!IMPORTANT]
>
> ## A note on `latest` and `beta`:
>
> It is not recommended to use the `latest` (`unixerius/proxmox-qdevice`, `unixerius/proxmox-qdevice:latest`) tag for production setups.
>
> [Those tags point](https://hub.docker.com/r/unixerius/proxmox-qdevice/tags) might not point to the latest commit in the `master` branch. They do not carry any promise of stability, and using them will probably put your proxmox-qdevice setup at risk of experiencing uncontrolled updates to non backward compatible versions (or versions with breaking changes). You should always specify the version you want to use explicitly to ensure your setup doesn't break when the image is updated.

