Function New-CIUser {
    <#
    .DESCRIPTION
        Unlock vCloud Director user account
    .PARAMETER Name
        The user name to unlock
    .PARAMETER Org
        The ORG the user exists in
    .PARAMETER FullName
        Full name of the User
    .PARAMETER Role
        The VCD Role of the User
            Catalog Author, Cloud User, Console Access Only, Organization Administrator, Support, System Administrator, vApp Author, vApp User
    .PARAMETER Enabled
        Setting this will enable the account, otherwise account will be created in a disabled state
    .PARAMETER Password
        If you do not set a password a 15 character one will be created using the New-Password module

    .EXAMPLE
        New-CIUser -Name $UserName -FullName $FullName -Password (New-Password -PasswordLength 10) -Org $myOrg -Role "Organization Administrator" -Enabled
    #>
    
    Param (
        $Name,
        $Password,
        $FullName,
        [switch]$Enabled,
        $Org,
        $Role
    )
    Process {
        try {
            $Org = Get-Org $Org
            $OrgED = $Org.ExtensionData
            $orgAdminUser = New-Object VMware.VimAutomation.Cloud.Views.User
            $orgAdminUser.Name = $Name
            $orgAdminUser.FullName = $FullName
            if ( $Password ) { $orgAdminUser.Password = $Password } else { $orgAdminUser.Password = ( New-Password -PasswordLength 15 ) }
            $orgAdminUser.IsEnabled = $Enabled
            $vcloud = $DefaultCIServers[0].ExtensionData
            $orgAdminRole = $vcloud.RoleReferences.RoleReference | where {$_.Name -eq $Role}
            $orgAdminUser.Role = $orgAdminRole
            $user = $orgED.CreateUser($orgAdminUser)
            $object = New-Object psobject
            $object | Add-Member -MemberType NoteProperty -Name "Name" -Value $Name
            $object | Add-Member -MemberType NoteProperty -Name "Full Name" -Value $FullName
            $object | Add-Member -MemberType NoteProperty -Name "Password" -Value $Password
            $object | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $Enabled
            $object | Add-Member -MemberType NoteProperty -Name "Org" -Value $Org.Name
            $object | Add-Member -MemberType NoteProperty -Name "Role" -Value $Role
            return $object
            #Get-CIUser -Org $Org -Name $Name
        }
        catch {
            Write-Host "Creation of $name failed"
            Write-Host $_.Exception.Message
            write-host $_.Exception.ItemName
        }
    }
}

function Remove-CIUser {
    <#
    .DESCRIPTION
        Remove vCloud Director user account
    .PARAMETER Name
        The user name to remove
    .PARAMETER Org
        The ORG the user exists in
    .EXAMPLE
        $User = Get-CIUser -Name UserName -Org OrganisationName
        $user | Remove-CIUser
    .EXAMPLE
        $Org = Get-Org -Name OrganisationName
        $User = $Org | Get-CIUser
        $user | Remove-CIUser
    .EXAMPLE
        Remove-CIUser -Name UserName -Org OrganisationName
    #>
    [cmdletbinding()]
    Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName  = $true)]
        $Name,
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName  = $true)]
        $Org
    )
    try {
        $Org = Get-Org $Org
        $Name = $Org | Get-CIUser $Name
        $UserE = $Name.ExtensionData
        $UserE.IsEnabled = $false
        $UserE.UpdateServerData()
    }
    catch {
            Write-Host "Removal of $name failed"
            Write-Host $_.Exception.Message
            write-host $_.Exception.ItemName
        }
}

function Disable-CIUser {
    <#
    .DESCRIPTION
        Disable vCloud Director user account
    .PARAMETER Name
        The user name to Disable
    .PARAMETER Org
        The ORG the user exists in
    .EXAMPLE
        $User = Get-CIUser -Name UserName -Org OrganisationName
        $user | Disable-CIUser
    .EXAMPLE
        $Org = Get-Org -Name OrganisationName
        $User = $Org | Get-CIUser
        $user | Disable-CIUser
    .EXAMPLE
        Disable-CIUser -Name UserName -Org OrganisationName
    #>
    [cmdletbinding()]
    Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName  = $true)]
        $Name,
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName  = $true)]
        $Org
    )
    try {
        $Org = Get-Org $Org
        $Name = $Org | Get-CIUser $Name
        $UserE = $Name.ExtensionData
        if ( $UserE.IsEnabled -eq "True" ) {
            $UserE.IsEnabled = $false
            $UserE.UpdateServerData()
        }
        Else {
            Write-Host "Account $($Name.name) is already Disabled"
        }
        
    }
    catch {
        Write-Host "Disabling of $name Failed"
        Write-Host $_.Exception.Message
        write-host $_.Exception.ItemName
    }
}

