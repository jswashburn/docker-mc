[CmdletBinding()]
param(
    # Name of the backup archive
    [Parameter(Mandatory = $true)]
    [string]
    $ArchiveName
)

#
# Extract the archive, move its contents to parent directory, remove empty directory
#

$backupCommand = @"
tar -zxvf $ArchiveName
mv $ArchiveName/* .
rm -r $ArchiveName
"@

Invoke-Expression -Command $backupCommand
