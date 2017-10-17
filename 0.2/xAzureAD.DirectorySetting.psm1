function _temp{[CmdletBinding(SupportsShouldProcess)] param() Write-Verbose "Temporary function to build list of parameters established for Advanced Functions."}
$Script:DefaultParams = (Get-Command _temp | Select-Object -ExpandProperty parameters).Keys
Remove-Item function:\_temp

function Get-AzureADGroupGuid {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position=0)]
        [String]$Identity
    )
    Begin {}
    Process {
        Try {
            $Group = Get-AzureADGroup -Filter "DisplayName eq '$Identity'" -ErrorAction stop
            if (!$Group) 
            {
                Throw "Group '$Identity' does not exist"
            }
            if ($Group.Count -gt 1)
            {
                Throw "Multiple groups named '$Identity' exist, cannot determine which group to use."
            }
        }
        Catch {
            $_
        }
    }
    End {Return $Group.ObjectId}
}

function Set-AzureADDirectorySetting {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        Example of how to use this cmdlet
    .EXAMPLE
        Another example of how to use this cmdlet
    .INPUTS
        Inputs to this cmdlet (if any)
    .OUTPUTS
        Output from this cmdlet (if any)
    .NOTES
        General notes
    .COMPONENT
        The component this cmdlet belongs to
    .ROLE
        The role this cmdlet belongs to
    .FUNCTIONALITY
        The functionality that best describes this cmdlet
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0)]
        # ValidateSet string build: (Get-AzureADDirectorySettingTemplate | Select-Object -ExpandProperty DisplayName | ForEach-Object {"""$_"""}) -join ","
        [ValidateSet("Group.Unified","Group.Unified.Guest","Application","Custom Policy Settings","Password Rule Settings","Prohibited Names Settings","Prohibited Names Restricted Settings")]
        [String]$Name
    )
    DynamicParam
    {
        $IsGuid = New-Object System.Collections.ArrayList
        $SettingsParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $Templates = Get-AzureADDirectorySettingTemplate
        $Template = $Templates | Where-Object {$_.DisplayName -eq $Name}
        $Template.Values | ForEach-Object {
            $Type = [System.Type]"$($_.Type)"
            $Fullname = $_.Name
            $SettingsAttribute = New-Object System.Management.Automation.ParameterAttribute
            $SettingsAttribute.Mandatory = $false
            $SettingsAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $Type = [System.Type]"$($_.Type)"
            $ParameterName = $_.Name
            if ($Type -eq [System.Guid])
            {
                $Type = [System.Type]"System.String"
                $SettingsParameterName = $ParameterName.Replace("Id","")
                $IsGuid.Add($SettingsParameterName) | Out-Null
            } else {
                $SettingsParameterName = $ParameterName
            }
            $SettingsAttributeCollection.Add($SettingsAttribute)
            $SettingsParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($SettingsParameterName,$Type,$SettingsAttributeCollection)
            $SettingsParameterDictionary.Add($SettingsParameterName,$SettingsParameter)
        }
        Return $SettingsParameterDictionary
    }

    Begin {
        Try {
            ForEach($Key in $PSBoundParameters.Keys) {
                Write-Verbose "PSBoundParameter name : ${Key}"
                Write-Verbose "PSBoundParameter value: $($PSBoundParameters.($Key))"
            }
            $Template = Get-AzureADDirectorySettingTemplate | Where-Object {$_.DisplayName -eq $Name}
            if (!(AzureADPreview\Get-AzureADDirectorySetting | Where-Object {$_.DisplayName -eq $Name}))
            {
                $Setting = $Template.CreateDirectorySetting()
                New-AzureADDirectorySetting -DirectorySetting $Setting
            }
            $Setting = AzureADPreview\Get-AzureADDirectorySetting -Id (AzureADPreview\Get-AzureADDirectorySetting | Where-Object -Property DisplayName -Value $Name -EQ).Id
            $UnfilteredParams = New-Object System.Collections.ArrayList
            $UnfilteredParams.Add("Name") | Out-Null

            if ($PSBoundParameters['GroupCreationAllowedGroup'])
            {
                $GroupId = Get-AzureADGroupGuid -Identity $PSBoundParameters['GroupCreationAllowedGroup']
                Write-Verbose "Group name: $PSBoundParameters['GroupCreationAllowedGroup']"
                if (!$GroupId)
                {
                    Throw "Group '$PSBoundParameters['GroupCreationAllowedGroup']' does not exist"
                }
                $Setting['GroupCreationAllowedGroupId'] = $GroupId
                $UnfilteredParams.Add("GroupCreationAllowedGroup") | Out-Null
                Write-Verbose "GroupCreationAllowedGroupId: ${GroupId}"
            }

            Write-Verbose "DEFAULT PARAMETERS: ${Script:DefaultParams}"
            $Script:DefaultParams | ForEach-Object {
                $UnfilteredParams.Add($_) | Out-Null
            }
            Write-Verbose "UNFILTERED PARAMETERS: ${UnfilteredParams}"
            Write-Verbose "PSBoundParameters: $($PSBoundParameters.Keys)"
            ForEach($Key in $PSBoundParameters.Keys) {
                if ($UnfilteredParams -notcontains $Key)
                {
                    Write-Verbose "ADDING ATTRIBUTE KEY: ${Key}"
                    $Setting[$Key] = $PSBoundParameters.($Key)
                    Write-Verbose "ADDING ATTRIBUTE VALUE: $($PSBoundParameters.($Key))"
                }
            }
        }
        Catch {
            $_
        }
    }
    Process {
        AzureADPreview\Set-AzureADDirectorySetting -Id (AzureADPreview\Get-AzureADDirectorySetting | Where-Object -Property DisplayName -Value $Name -EQ).id -DirectorySetting $Setting
    }
    End {Get-AzureADDirectorySetting $Name}
}

function Get-AzureADDirectorySetting {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        Example of how to use this cmdlet
    .EXAMPLE
        Another example of how to use this cmdlet
    .INPUTS
        Inputs to this cmdlet (if any)
    .OUTPUTS
        Output from this cmdlet (if any)
    .NOTES
        General notes
    .COMPONENT
        The component this cmdlet belongs to
    .ROLE
        The role this cmdlet belongs to
    .FUNCTIONALITY
        The functionality that best describes this cmdlet
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=0)]
        # ValidateSet string build: (Get-AzureADDirectorySettingTemplate | Select-Object -ExpandProperty DisplayName | ForEach-Object {"""$_"""}) -join ","
        [ValidateSet("Group.Unified","Group.Unified.Guest","Application","Custom Policy Settings","Password Rule Settings","Prohibited Names Settings","Prohibited Names Restricted Settings")]
        [String]$Name
    )
    $Results = AzureADPreview\Get-AzureADDirectorySetting | Where-Object {$_.DisplayName -eq $Name}
    $Values = $Results.Values
    $Values | ForEach-Object {
        if ($_.Name -eq "GroupCreationAllowedGroupId")
        {
            $_.Name = "GroupCreationAllowedGroup"
            $_.Value = (Get-AzureADGroup -ObjectId $_.Value).DisplayName
        }
    }
    Return $Values
}