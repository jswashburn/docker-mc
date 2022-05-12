$command = @"
docker run -itp 25565:25565 wwishy/gorkcraft
"@

Invoke-Expression -Command $command