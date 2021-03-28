$tar = "hi"
$text = [IO.File]::ReadAllText(".\beforeAttack.ps1")
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
"-EncodedCommand $EncodedText" > ".\$tar"