# Get current settings of my custom RBAC management role
Get-ManagementRoleEntry "CustomMyDistributionGroups\*"

# Remove the custom management role entries for distribution group members
Remove-ManagementRoleEntry "CustomMyDistributionGroups\Add-DistributionGroupMember" -Confirm:$false
Remove-ManagementRoleEntry "CustomMyDistributionGroups\Remove-DistributionGroupMember" -Confirm:$false
Remove-ManagementRoleEntry "CustomMyDistributionGroups\Set-DistributionGroupMember" -Confirm:$false

