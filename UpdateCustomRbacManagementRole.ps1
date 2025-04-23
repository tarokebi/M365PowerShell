# Check where "CustomMyDistributionGroups" belongs to
Get-RoleAssignmentPolicy | Where-Object {
    (Get-ManagementRoleAssignment -RoleAssignee $_.Name).Role -contains "CustomMyDistributionGroups"
}

# List all users who are assigned "Default Role Assignment Policy" (and export to csv)
Get-Mailbox -ResultSize Unlimited | Where-Object {
    $_.RoleAssignmentPolicy -eq "Default Role Assignment Policy"
} | Select-Object DisplayName, UserPrincipalName |
Export-Csv -Path "$env:USERPROFILE\_tools\dst\DefaultRoleUsers.csv" -NoTypeInformation -Encoding UTF8


# Check specific user's role assignment policy
Get-Mailbox -Identity "user@example.com" | Select-Object DisplayName, RoleAssignmentPolicy

# Get current settings of my custom RBAC management role
Get-ManagementRoleEntry "CustomMyDistributionGroups\*"

# Remove the custom management role entries for distribution group members
Remove-ManagementRoleEntry "CustomMyDistributionGroups\Add-DistributionGroupMember" -Confirm:$false
Remove-ManagementRoleEntry "CustomMyDistributionGroups\Remove-DistributionGroupMember" -Confirm:$false
Remove-ManagementRoleEntry "CustomMyDistributionGroups\Set-DistributionGroupMember" -Confirm:$false

