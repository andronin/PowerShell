<#
.SYNOPSIS
Some automation to get Cisco UCS Techsupport for one or many UCS Domains and or chassis
.DESCRIPTION
Get UCS UCSTechsupport files
.PARAMETER UCS_Domains
A single or list of UCS domains to connect to. Can also be an array
.PARAMETER Credentials
Credentials used to connect to the UCS domains
.PARAMETER basePath
Path to save the TechSupport files to
.PARAMETER ChassisIDs
A single or list of UCS Chassis ID's to collect Techsupport files from. Can also be an array. If nothing specified all chassis will be collected
.INPUTS
None You cannot pipe to this command
.OUTPUTS
Techsupport files to the basePath\UCS_Domain\TechSupport\SRNumber
.EXAMPLE
This will save the Techsupport files under
    C:\Path\To\Save\Techsupport\fc01.UCS.f.q.d.n\TechSupport\SR123456789
for every chassis on the UCS Domain
.\UcsTechSupport.ps1 -UCS_Domains fc01.UCS.f.q.d.n -Credentials (Get-Credential) -basePath 'C:\Path\To\Save\Techsupport' -TACCaseID "123456789"
.EXAMPLE
Below will collect the Techsupport files for the UCS Domains in the array, and and for Chassis 1, 3 and 7
$UCS_Domains = "fc01.UCS.f.q.d.n","fc02.UCS.f.q.d.n","fc03.UCS.f.q.d.n"
.\UcsTechSupport.ps1 -UCS_Domains $UCS_Domains -Credentials (Get-Credential) -basePath 'C:\Path\To\Save\Techsupport' -ChassisIDs 1,3,7 -TACCaseID "123456789"
.EXAMPLE
Below will collect the Techsupport files for the UCS Domains in the array, and and for ALL attached Chassis
$UCS_Domains = "fc01.UCS.f.q.d.n","fc02.UCS.f.q.d.n","fc03.UCS.f.q.d.n"
.\UcsTechSupport.ps1 -UCS_Domains $UCS_Domains -Credentials (Get-Credential) -basePath 'C:\Path\To\Save\Techsupport' -TACCaseID "123456789"

.LINK
https://www.kimwhite.co.za
#>

param(
    [Parameter(Mandatory=$true)]
    [string[]]$UCS_Domains,
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.CredentialAttribute()] $Credentials = (get-credential),
    [Parameter(Mandatory=$false)]
    [string[]]$ChassisIDs,
    [Parameter(Mandatory=$true)]
    [string]$basePath,
    [Parameter(Mandatory=$false)]
    [string]$TACCaseID
)

function Collect-UCSTechsupport
{    
param(
    [Parameter(Mandatory=$true)]
    [string[]]$UCS_Domain,
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.CredentialAttribute()] $Credentials,
    [Parameter(Mandatory=$true)]
    [string]$basePath
)
#>
    $TimeStamp = Get-Date -Format yyyyMMdd_hhmmm
    Connect-Ucs -Name $UCS_Domain -Credential $Credentials | Out-Null
    if ( $TACCaseID ) { $basePath = $basePath + "\$UCS_Domain\TechSupport\SR$TACCaseID" }
    else { $basePath = $basePath + "\$UCS_Domain\TechSupport" }
    if ( ! (Get-ChildItem $basePath -ErrorAction SilentlyContinue )  ) { New-Item -Path $basePath -ItemType Directory -Force }
    Write-Host -ForegroundColor Cyan $basePath
    Write-Host -ForegroundColor Cyan "Collecting UcsManager"
    Get-UcsTechSupport -UcsManager -PathPattern "$basePath\UcsManager_$TimeStamp.tar" -RemoveFromUcs
    Write-Host -ForegroundColor Cyan "Collecting UcsMgmt"
    Get-UcsTechSupport -UcsMgmt -PathPattern "$basePath\UcsMgmt_$TimeStamp.tar" -RemoveFromUcs
    if ( $ChassisIDs )
    {
        foreach ( $UCSChassis in $ChassisIDs )
        {
            Write-Host -ForegroundColor Cyan "Collecting Chassis" $UCSChassis
            Get-UcsTechSupport -ChassisId $UCSChassis -CimcId all -PathPattern  "$basePath\Chassis-${UCSChassis}_$TimeStamp.tar" -RemoveFromUcs
        }
    }
    else
    {
        foreach ( $UCSChassis in ( Get-UcsChassis | ForEach-Object Id ) )
        {
            Write-Host -ForegroundColor Cyan "Collecting Chassis" $UCSChassis
            Get-UcsTechSupport -ChassisId $UCSChassis -CimcId all -PathPattern  "$basePath\Chassis-${UCSChassis}_$TimeStamp.tar" -RemoveFromUcs
        }
    }
    Disconnect-Ucs  -Verbose
}
Disconnect-Ucs  -Verbose

foreach ( $UCS_Domain in $UCS_Domains ) { Collect-UCSTechsupport -UCS_Domain $UCS_Domain -Credentials $Credentials -basePath $basePath }