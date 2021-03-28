# cant use Set-ExecutionPolicy
# https://www.avex.idv.tw/2019/07/30/powershell-run-as-administrator-from-command/
Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" -Name ExecutionPolicy -value Unrestricted
Set-Itemproperty -path "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell" -Name '(Default)' -value 0