$ErrorActionPreference = "Stop"

$LibCopyRules = @(
    New-Object PSObject -Property @{Source="$PWD\Build\Legacy\Debug";Destination="$PWD\Pack\lib\native\win\sgx\legacy\debug"}
    New-Object PSObject -Property @{Source="$PWD\Build\Legacy\Release";Destination="$PWD\Pack\lib\native\win\sgx\legacy\release"}

    New-Object PSObject -Property @{Source="$PWD\Build\FLC\Debug";Destination="$PWD\Pack\lib\native\win\sgx\flc\debug"}
    New-Object PSObject -Property @{Source="$PWD\Build\FLC\Release";Destination="$PWD\Pack\lib\native\win\sgx\flc\release"}
)

If (Test-Path Pack)
{
    Remove-Item Pack -Recurse -Force
}

Function Get-LibsByGlob([String]$Glob)
{
    Get-ChildItem -Recurse $Glob |
        Where-Object { -Not ($_.FullName.Contains("tests") -or $_.FullName.Contains("tools") -or $_.FullName.Contains("debugger")) }
}

Function Get-EnclaveLibs()
{
    Get-LibsByGlob *.a
}

Function Get-HostLibs()
{
    Get-LibsByGlob *.lib
}

Function Copy-Tools([String]$SgxPlatform)
{
    Push-Location $PWD\Build\$SgxPlatform\Release\_CPack_Packages\win64\NuGet
    $Bin = (Get-ChildItem -Recurse bin)
    Pop-Location
    Copy-Item -Path "$($Bin.FullName)\*" -Destination .\Pack\tools\win\legacy -Recurse -Force
}

Function Copy-Includes([String]$SgxPlatform, [String]$BuildType)
{
    Push-Location $PWD\Build\$SgxPlatform\$BuildType\_CPack_Packages\win64\NuGet
    $Inc = (Get-ChildItem -Recurse include)
    Pop-Location

    Copy-Item -Path $Inc.FullName -Destination .\Pack\build\native\win\sgx\$SgxPlatform\$BuildType\ -Recurse -Force
}


New-Item -ItemType Directory -Path Pack\build\native\win\sgx\legacy\debug | Out-Null
New-Item -ItemType Directory -Path Pack\build\native\win\sgx\legacy\release | Out-Null

New-Item -ItemType Directory -Path Pack\build\native\win\sgx\flc\debug | Out-Null
New-Item -ItemType Directory -Path Pack\build\native\win\sgx\flc\release | Out-Null


New-Item -ItemType Directory -Path Pack\lib\native\win\sgx\legacy\debug\enclave\clang-7 | Out-Null
New-Item -ItemType Directory -Path Pack\lib\native\win\sgx\legacy\debug\host\msvc-14.16.27023 | Out-Null

New-Item -ItemType Directory -Path Pack\lib\native\win\sgx\legacy\release\enclave\clang-7 | Out-Null
New-Item -ItemType Directory -Path Pack\lib\native\win\sgx\legacy\release\host\msvc-14.16.27023 | Out-Null


New-Item -ItemType Directory -Path Pack\lib\native\win\sgx\flc\debug\enclave\clang-7 | Out-Null
New-Item -ItemType Directory -Path Pack\lib\native\win\sgx\flc\debug\host\msvc-14.16.27023 | Out-Null

New-Item -ItemType Directory -Path Pack\lib\native\win\sgx\flc\release\enclave\clang-7 | Out-Null
New-Item -ItemType Directory -Path Pack\lib\native\win\sgx\flc\release\host\msvc-14.16.27023 | Out-Null


New-Item -ItemType Directory -Path Pack\tools\win\legacy | Out-Null
New-Item -ItemType Directory -Path Pack\tools\win\flc | Out-Null


$LibCopyRules | ForEach-Object {
    Push-Location $_.Source
    $EnclaveLibs = Get-EnclaveLibs
    $HostLibs = Get-HostLibs
    Copy-Item -Path $EnclaveLibs -Destination (Join-Path -Path $_.Destination -ChildPath enclave\clang-7)
    Copy-Item -Path $HostLibs -Destination (Join-Path -Path $_.Destination -ChildPath host\msvc-14.16.27023)
    Pop-Location
}

Copy-Includes Legacy Debug
Copy-Includes Legacy Release
Copy-Includes FLC Debug
Copy-Includes FLC Release

Copy-Tools Legacy
Copy-Tools FLC
