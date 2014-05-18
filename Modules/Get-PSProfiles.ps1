﻿# OUTPUT zip
<#
.SYNOPSIS
Get-PowershellProfiles.ps1
Grabs copies of Powershell profiles, both users specific and default
#>

function add-zip
{
    param([string]$zipfilename)

    if (-not (Test-Path($zipfilename))) {
        Set-Content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
        (dir $zipfilename).IsReadOnly = $false
    }

    $shellApplication = New-Object -com shell.application
    $zipPackage = $shellApplication.NameSpace($zipfilename)

    foreach($file in $input) {
        $zipPackage.CopyHere($file.FullName)
        Start-Sleep -milliseconds 100
    }
}


$zipfile = (($env:TEMP) + "\" + ($env:COMPUTERNAME) + "-PSProfiles.zip")
if (Test-Path $zipfile) { rm $zipfile -Force }

foreach($path in (Get-WmiObject win32_userprofile | select -ExpandProperty LocalPath)) {
    $prfile = ($path + "\Documents\WindowsPowershell\Microsoft.Powershell_profile.ps1")
    if (Test-Path $prfile) {
        $thisProfile = ((Split-Path -Leaf $path) + "_" + "Microsoft.Powershell_profile.ps1")
        $suppress = Copy-Item $prfile $env:TEMP\$thisProfile
        ls $env:TEMP\$thisprofile | add-zip $zipfile
        Remove-Item $env:TEMP\$thisProfile -Force
    }
}

$alluserprofile = ($env:windir + "\System32\WindowsPowershell\v1.0\Microsoft.Powershell_profile.ps1")
if (Test-Path $alluserprofile) {
"passed the test"
    $thisProfile = "Default_Microsoft.Powershell_profile.ps1"
    $suppress = Copy-Item $alluserprofile $env:TEMP\$thisProfile
    ls $env:TEMP\$thisprofile | add-zip $zipfile
    Remove-Item $env:TEMP\$thisProfile -Force
}

Get-Content -Encoding Byte -Raw $zipfile
$suppress = Remove-Item $zipfile