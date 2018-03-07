[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$FileName
)

$ResourceGroupName = 'mediaatoz-rg'
$StorageAccountName = 'mediaatoz'
$ContainerName = 'transfer'

$BlobFileName = $FileName

$StorageKey = Get-AzureRMStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageKey[0].Value
Set-AzureStorageBlobContent -Context $StorageContext -Container $ContainerName -File $FileName -Blob $BlobFileName