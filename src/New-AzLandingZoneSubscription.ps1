# PowerShell sample to create new Azure Subscriptions and move to target management group
param (
    $subscriptionDisplayName,
    $targetManagementGroupId,
    $offerType = "MS-AZR-0017P"
)
                        
    Write-Host "Creating new subscription"

    $subscription = New-AzSubscription -Name $subscriptionDisplayName `
                                       -OfferType $offerType `
                                       -EnrollmentAccountObjectId (Get-AzureRmEnrollmentAccount)[0].ObjectId

    Write-Host "Creating new subscription Success!"


    # Assign Subscription to its Management Group .
    New-AzManagementGroupSubscription -GroupName $ManagementGroupName -SubscriptionId $subscription.SubscriptionId
