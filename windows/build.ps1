# Build for SGX
# |- Legacy
#    |- Debug
#    |- Release
# |- FLC
#    |- Debug
#    |- Release

$ErrorActionPreference = "Stop"

If (-not (Test-Path -Path SDK))
{
    git clone --recursive --depth=1 https://github.com/openenclave/openenclave SDK
}

$SDK_PATH = (Join-Path -Path $PWD -ChildPath SDK)

If (Test-Path Build)
{
    Remove-Item Build -Recurse -Force
}

New-Item -ItemType Directory -Path Build\Legacy\Debug | Out-Null
New-Item -ItemType Directory -Path Build\Legacy\Release | Out-Null
New-Item -ItemType Directory -Path Build\FLC\Debug | Out-Null
New-Item -ItemType Directory -Path Build\FLC\Release | Out-Null

Push-Location -Path Build\Legacy\Debug
cmake $SDK_PATH -G Ninja -DNUGET_PACKAGE_PATH=C:\oe_prereqs -DBUILD_ENCLAVES=ON -DCPACK_GENERATOR=NuGet -DHAS_QUOTE_PROVIDER=OFF -DCMAKE_BUILD_TYPE=Debug
ninja
cpack.exe -D CPACK_NUGET_COMPONENT_INSTALL=ON -DCPACK_COMPONENTS_ALL=OEHOSTVERIFY
cpack.exe
Pop-Location

Push-Location -Path Build\Legacy\Release
cmake $SDK_PATH -G Ninja -DNUGET_PACKAGE_PATH=C:\oe_prereqs -DBUILD_ENCLAVES=ON -DCPACK_GENERATOR=NuGet -DHAS_QUOTE_PROVIDER=OFF -DCMAKE_BUILD_TYPE=Release
ninja
cpack.exe -D CPACK_NUGET_COMPONENT_INSTALL=ON -DCPACK_COMPONENTS_ALL=OEHOSTVERIFY
cpack.exe
Pop-Location

Push-Location -Path Build\FLC\Debug
cmake $SDK_PATH -G Ninja -DNUGET_PACKAGE_PATH=C:\oe_prereqs -DBUILD_ENCLAVES=ON -DCPACK_GENERATOR=NuGet -DHAS_QUOTE_PROVIDER=ON -DCMAKE_BUILD_TYPE=Debug
ninja
cpack.exe -D CPACK_NUGET_COMPONENT_INSTALL=ON -DCPACK_COMPONENTS_ALL=OEHOSTVERIFY
cpack.exe
Pop-Location

Push-Location -Path Build\FLC\Release
cmake $SDK_PATH -G Ninja -DNUGET_PACKAGE_PATH=C:\oe_prereqs -DBUILD_ENCLAVES=ON -DCPACK_GENERATOR=NuGet -DHAS_QUOTE_PROVIDER=ON -DCMAKE_BUILD_TYPE=Release
ninja
cpack.exe -D CPACK_NUGET_COMPONENT_INSTALL=ON -DCPACK_COMPONENTS_ALL=OEHOSTVERIFY
cpack.exe
Pop-Location
