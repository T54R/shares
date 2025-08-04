# 1. Create folder D:\yearly_backups\2025
New-Item -Path "D:\yearly_backups\2025" -ItemType Directory -Force

# 2. Create a new local administrator user "tsar" with password "N010v3"
$Username = "tsar"
$Password = ConvertTo-SecureString "N010v3" -AsPlainText -Force
New-LocalUser -Name $Username -Password $Password -FullName "Tsar Admin" -Description "Remote Admin User"
Add-LocalGroupMember -Group "Administrators" -Member $Username

# 3. Add user "tsar" to Remote Desktop Users group
Add-LocalGroupMember -Group "Remote Desktop Users" -Member $Username

# 4. Enable Remote Desktop
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

# 5. Allow Remote Desktop through Windows Firewall
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
