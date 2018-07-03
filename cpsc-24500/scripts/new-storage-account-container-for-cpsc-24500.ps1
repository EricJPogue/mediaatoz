$ResourceGroupName = 'mediaatoz-rg'
$StorageAccountName = 'mediaatoz'
$ContainerName = 'cpsc-24500'

$StorageKey = Get-AzureRMStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageKey[0].Value

Write-Host "Creating Azure storage account container ($ContainerName)."
New-AzureStorageContainer -Context $StorageContext -Name $ContainerName -Permission Container
