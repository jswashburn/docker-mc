FROM ubuntu:20.04

WORKDIR /serverBackup

# Install Powershell 7
RUN apt-get update
RUN apt-get install -y wget apt-transport-https software-properties-common
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN add-apt-repository universe
RUN apt-get install -y powershell

# Install Java OpenJDK
RUN apt install -y openjdk-17-jre-headless

# Install screen
RUN apt-get -y install screen

# Install require Az Powershell modules
RUN pwsh -Command Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
RUN pwsh -Command Install-Module Az.Accounts
RUN pwsh -Command Install-Module Az.Storage
RUN pwsh -Command Install-Module Az.KeyVault
RUN pwsh -Command Install-Module Az.Resources

# Set environment variables
ENV SERVER_BACKUP_SETTINGS=data/settings.json
ENV SERVER_BACKUP_TEMPLATE=template/serverBackup.Template.json
ENV SERVER_BACKUP_TEMPLATE_PARAMETERS=template/serverBackup.Parameters.json
ENV SERVER_BACKUP_TEMPLATE_PARAMETERS_GENERIC=template/serverBackup.Parameters-generic.json

# Copy over files in repo, except those specified in the .dockerignore
COPY . .

# Get the latest Paper server .jar file
RUN pwsh -Command ./Update-PaperJar.ps1 -NoWarn

# Do initial server run and accept eula
RUN java -jar paper-latest.jar --nogui
RUN pwsh -Command ./Set-EulaAccepted.ps1 -EulaPath ./eula.txt
