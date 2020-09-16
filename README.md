# Cross-Platform Open Enclave SDK NuGet Package

This repository contains the scripts used to build a cross-platform NuGet
package for the Open Enclave SDK. The resulting package may be used on Windows
to build SGX enclaves as well as on Linux to build SGX and OP-TEE enclaves for
the Scalys Grapeboard (LS-1012A) and QEMU ARMv8.

The SGX builds are suitable both for SGX1 systems as well as for systems that
support FLC. All SGX builds contain enclave libraries with and without LVI
mitigations.

## Environment Setup

Two build systems are required: the first must run Windows Server 2019 with GUI
and the second must run Ubuntu 18.04 LTS or later (Desktop and Server are both
OK). These two environments may exist on physical systems or in virtual
machines, it does not matter.

This section explains how to set up both environments.

### Windows Server 2019

1. Install Windows Server 2019 with GUI.
2. Download the SDK's [Windows prerequisites installation
   script](https://github.com/openenclave/openenclave/blob/master/scripts/install-windows-prereqs.ps1).
3. If present, comment out the line in the script that starts with:
   ```powershell
   New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\sgx_lc_msr\Parameters" [...]
   ```
4. Execute the script as follows:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   .\install-windows-prereqs.ps1 -InstallPath C:/oe_prereqs -LaunchConfiguration SGX1FLC-NoIntelDrivers -DCAPClientType None
   ```
5. When prompted, reboot the system.

### Ubuntu

1. Run `setup-host.sh`, accepting the LXD initialization defaults.
2. Log out and log back in.
3. Run `setup-containers.sh` to create and start the containers used for
   building; unlike Docker containers, these remain running in the background
   and have persistent storage; think of them as virtual machines instead of
   containers.
4. Clone the SDK:
   ```bash
   git clone -b v0.11.0-rc1 --recursive --depth=1 https://github.com/openenclave/openenclave sdk
   ```
5. Open `scripts/ansible/oe-contributors-setup.yml` and comment out the step
   that installs the Intel SGX driver because drivers cannot be installed inside
   containers.
6. Install the prerequisites in each container:
   ```bash
   # Enter the Xenial container.
   lxc exec oepkgxenial su ubuntu

   cd /host/path/to/sdk
   sudo scripts/ansible/install-ansible.sh
   ansible-playbook scripts/ansible/oe-contributors-setup-cross-arm.yml

   sudo apt install python3-pip p7zip-full -y
   pip3 install pycryptodome

   # Quit the Xenial container.
   exit

   # Enter the Bionic container.
   lxc exec oepkgbionic su ubuntu

   cd /host/path/to/sdk
   sudo scripts/ansible/install-ansible.sh
   ansible-playbook scripts/ansible/oe-contributors-setup-cross-arm.yml
   sudo apt install python3-pyelftools p7zip-full -y

   # Quit the Bionic container.
   exit
   ```

## Building

### Windows

To build the SDK in all its configurations:

1. Launch the x64 Native Tools Command Prompt for VS 2017 from the Start menu.
2. Run:
   ```cmd
   cd %SYSTEMDRIVE%\path\to\this\repository\windows
   powershell -c "Set-ExecutionPolicy Bypass -Scope Process; .\build.ps1"
   powershell -c "Set-ExecutionPolicy Bypass -Scope Process; .\pack.ps1"
   ```

This creates a `Pack` directory with the build outputs.

### Ubuntu
To build the SDK in all its configurations, run:

```bash
cd /path/to/this/repository/linux
./driver.sh
./pack.sh
```

This creates a `pack` directory with the build outputs.

## Packaging

Fetch the resulting `pack` directories from both environments and merge their
contents. This can be achieved by copying the contents of one folder into the
other; there are no files that overlap.

Then, copy the contents of the `extras` directory in this repository into the
root of the combined `pack` directory. Update the version information insde
`open-enclave-cross.nuspec` if necessary.

Lastly, create a `licenses` directory inside the merged `pack` directory and
copy into it the following two files from the SDK:

1. `LICENSE`
2. `THIRD_PARTY_NOTICES`

To create the NuGet package, navigate to the root of the merged `pack` directory
and run:

```
# The extension informs 7z as to the type of archive to create.
7z a -mm=Deflate -mx=9 -mmt=8 -mfb=258 -mpass=15 -r out.zip .
mv out.zip open-enclave-cross.0.11.0-rc1-cbe4dedc-1.nupkg
```

updating the output file name and the value of `-mmt=` to the number of logical
cores on your system as necessary. Note that using 7-Zip in this manner instead
of the official `nuget` tool is necessary to ensure that the resulting `.nupkg`
is below the maximum allowed file size in `nuget.org` (and to not make users
download a file five times the size).
