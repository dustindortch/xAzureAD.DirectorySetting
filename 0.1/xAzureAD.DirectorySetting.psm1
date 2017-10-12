function _temp{[CmdletBinding(SupportsShouldProcess)] param() Write-Verbose "Temporary function to build list of parameters established for Advanced Functions."}
$Script:DefaultParams = (Get-Command _temp | Select-Object -ExpandProperty parameters).Keys
Remove-Item function:\_temp

function Set-AzureADGroupsSetting
{
    <#
    .SYNOPSIS
        Set-AzureADGroupsSetting adjusts settings for Office 365 Groups
    .DESCRIPTION
        Set-AzureADGroupsSetting adjusts settings for Office 365 Groups and depends on the AzureADPreview module
    .EXAMPLE
        Set-AzureADGroupsSetting -GroupCreationAllowedGroup <GroupName> -EnableGroupCreation [$true|$false]
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
    Param
    (
        # CustomBlockedWordsList help description
        [String]$CustomBlockedWordsList,

        # EnableMSStandardBlockedWords help description
        [Boolean]$EnableMSStandardBlockedWords,

        # ClassificationDescriptions help description
        [String]$ClassificationDescriptions,

        # DefaultClassification help description
        [String]$DefaultClassification,

        # PrefixSuffixNamingRequirement help description
        [String]$PrefixSuffixNamingRequirement,

        # AllowGuestsToBeGroupOwner help description
        [boolean]$AllowGuestsToBeGroupOwner,

        # AllowGuestsToAccessGroups help description
        [Boolean]$AllowGuestsToAccessGroups,

        # GuestUsageGuidelinesUrl help description
        [String]$GuestUsageGuidelinesUrl,

        # GroupCreationAllowedGroupId help description
        [String]$GroupCreationAllowedGroup,

        # AllowToAddGuests help description
        [Boolean]$AllowToAddGuests,

        # UsageGuidelinesUrl help description
        [String]$UsageGuidelinesUrl,

        # ClassificationList help description
        [String]$ClassificationList,

        # EnableGroupCreation help description
        [Boolean]$EnableGroupCreation
    )

    Begin
    {
        $Template = Get-AzureADDirectorySettingTemplate | Where-Object {$_.DisplayName -eq 'Group.Unified'}
        if (!(Get-AzureADDirectorySetting | Where-Object {$_.DisplayName -eq 'Group.Unified'}))
        {
            $Setting = $Template.CreateDirectorySetting()
            New-AzureADDirectorySetting -DirectorySetting $Setting
        }
        $Setting = Get-AzureADDirectorySetting -Id (Get-AzureADDirectorySetting | Where-Object -Property DisplayName -Value "Group.Unified" -EQ).Id
        $UnfilteredParams = New-Object System.Collections.ArrayList

        if ($GroupCreationAllowedGroup)
        {
            $Group = (Get-AzureADGroup -SearchString "${GroupCreationAllowedGroup}").ObjectId
            if (!$Group) {Write-Error "Group ${GroupCreationAllowedGroup} not found"; Return $null}
            $Setting['GroupCreationAllowedGroupId'] = $Group
            $UnfilteredParams.Add("GroupCreationAllowedGroup") | Out-Null
        }
        Write-Verbose "DEFAULT PARAMETERS: ${Script:DefaultParams}"
        $Script:DefaultParams | ForEach-Object {
            $UnfilteredParams.Add($_) | Out-Null
        }
        Write-Verbose "UNFILTERED PARAMETERS: ${UnfilteredParams}"
        ForEach($Key in $PSBoundParameters.Keys) {
            if ($UnfilteredParams -notcontains $Key)
            {
                Write-Verbose "ADDING ATTRIBUTE KEY: ${Key}"
                $Setting[$Key] = $PSBoundParameters.($Key)
                Write-Verbose "ADDING ATTRIBUTE VALUE: ${PSBoundParameters.($Key)}"
            }
        }
    }
    Process
    {
        Set-AzureADDirectorySetting -Id (Get-AzureADDirectorySetting | Where-Object -Property DisplayName -Value "Group.Unified" -EQ).id -DirectorySetting $Setting
    }
    End
    {
        Return (Get-AzureADDirectorySetting).Values
    }
}