function Enable-CIUser {
    <#
    .DESCRIPTION
        Enable vCloud Director user account
    .PARAMETER Name
        The user name to Enable
    .PARAMETER Org
        The ORG the user exists in
    .EXAMPLE
        $User = Get-CIUser -Name UserName -Org OrganisationName
        $user | Enable-CIUser
    .EXAMPLE
        $Org = Get-Org -Name OrganisationName
        $User = $Org | Get-CIUser
        $user | Enable-CIUser
    .EXAMPLE
        Enable-CIUser -Name UserName -Org OrganisationName
    #>
    [cmdletbinding()]
    Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName  = $true)]
        $Name,
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName  = $true)]
        $Org
    )
    try {
        $Org = Get-Org $Org
        $Name = $Org | Get-CIUser $Name
        $UserE = $Name.ExtensionData
        if ( $UserE.IsEnabled -ne "True" ) {
            $UserE.IsEnabled = $true
            $script:result = $UserE.UpdateServerData()
        }
        Else {
            Write-Host "Account $($Name.name) is already Enabled"
        }
        
    }
    catch {
        Write-Host "Enabling of $name Failed"
        Write-Host $_.Exception.Message
        write-host $_.Exception.ItemName
    }
}

function Set-CIUserPassword {
    <#
    .DESCRIPTION
        Change the password of a vCloud Director user account
    .PARAMETER Name
        The user name to change password on
    .PARAMETER Org
        The ORG the user exists in
    .EXAMPLE
        $User = Get-CIUser -Name UserName -Org OrganisationName
        $user | Set-CIUserPassword
    .EXAMPLE
        $Org = Get-Org -Name OrganisationName
        $User = $Org | Get-CIUser
        $user | Set-CIUserPassword -Password PasswordGoesHere!!
    .EXAMPLE
        Set-CIUserPassword -Name UserName -Org OrganisationName
    .EXAMPLE
        Set a Random generated password of length 10
        Set-CIUserPassword -Name UserName -Org OrganisationName -Password ( New-Password -PasswordLength 10)
    #>
    [cmdletbinding()]
    Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName  = $true)]
        $Name,
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName  = $true)]
        $Org,
        [Parameter(Mandatory=$false)]
        $Password
    )
    try {
        if ( ! $password ) { $password = New-Password }
        $Org = Get-Org $Org
        $Name = $Org | Get-CIUser $Name
        $UserE = $Name.ExtensionData
        $UserE.Password = $Password
        $UserE.UpdateServerData()
        $object = New-Object psobject
        $object | Add-Member -MemberType NoteProperty -Name "Name" -Value $Name.Name
        $object | Add-Member -MemberType NoteProperty -Name "Org" -Value $Org.Name
        $object | Add-Member -MemberType NoteProperty -Name "Password" -Value $Password

        return $object
    }
    catch {
        Write-Host "Change of password failed for $name"
        Write-Host $_.Exception.Message
        write-host $_.Exception.ItemName
    }


}

function Unlock-CIUserAccount {
    <#
    .DESCRIPTION
        Unlock vCloud Director user account
    .PARAMETER Name
        The user name to unlock
    .PARAMETER Org
        The ORG the user exists in
    .EXAMPLE
        $User = Get-CIUser -Name UserName -Org OrganisationName
        $user | Unlock-CIUserAccount
    .EXAMPLE
        $Org = Get-Org -Name OrganisationName
        $User = $Org | Get-CIUser
        $user | Unlock-CIUserAccount
    .EXAMPLE
        Unlock-CIUserAccount -Name UserName -Org OrganisationName
    #>
    [cmdletbinding()]
    Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName  = $true)]
        $Name,
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName  = $true)]
        $Org
    )
    begin{
    }
    process {
        try {
            if ( ( $Org ) -and ( $Name)){
                $Org = Get-Org $Org
                $Name = $Org | Get-CIUser $Name
                $UserE = $Name.ExtensionData
                if ( $UserE.IsLocked -eq "True" ) {
                $script:result = $UserE.Unlock()
                }
                Else {
                    Write-Host "Account $($Name.name) is not Locked"
                }
            }
            else {
                Write-Host -ForegroundColor Red "Required Parameters from pipeline missing"
            }
        }
        catch {
            Write-Host "Unlock of account $($Name.Name) Failed"
            Write-Host $_.Exception.Message
            write-host $_.Exception.ItemName
        }
    }
}

