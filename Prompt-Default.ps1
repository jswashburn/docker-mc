[CmdletBinding()]
param(
    # The Prompt
    [Parameter(Position = 0)]
    [string]
    $Prompt,

    # The Default value if nothing is entered
    [Parameter(Position = 1)]
    [string]
    $Default
)

return (Read-Host "$Prompt (Enter nothing for default: '$Default')" -OutVariable val) -eq "" ? $Default : $val[0]
