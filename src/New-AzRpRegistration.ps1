# PowerShell sample to register an RP to all Azure Subscriptions
param (
    $ResourceProviderName
)
                        
    $AzureSubscriptions = Get-AzSubscription
    foreach ($sub in $AzureSubscriptions)
    {
        Register-AzResourceProvider -ProviderNamespace $ResourceProviderName
    }