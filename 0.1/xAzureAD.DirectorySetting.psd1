@{
    RootModule = 'xAzureAD.DirectorySetting.psm1'
    ModuleVersion = '0.1'
    Author = 'Dustin Dortch'
    Description = 'Azure AD Directory Setting for Office 365 Groups'
    PowerShellVersion = '5.0'
    PowerShellHostVersion = '1.0'
    DotNetFrameworkVersion = '4.5.0.0'
    RequiredModules = @("AzureADPreview")
    FunctionsToExport = "*"
    CmdletsToExport = "*"
    VariablesToExport = "*"
    AliasesToExport = "*"
    ModuleList = @("xAzureAD.DirectorySetting")
    DefaultCommandPrefix = ''
    FileList = @("xAzureAD.DirectorySetting.psd1","xAzureAD.DirectorySetting.psm1")
    PrivateData = @{
        PSData = @{
            Tags = @('AzureAD')
        }
    }
}