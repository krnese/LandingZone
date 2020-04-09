function Expand-AzTemplate {
    <#
        .Synopsis
        Validates ARM template in combination with parameter file and returns ARM expanded results.
        .Example
        Expand-AzTemplate -TemplateFile c:\NorthStar.json -ParameterFile c:\NorthStar.parameters.json -Name validation
    #>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $TemplateFile,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ParameterFile,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Location
    )
    begin {
        $currentContext = Get-AzContext
        $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        $profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient]::new($azureRmProfile)
        $token = $profileClient.AcquireAccessToken($currentContext.Subscription.TenantId)
    }
    process {
        $templateParams = Get-Content -Raw $ParameterFile | ConvertFrom-Json 
        $body = @"
{
    "properties": {
        "template": $(Get-Content -Raw $TemplateFile),
        "parameters": $($templateParams.parameters | ConvertTo-Json),
        "mode": "Incremental"
    },
    "location": "$location"
}
"@
        $iwrArgs = @{
            Uri = "https://management.azure.com/providers/Microsoft.Resources/deployments/$($Name)/validate?api-version=2019-10-01"
            Headers = @{
                Authorization = "Bearer $($token.AccessToken)"
                'Content-Type' = 'application/json'
            }
            Method = 'Post'
            Body = $body
            UseBasicParsing = $true
        }
        $result = Invoke-WebRequest @iwrArgs
        #pretty print
        [Newtonsoft.Json.Linq.JObject]::Parse($result.Content).ToString()
    }
}
