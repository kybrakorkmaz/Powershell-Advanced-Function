<#
.Synopsis
   Obtaining information about system of personal computer.
.DESCRIPTION
   Obtaining information about operating sistem, computer system and
   bios of the personal computer, and if the user want to save information into
   a text file then, user have to active "save" switch 
   after that thoese information will be saved into text file.
   If the user does not want to save those information,
   "FileName" mandatory must be false. 

.PARAMETER ComputerName
    Obtain hostname from user, or user can use the name inside of the validateset
    Parameter mandatory

.PARAMETER save
    Save is a switch parameter, default value is false. If user active this switch
    information of the computer will be saved into the text file

.PARAMETER FileName
    Obtaining filename from user, where all information will be saved.
    Parameter Mandatory
    ValuefromPipeline 
    
.EXAMPLE
   Get-ComputerInformation -ComputerName DESKTOP-J1GT1U6 -save -ErrorAction SilentlyContinue
   
   cmdlet Get-ComputerInformation at command pipeline position 1
    Supply values for the following parameters:
    (Type !? for Help.)
    FileName: information


    Domain                 : WORKGROUP
    OperatingSystemVersion : 10.0.19043
    BuildNumber            : 19043
    Manufacturer           : LENOVO
    BIOSSerialNumber       : PF16UMPR
    ComputerName           : DESKTOP-J1GT1U6
    BIOSVersion            : LENOVO - 1
    OSSerialNumber         : 00330-80000-00000-AA382
    Model                  : 81FK
    RegisteredUser         : Lenovo
    OperatingSystem        : Microsoft Windows 10 Pro

    LastWriteTime : 22.10.2022 13:22:31
    Length        : 0
    Name          : information.txt

.EXAMPLE
   Get-ComputerInformation -ComputerName DESKTOP-J1GT1U6 -FileName $false

    Domain                 : WORKGROUP
    OperatingSystemVersion : 10.0.19043
    BuildNumber            : 19043
    Manufacturer           : LENOVO
    BIOSSerialNumber       : PF16UMPR
    ComputerName           : DESKTOP-J1GT1U6
    BIOSVersion            : LENOVO - 1
    OSSerialNumber         : 00330-80000-00000-AA382
    Model                  : 81FK
    RegisteredUser         : Lenovo
    OperatingSystem        : Microsoft Windows 10 Pro
#>

Function Get-ComputerInformation
{
[cmdletBinding()]
param(
[parameter(Mandatory=$true)]
[ValidateSet('DESKTOP-J1GT1U6')] #write your own hostname
[string]$ComputerName,

[parameter()]
[switch]$save=$false,

[parameter(Mandatory = $true, ValueFromPipeline=$true, HelpMessage = 'Please enter a text file name:')]
[string]$FileName
)

#computer system
$ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName

#operating Sytem
$OperatingSystem = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName

#BIOS
$Bios = Get-WmiObject -Class Win32_BIOS -ComputerName $ComputerName

# Prepare Output
$Properties = @{
ComputerName=$ComputerName
Domain = $ComputerSystem.Domain
Manufacturer = $ComputerSystem.Manufacturer
Model=$ComputerSystem.Model
########
OperatingSystem=$OperatingSystem.Caption
OperatingSystemVersion = $OperatingSystem.Version
BuildNumber=$OperatingSystem.BuildNumber
RegisteredUser=$OperatingSystem.RegisteredUser
OSSerialNumber=$OperatingSystem.SerialNumber
########
BIOSSerialNumber = $Bios.SerialNumber
BIOSVersion = $Bios.Version
}

#Output Information
New-Object -TypeName PSobject -Property $Properties

if($save.IsPresent)
{
   if( Test-Path -Path "$($FileName).txt" -PathType Leaf){
        $Properties > "$($FileName).txt"
        Invoke-Item "$($FileName).txt"
   }
   else{
        Write-Error -Exception ([System.IO.FileNotFoundException]::new("Could not find path: $Path")) -ErrorAction $ErrorActionPreference
        if($ErrorActionPreference -eq "SilentlyContinue"){
            New-Item -Path "$($FileName).txt"
            $Properties > "$($FileName).txt"
            Invoke-Item "$($FileName).txt"
        }
   }
}

}
