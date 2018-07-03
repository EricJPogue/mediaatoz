[CmdletBinding()]
Param(
  [Parameter()]
    [switch]$production = $false
)

Write-Host 'Executing:'$PSCommandPath
Import-Module $EJPLibraryPathName -Force

$ProductionAppName="mediaatoz"
$WebAppName="$ProductionAppName-test-$(Get-Random)"
If ($production) {
    # WARNING: There will be a delay before the web app name can be reused once it is removed.
    #     This will cause an error in the script if it is run too quickly.
    $WebAppName=$ProductionAppName
    Write-Host "Deploying production site."$WebAppName
}

$AppServicePlanName = "$ProductionAppName-sp"
$ResourceGroup = "$ProductionAppName-rg"
$Location="Central US"

Write-Host
Write-Host "Production Application Name: $ProductionAppName"
Write-Host "Deployment Application Name: $WebAppName"
Write-Host "Service Plane Name:          $AppServicePlanName"
Write-Host "Resource Group Name:         $ResourceGroup"
Write-Host "Hosting Location:            $Location"
Write-Host "Hosted URL:                  $WebAppName.azurewebsites.net"
Write-Host
Write-Host "Azure Context Information:"  
Get-AzureRmContext

$VerifyContinue = Read-Host "Do you wish to continue creating a new Git remote with the above parameters? [y/n]"
if ($VerifyContinue -ne "y") {
    Exit-WithMessage("User cancelled.")
}

# Get app-level deployment credentials
$xml = [xml](Get-AzureRmWebAppPublishingProfile -Name $WebAppName -ResourceGroupName $ResourceGroup `
-OutputFile null)
$username = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userName").value
$password = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userPWD").value

# Add the Azure remote to your local Git respository and push your code
#### This method saves your password in the git remote. You can use a Git credential manager to secure your password instead.
git remote add azure "https://${username}:$password@$WebAppName.scm.azurewebsites.net"
git push azure master
