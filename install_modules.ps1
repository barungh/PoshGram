<#
.SYNOPSIS
    This script is used in AWS CodeBuild to install the required PowerShell Modules for the build process.
.DESCRIPTION
    The version of PowerShell being run will be identified. This may vary depending on what type of build
    container you are running and if your buildspec is installing various versions of PowerShell. You will
    need to specify each module and version that is required for installation. You also need to specify
    which version of that module should be installed. Additionally, you will need to specify the S3 bucket
    location where that module currently resides, so that it can be downloaded and installed into the build
    container at runtime. This necessitates that you download and upload your required modules to S3 prior to
    the build being executed.
.EXAMPLE
    Save-Module -Name Pester -RequiredVersion 4.4.5 -Path C:\RequiredModules
    Create an S3 bucket in your AWS account
    Zip the contents of the Pester Module up (when done properly the .psd1 of the module should be at the root of the zip)
    Name the ZIP file Pester_4.4.4 (adjust version as needed) unless you want to modify the logic below
    Upload the Pester Zip file up to S3 bucket you just created
.NOTES
    Alternatively, you can source PowerShell modules from the PSGallery although this is quite a bit slower
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'

$galleryDownload = $false # set to false to download from S3

# List of PowerShell Modules required for the build
# The AWS PowerShell Modules are added below, based on the $PSEdition
$modulesToInstall = [System.Collections.ArrayList]::new()
$null = $modulesToInstall.Add(([PSCustomObject]@{
            ModuleName    = 'Pester'
            ModuleVersion = '5.3.3'
            BucketName    = 'ps-invoke-modules'
            KeyPrefix     = ''
        }))
$null = $modulesToInstall.Add(([PSCustomObject]@{
            ModuleName    = 'InvokeBuild'
            ModuleVersion = '5.9.10'
            BucketName    = 'ps-invoke-modules'
            KeyPrefix     = ''
        }))
$null = $modulesToInstall.Add(([PSCustomObject]@{
            ModuleName    = 'PSScriptAnalyzer'
            ModuleVersion = '1.20.0'
            BucketName    = 'ps-invoke-modules'
            KeyPrefix     = ''
        }))
$null = $modulesToInstall.Add(([PSCustomObject]@{
            ModuleName    = 'platyPS'
            ModuleVersion = '0.12.0'
            BucketName    = 'ps-invoke-modules'
            KeyPrefix     = ''
        }))
$null = $modulesToInstall.Add(([PSCustomObject]@{
            ModuleName    = 'AWS.Tools.Common'
            ModuleVersion = '4.1.98'
            BucketName    = 'ps-invoke-modules'
            KeyPrefix     = ''
        }))
$null = $modulesToInstall.Add(([PSCustomObject]@{
            ModuleName    = 'AWS.Tools.SecretsManager'
            ModuleVersion = '4.1.98'
            BucketName    = 'ps-invoke-modules'
            KeyPrefix     = ''
        }))

$tempPath = [System.IO.Path]::GetTempPath()

if ($PSVersionTable.Platform -eq 'Win32NT') {
    $moduleInstallPath = [System.IO.Path]::Combine($env:ProgramFiles, 'WindowsPowerShell', 'Modules')
    if ($PSEdition -eq 'Core') {
        $moduleInstallPath = [System.IO.Path]::Combine($env:ProgramFiles, 'PowerShell', 'Modules')
    }
    else {
        $moduleInstallPath = [System.IO.Path]::Combine($env:ProgramFiles, 'WindowsPowerShell', 'Modules')
    }
}
elseif ($PSVersionTable.Platform -eq 'Unix') {
    $moduleInstallPath = [System.IO.Path]::Combine('/', 'usr', 'local', 'share', 'powershell', 'Modules')
}
elseif ($PSEdition -eq 'Desktop') {
    $moduleInstallPath = [System.IO.Path]::Combine($env:ProgramFiles, 'WindowsPowerShell', 'Modules')
}
else {
    throw 'Unrecognized OS platform'
}

if ($galleryDownload -eq $false) {
    'Installing PowerShell Modules from S3'
    foreach ($module in $modulesToInstall) {
        '  - {0} {1}' -f $module.ModuleName, $module.ModuleVersion

        # Download file from S3
        $key = '{0}_{1}.zip' -f $module.ModuleName, $module.ModuleVersion
        $localFile = Join-Path -Path $tempPath -ChildPath $key

        # Download modules from S3 to using the AWS CLI
        #note: remove --quiet for more verbose output or if S3 download troubleshooting is needed
        $s3Uri = 's3://{0}/{1}{2}' -f $module.BucketName, $module.KeyPrefix, $key
        & aws s3 cp $s3Uri $localFile --quiet

        # Ensure the download worked
        if (-not(Test-Path -Path $localFile)) {
            $message = 'Failed to download {0}' -f $module.ModuleName
            "  - $message"
            throw $message
        }

        # Create module path
        $modulePath = Join-Path -Path $moduleInstallPath -ChildPath $module.ModuleName
        $moduleVersionPath = Join-Path -Path $modulePath -ChildPath $module.ModuleVersion
        $null = New-Item -Path $modulePath -ItemType 'Directory' -Force
        $null = New-Item -Path $moduleVersionPath -ItemType 'Directory' -Force

        # Expand downloaded file
        Expand-Archive -Path $localFile -DestinationPath $moduleVersionPath -Force
    }
} #if_GalleryDownload
else {
    Get-PackageProvider -Name Nuget -ForceBootstrap | Out-Null
    'Installing PowerShell Modules from PSGallery'
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    # $NuGetProvider = Get-PackageProvider -Name "NuGet" -ErrorAction SilentlyContinue
    # if ( -not $NugetProvider ) {
    #     Install-PackageProvider -Name "NuGet" -Confirm:$false -Force -Verbose
    # }
    foreach ($module in $modulesToInstall) {
        try {
            if ($module.ModuleName -eq 'Pester' -and $PSEdition -eq 'Desktop') {
                Install-Module $module.ModuleName -RequiredVersion $module.ModuleVersion -Repository PSGallery -Force -SkipPublisherCheck -ErrorAction Stop
            }
            else {
                Install-Module $module.ModuleName -RequiredVersion $module.ModuleVersion -Repository PSGallery -Confirm:$false -Force -ErrorAction Stop
            }
        }
        catch {
            $message = 'Failed to install {0}' -f $module.ModuleName
            "  - $message"
            throw $_
        }
    }
}
