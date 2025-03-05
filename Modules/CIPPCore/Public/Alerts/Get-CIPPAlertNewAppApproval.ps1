
function Get-CIPPAlertNewAppApproval {
    <#
    .FUNCTIONALITY
        Entrypoint
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [Alias('input')]
        $InputValue,
        $TenantFilter
    )
    try {
        $Approvals = New-GraphGetRequest -Uri "https://graph.microsoft.com/v1.0/identityGovernance/appConsent/appConsentRequests?`$filter=userConsentRequests/any (u:u/status eq 'InProgress')" -tenantid $TenantFilter
        if ($Approvals.count -gt 0) {
            $AlertData = "There are $($Approvals.count) App Approval(s) pending."
            Write-AlertTrace -cmdletName $MyInvocation.MyCommand -tenantFilter $TenantFilter -data $AlertData
        }
    } catch {
    }
}

<#
The current script, `Get-CIPPAlertNewAppApproval.ps1`, fetches app consent requests. To add steps to get who requested the app, the app name, and the permissions the app is asking for, follow these steps:

1. **Identify where to add the new steps**:
   - After fetching approvals, iterate through each approval to extract additional details.

2. **Modify the script**:
   - Add logic to extract the requester, app name, and permissions.

Here's an example modification to the script:

```powershell
function Get-CIPPAlertNewAppApproval {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [Alias('input')]
        $InputValue,
        $TenantFilter
    )
    try {
        $Approvals = New-GraphGetRequest -Uri "https://graph.microsoft.com/v1.0/identityGovernance/appConsent/appConsentRequests?`$filter=userConsentRequests/any (u:u/status eq 'InProgress')" -tenantFilter $TenantFilter
        if ($Approvals.count -gt 0) {
            foreach ($Approval in $Approvals) {
                $Requester = $Approval.userConsentRequests[0].user.displayName
                $AppName = $Approval.app.displayName
                $Permissions = $Approval.app.requiredResourceAccess | ForEach-Object {
                    $_.resourceAppId + ": " + ($_.resourceAccess | ForEach-Object { $_.type + " " + $_.id })
                } | Out-String

                $AlertData = "Requester: $Requester`nApp Name: $AppName`nPermissions: $Permissions"
                Write-AlertTrace -cmdletName $MyInvocation.MyCommand -tenantFilter $TenantFilter -data $AlertData
            }
        }
    } catch {
        Write-Error "Failed to get app approval requests: $_"
    }
}
```

This modification adds steps to extract and log the requester, app name, and permissions for each approval. Validate and test the script to ensure it runs correctly and retrieves the required information.
