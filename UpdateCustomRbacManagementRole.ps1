# ① コピー元（既定）のロール一覧を取得
$defaultRoles = (Get-RoleAssignmentPolicy -Identity "Default Role Assignment Policy").Roles

# ② 新しいロールポリシー名を定義（好きな名前に変えてOK）
$newPolicyName = "CopiedFromDefaultPolicy"

# ③ 新しいポリシーを作成（同じロールを割り当てて）
New-RoleAssignmentPolicy -Name $newPolicyName -Roles $defaultRoles


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




# Create new policy
New-RoleAssignmentPolicy -Name "GroupEditPolicy" -Roles "CustomMyDistributionGroups", "その他必要なロール"

# Change policy of specific user
Set-Mailbox -Identity user@example.com -RoleAssignmentPolicy "GroupEditPolicy"

# Finally, remove CustomMyDistributionGroups from Default Role Assignment Policy
Get-ManagementRoleAssignment -RoleAssignee "Default Role Assignment Policy" `
  | Where-Object { $_.Role -eq "CustomMyDistributionGroups" } `
  | Remove-ManagementRoleAssignment -Confirm:$false






# 管理者の権限が割り当てられているユーザーをピックアップ
# 出力ファイル名（デスクトップに作成）
$csvPath = "$env:USERPROFILE\_tools\dst\UserAndAdminRoles.csv"

# ユーザーごとのロール割り当てを収集
$results = @()

# ① Exchangeユーザー（メールボックス）一覧
$mailboxes = Get-Mailbox -ResultSize Unlimited

foreach ($mbx in $mailboxes) {
    $obj = [PSCustomObject]@{
        DisplayName          = $mbx.DisplayName
        UserPrincipalName    = $mbx.UserPrincipalName
        RoleAssignmentPolicy = $mbx.RoleAssignmentPolicy
        AdminRoleGroups      = ""
    }

    # ② 管理者ロールグループに含まれてるかチェック
    $adminGroups = Get-RoleGroup | Where-Object {
        (Get-RoleGroupMember $_.Name -ErrorAction SilentlyContinue | Where-Object {$_.PrimarySmtpAddress -eq $mbx.PrimarySmtpAddress}).Count -gt 0
    }

    if ($adminGroups) {
        $obj.AdminRoleGroups = ($adminGroups.Name -join ", ")
    }

    $results += $obj
}

# ③ CSV出力
$results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "✅ 出力完了！ファイル：$csvPath" -ForegroundColor Cyan



# 管理者の権限が割り当てられているユーザーをピックアップ (改良版)
# 出力先
$csvPath = "$env:USERPROFILE\Desktop\UserAndAdminRoles.csv"
$results = @()

# 一括取得
$mailboxes = Get-Mailbox -ResultSize Unlimited
$roleGroups = Get-RoleGroup

# 管理者ロールグループごとのメンバーを先に全て取得して辞書化
$adminMembership = @{}
foreach ($group in $roleGroups) {
    $members = Get-RoleGroupMember $group.Name -ErrorAction SilentlyContinue
    foreach ($member in $members) {
        $key = $member.UserPrincipalName.ToLower()
        if ($adminMembership.ContainsKey($key)) {
            $adminMembership[$key] += $group.Name
        } else {
            $adminMembership[$key] = @($group.Name)
        }
    }
}

# ルックアップ形式で爆速チェック
foreach ($mbx in $mailboxes) {
    $key = $mbx.UserPrincipalName.ToLower()

    $obj = [PSCustomObject]@{
        DisplayName          = $mbx.DisplayName
        UserPrincipalName    = $mbx.UserPrincipalName
        RoleAssignmentPolicy = $mbx.RoleAssignmentPolicy
        AdminRoleGroups      = $adminMembership[$key] -join ", "
    }

    $results += $obj
}

# 出力
$results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "✅ 出力完了！ファイル：$csvPath" -ForegroundColor Cyan
