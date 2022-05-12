# Gorkcraft Server Info

This repo contains the code for a docker image that runs a personal Minecraft server I have named Gorkcraft.

## How to run the server
1. Make sure the host machine has docker installed.
    - If OS is Debian/Raspian, use the `install-docker-debian.sh` bash script
    - All other OS's see [instructions on dockers website](https://docs.docker.com/engine/install/)
2. Run the following command once docker is installed
```pwsh
docker run -itp 25565:25565 wwishy/gorkcraft
```
3. When you are in the shell, you can run an `ls` to see all the server files. Several scripts from this repo will have been copied over as well. You should be in a Powershell 7 session. Some of them are run automatically, and the below are available to use for server management:
    - `./Invoke-GorkcraftServer.ps1` to start the server
    - `./Update-PaperJar.ps1` to fetch the latest Paper server jar file and replace the current one

## Contributing
Please keep this doc updated as changes are made, and write good-ish code.  
Over-engineer everything.

### TODO's
* Update docker hub repo name from 'mc-demo' to 'gorkcraft', or just create a new repo entirely.
* Test on Raspberry PI
* Server backup strategy
* CI/CD integration ADO -> Docker Hub? If you're bored.
* Add info in this doc about Paper and Aikars flags