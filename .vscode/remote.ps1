$user = "paul"
$KeyFilePath = "C:\users\paulh\.ssh\id_ed25519"
$ComputerName = "docker.houghton.network","10.10.20.201","xo.houghton.network"


$credential = Get-Credential

foreach ($Computer in $Computername){


# Define the SSH session
$session = New-PSSession -HostName $Computer -UserName $user -KeyFilePath $KeyFilePath -verbose

# Define the command to run the Bash script with sudo

$command = "./update.sh"

# Execute the command on the remote Linux machine
Invoke-Command -Session $session -ScriptBlock { param($cmd, $cred) $env:PS_PASSWORD = $cred.GetNetworkCredential().Password; &echo $env:PS_PASSWORD | sudo -S $cmd } -ArgumentList $command, $credential -verbose

# Close the SSH session
Remove-PSSession -Session $session

}


