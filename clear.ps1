Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" -Name ExecutionPolicy -value Restricted
Set-Itemproperty -path "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell" -Name '(Default)' -value Open
Remove-Item –path "C:/Users/attack_file2.bat"
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "virus"
echo "clear success!"
pause