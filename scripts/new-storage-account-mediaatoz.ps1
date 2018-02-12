$ResourceGroupName = 'mediaatoz-rg'
# Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.
$StorageAccountName = 'mediaatoz'

Write-Host "Creating Azure storage account ($StorageAccountName). Please be patient."
New-AzureRMStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -SkuName "Standard_LRS" -Location "Central US" -Kind "BlobStorage" -AccessTier "hot"
