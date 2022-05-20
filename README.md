# Summary

Docker image for Minecraft server

## Cool features 😎
* Setup scripts that provision the required resources in Azure for data backups.
* Data backup scripts for zipping and uploading folders and files to the Azure cloud.
* Minecraft server management scripts.
* Installation tools
  
## Stuff you need 📃
* Azure account and subscription (if you want cloud backups)
* Docker installed on the host you plan to run the server from

## How to run the server 🤔
1. Make sure docker is installed.
2. Run the following command
    ```pwsh
    docker image build -t <image-name> .
    docker run -itp 25565:25565 <image-name>
    ```
    > The `-itp 25565:25565` part means *"attach an interactive terminal and map port 25565 on the host to 25565 on the server"*. These are the ports used by Minecraft.
3. You are now in the server. To get started, run `Start-Server.ps1` in PowerShell and provide your Azure subscription id. If you do not wish to use cloud backups, pass the `-SkipAzResourceProvisioning` flag to the cmdlet.

## Useful scripts ⚙️
### In this repository
* `tools\install-docker-debian.sh` - Installs docker
### In the container
* `Start-Server.ps1` - Starts the Minecraft server and performs initial setup of cloud backup resources.
* `Start-ArchiveUpload.ps1` - Accepts an array of folder names, archives them, and uploads to your cloud storage.
* `Get-UpdatedPaperJar.ps1` - Finds the most up to date version of the PaperMC server jar file and replaces the one in the server's directory. Make sure to stop the server first!
> Any scripts you see not listed above are run behind the scenes, take a look at the comments to see what they do. They are not meant to be run on their own so make sure you understand what's going on first

## How to use cloud backups ☁️
Currently server backups must be performed manually by running the provided script. I am working on a way to do this automatically, while the server is running.

1. You must have the cloud resources in place and ready to go before the backup script will work. If you have an Azure account and subscription this should have been set up for you on the initial server run.
2. Run the provided script, passing in the names of the folders you want zipped and uploaded. The default array is `@("world,", "world_nether", "world_the_end")`

## Contributing
Please keep this doc updated as changes are made, and write good-ish code.  
Over-engineer everything.
### TODO
* Download world backups