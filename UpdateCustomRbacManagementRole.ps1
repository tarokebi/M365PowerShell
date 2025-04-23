# Check where "CustomMyDistributionGroups" belongs to
Get-RoleAssignmentPolicy | Where-Object {
    (Get-ManagementRoleAssignment -RoleAssignee $_.Name).Role -contains "CustomMyDistributionGroups"
}

Get-Mailbox -ResultSize Unlimited | Where-Object {
    $_.RoleAssignmentPolicy -eq "RestrictedGroupManagementPolicy"
} | Select-Object DisplayName, UserPrincipalName

Get-Mailbox -Identity "user@example.com" | Select-Object DisplayName, RoleAssignmentPolicy

# Get current settings of my custom RBAC management role
Get-ManagementRoleEntry "CustomMyDistributionGroups\*"

# Remove the custom management role entries for distribution group members
Remove-ManagementRoleEntry "CustomMyDistributionGroups\Add-DistributionGroupMember" -Confirm:$false
Remove-ManagementRoleEntry "CustomMyDistributionGroups\Remove-DistributionGroupMember" -Confirm:$false
Remove-ManagementRoleEntry "CustomMyDistributionGroups\Set-DistributionGroupMember" -Confirm:$false

