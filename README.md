# Proxmox Qdevice

[![CodeQL](https://github.com/unixerius/proxmox-qdevice/actions/workflows/github-code-scanning/codeql/badge.svg?branch=master)](https://github.com/unixerius/proxmox-qdevice/actions/workflows/github-code-scanning/codeql) [![Docker Image CI](https://github.com/unixerius/proxmox-qdevice/actions/workflows/docker-image.yml/badge.svg?branch=master)](https://github.com/unixerius/proxmox-qdevice/actions/workflows/docker-image.yml) [![Docker Scout vuln. scan](https://github.com/unixerius/proxmox-qdevice/actions/workflows/docker-scout.yml/badge.svg)](https://github.com/unixerius/proxmox-qdevice/actions/workflows/docker-scout.yml)

This repository allows you to build and deploy a docker container for use with a proxmox cluster as an external qdevice.  Properly configured proxmox clusters require an odd number servers in the cluster.   In the event that you have an even number of proxmox servers (like 2, such as I have), you need an another device to vote.   Proxmox supports this by allowing you to configure a qdevice for an external vote.

For more information on proxmmox clusters, external qdevices, and how to configure/use them, go [here](https://pve.proxmox.com/wiki/Cluster_Manager#_corosync_external_vote_support).

Run this container on a device that is *NOT* a virtual instance on one of your proxmox servers.


## Provenance:

This container image is based on Debian's "slim" images, for both Trixie (13) and Bookworm (12).

The QDevice software is installed from Debian's own software repositories.

The image contains a shell script and a Supervisord configuration created by this project's original author. This project is a fork of [bcleonard/proxmox-qdevice](https://github.com/bcleonard/proxmox-qdevice).

Why a fork? The upstream project hasn't had an update in a year and it lacks weekly builds of the parent image, thus opening up your environment to long-lived vulnerabilities. 


## Acknowledgements:

This repository is based on original [work by Bradley Leonard](https://github.com/bcleonard/proxmox-qdevice). Many thanks to his hard work!

Bradley's original wiki [can be found here](https://github.com/bcleonard/proxmox-qdevice/wiki) which contains all kinds of information on configuring this container.

