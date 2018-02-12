# Instructions:
#     - Create a folder named "cpsc-24500-video-java-introduction"
#     - Add index.html, index.css, web.config, and at least one mp4 recording
#     - Make a scripts folder and add this ps1 file to the folder
#     - Make the folder a Git repository ("git init .")
#     - Add the index.html, index.css, web.config, and mp4 files ("git add ...)
#     - Add the scripts folder ("git add ...)
#     - Commit revision (git commit -a -m "Add initial files.")
#     - Run this script
[CmdletBinding()]
Param(
  [Parameter()]
    [switch]$production = $false
)

Import-Module $EJPLibraryPathName -Force
Write-Host 'Executing:'$PSCommandPath
$ProductionAppName="sp18-cpsc-24500-001-video"
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

$VerifyContinue = Read-Host "Do you wish to continue creating the site with the above parameters? [y/n]"
if ($VerifyContinue -ne "y") {
    Exit-WithMessage("User cancelled.")
}

# Create a resource group.
New-AzureRmResourceGroup -Name $ResourceGroup -Location $Location

# Create an App Service plan in `Free` tier.
New-AzureRmAppServicePlan -Name $AppServicePlanName -Location $Location -ResourceGroupName $ResourceGroup -Tier Free

# Create a web app.
New-AzureRmWebApp -Name $WebAppName -Location $Location -AppServicePlan $AppServicePlanName -ResourceGroupName $ResourceGroup

# Configure GitHub deployment from your GitHub repo and deploy once.
$PropertiesObject = @{
    scmType = "LocalGit";
}
Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $ResourceGroup `
-ResourceType Microsoft.Web/sites/config -ResourceName $WebAppName/web `
-ApiVersion 2015-08-01 -Force

# Get app-level deployment credentials
$xml = [xml](Get-AzureRmWebAppPublishingProfile -Name $WebAppName -ResourceGroupName $ResourceGroup `
-OutputFile null)
$username = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userName").value
$password = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userPWD").value

# Add the Azure remote to your local Git respository and push your code
#### This method saves your password in the git remote. You can use a Git credential manager to secure your password instead.
git remote add azure "https://${username}:$password@$WebAppName.scm.azurewebsites.net"
git push azure master

# Don't forget to 'git remote remove azure' and delete the Resource group in order to redeploy with script.

Write-Host
Write-Host "Hints:" -foregroundcolor "Yellow"
Write-Host "  git commit -a -m 'Update index.html.'" -foregroundcolor "Yellow"
Write-Host "  git push" -foregroundcolor "Yellow"
Write-Host "  git push azure master" -foregroundcolor "Yellow"
Write-Host "  Get-AzureRmResourceGroup" -foregroundcolor "Yellow"
Write-Host "  git remote remove azure" -foregroundcolor "Yellow"
Write-Host "  Remove-AzureRmResourceGroup $ResourceGroup" -foregroundcolor "Yellow"

