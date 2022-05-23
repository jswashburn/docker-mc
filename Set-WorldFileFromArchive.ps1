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

# TODO: mv command below not working and probs not needed
$backupCommand = @"
tar -zxvf $ArchiveName
mv $ArchiveName/* .
rm -r $ArchiveName
"@

Invoke-Expression -Command $backupCommand
