# Proxmox Qdevice

This repository will allow you build and deploy a docker container for use with a proxmox cluster as an external qdevice.  Properly configured proxmox clusters require an odd number servers in the cluster.   In the event that you have an even number of proxmox servers (like 2, such as I have), you need an another device to vote.   Proxmox supports this by allow you to configure a qdevice for an external vote.

Normally running an even number of servers in a cluster isn't a problem, but I've had situations where I've booted both proxmox servers at the same time.  In that case, the first server to come online doesn't have a quorum (1 of 2) so the virtual machines and containers won't start.  With an external qdevice thats already up, the first device to come up has quorum (2 of 3).  

For more information on proxmmox clusters, external qdevices, and how to configure/use them, go [here](https://pve.proxmox.com/wiki/Cluster_Manager#_corosync_external_vote_support).

Run this container on a device that is *NOT* a virtual instance on one of your proxmox servers.


## Provenance:

This container image is based on Docker's Debian DHI (*Docker Hardened Image*), i.e. it is supposed to be a more secure variant of a Debian container. At the time of writing, this is based upon Debian 13 (Trixie).

The QDevice software is installed from Debian's own software repositories.

The image contains a shell script and a Supervisord configuration created by this project's original author. This project is a fork of [bcleonard/proxmox-qdevice](https://github.com/bcleonard/proxmox-qdevice).

Why a fork? The upstream project hasn't had an update in a year and it lacks weekly builds of the parent image, thus opening up your environment to long-lived vulnerabilities. 


## Install:

This container is designed to run from either Docker Compose or a container manager, like Portainer.

## Configuration:

Modify the docker-compose.yml file.   Make sure to change:

* Environment Variable NEW_ROOT_PASSWORD.
* Location of your corosync-data (so you can keep your configuration between restarts, etc.).
* Hostname .
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

## Acknowledgements:

This repository is based on original [work by Bradley Leonard](https://github.com/bcleonard/proxmox-qdevice). Many thanks to his hard work!

Bradley's original wiki [can be found here](https://github.com/bcleonard/proxmox-qdevice/wiki) which contains all kinds of information on configuring this container.

