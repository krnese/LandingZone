function Elevate-AzTenantAccess {
    <#
        1/1/2020 - Kristian Nese
        Elevate yourself to UAA at Azure Tenant Scope (requires user to be Global Admin in AAD)
        
        .Synopsis
        Allos Global Admin to elevate themselves to UAA at Azure tenant root

        .Example
        Elevate-AzTenantAccess
    #>

    [cmdletbinding()]
    param (
    )
    begin {
        $currentContext = Get-AzContext
        $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        $profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient]::new($azureRmProfile)
        $token = $profileClient.AcquireAccessToken($currentContext.Subscription.TenantId)
    }
    process {
    # ARM Request
    $ARMRequest = @{
        Uri = "https://management.azure.com/providers/Microsoft.Authorization/elevateAccess?api-version=2016-07-01"
        Headers = @{
            Authorization = "Bearer $($token.AccessToken)"
            'Content-Type' = 'application/json'
        }
        Method = 'Post'
        Body = $body
        UseBasicParsing = $true
    }
            $Elevate = Invoke-WebRequest @ARMRequest
            #prettify
            if ($Elevate.StatusDescription -eq 'OK')
            {
                Write-Host "Successfully elevated access to tenant root scope"
            }
            else 
            {
                Write-Host "Request failed. Verify you are Global Admin in Azure AD for the given tenant."    
            }
        }
    }

