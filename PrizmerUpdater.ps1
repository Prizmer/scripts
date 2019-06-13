
Write-Host "Welcome to PRIZMER updater!"

$subversionModuleVersion = Get-Module -ListAvailable -Name "Subversion" | Format-List -Property Version | Out-String
$subversionModuleVersion = $subversionModuleVersion.Trim().ToLower()
if ($subversionModuleVersion) {
    Write-Host "Subversion module exists, $subversionModuleVersion"
    Write-Host ""
} 
else 
{
    Write-Host "No subversion module, installing... "
    Install-Module -Name "Subversion" -Force -AllowClobber
    Write-Host "Ready!"
    Write-Host ""
}

$ghUserName = "Prizmer"
$ghPublicApiUrl = "https://api.github.com/orgs/$ghUserName/repos?per_page=1000"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$repositoriesInfo = Invoke-RestMethod -Uri $ghPublicApiUrl -Method GET

Write-Host "Availiable repositories:"
$counter = 0;
foreach ($repository in $repositoriesInfo) {
    Write-Host "$counter. "$repository.name
    $counter++;
}

$repositoryIndex = Read-Host -Prompt 'Input repository index to install'
$repositoryName = $repositoriesInfo[$repositoryIndex].name
$projectName = $repositoriesInfo[$repositoryIndex].description

$remoteURL = "https://github.com/$ghUserName/$repositoryName/trunk/";
if ($projectName) {
    $fullProjectPrompt = Read-Host -Prompt 'Enter F to download full project'
    $res = $fullProjectPrompt -eq 'F'
    if (!$res) {
        $remoteURL = "https://github.com/$ghUserName/$repositoryName/trunk/$projectName/bin/Debug/";
    }
}

$targetDirectory = "C:\$ghUserName\$repositoryName"

Write-Host ""
Write-Host "Source URL: $remoteURL"
Write-Host "Target directory: $targetDirectory "
Write-Host ""

if (Test-Path $targetDirectory) {
    Remove-Item -LiteralPath $targetDirectory -Force -Recurse
}

# download target dirrectory recursively
svn export $remoteURL $targetDirectory --force

Invoke-Item $targetDirectory