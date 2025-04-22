# Importeer de benodigde module
Import-Module Microsoft.Graph.Autopilot

# Authenticatie met Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All"

# Pad naar de CSV
$csvPath = "C:\Intune\devices1.csv"

# Pad naar het logbestand
$logPath = "C:\Intune\Error.log"

# CSV-indeling: SerialNumber, NewComputerName
$devices = Import-Csv -Path $csvPath

foreach ($device in $devices) {
    $serialNumber = $device.SerialNumber
    $newName = $device.NewComputerName

    # Zoek het apparaat in Autopilot
    $autopilotDevice = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -Filter "serialNumber eq '$serialNumber'"

    if ($autopilotDevice) {
        # Controleer of de computernaam al is ingesteld
        if (-not [string]::IsNullOrWhiteSpace($autopilotDevice.DisplayName)) {
            $errorMessage = "Fout: Computernaam voor apparaat met serienummer $serialNumber is al ingesteld op '$($autopilotDevice.DisplayName)'."
            Write-Host $errorMessage
            $errorMessage | Add-Content -Path $logPath
            continue
        }

        # Update de computernaam
        Update-MgDeviceManagementWindowsAutopilotDeviceIdentity -WindowsAutopilotDeviceIdentityId $autopilotDevice.Id -DisplayName $newName
        Write-Host "Naam bijgewerkt voor apparaat met serienummer $serialNumber naar $newName"
    } else {
        $errorMessage = "Apparaat met serienummer $serialNumber niet gevonden in Autopilot"
        Write-Host $errorMessage
        $errorMessage | Add-Content -Path $logPath
    }
}

# Verbinding verbreken
Disconnect-MgGraph