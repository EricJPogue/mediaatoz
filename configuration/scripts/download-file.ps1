[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$FileName
)

$ResourceGroupName = 'mediaatoz-rg'
$StorageAccountName = 'mediaatoz'
$ContainerName = 'environment-configuration'

$BlobFileName = $FileName

$StorageKey = Get-AzureRMStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageKey[0].Value

Get-AzureStorageBlobContent -Blob $BlobFileName -Container $containerName -Destination ".\" -Context $StorageContext 