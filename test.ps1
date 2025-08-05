# CSV 読み込み
$csv = Import-Csv -Path "input.csv"

foreach ($row in $csv) {
    # 1. col2 を加工（SMTP削除 + スペース→;）
    $row.col2 = ($row.col2 -replace '(?i)smtp:', '') -replace ' ', ';'

    # 2. col3 にコピー（mailLocalAddress 相当）
    $row | Add-Member -NotePropertyName col3 -NotePropertyValue $row.col2

    # 3. col4 に数値 0 を追加（userType 相当）
    $row | Add-Member -NotePropertyName col4 -NotePropertyValue 0
}

# 4. ヘッダー名を変更
$renamed = $csv | Select-Object @{
    Name = 'uid'; Expression = { $_.col1 }
}, @{
    Name = 'mail'; Expression = { $_.col2 }
}, @{
    Name = 'mailLocalAddress'; Expression = { $_.col3 }
}, @{
    Name = 'userType'; Expression = { $_.col4 }
}

# 5. 新しい CSV に出力
$renamed | Export-Csv -Path "output.csv" -NoTypeInformation -Encoding UTF8
