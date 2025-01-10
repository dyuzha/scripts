# Папка, содержимое которой, нужно проверить на наследуемость GPO
$root_folder = "C:\\Puth\to\folder"

# Чтобы искать еще и в подпапке
# $folders = gci -Recurse $root_folder
$folders = gci $root_folder

foreach ($path in $folders) {
    if ($path.PSIsContainer -eq $false) {
        continue
    }
    if ((Get-Acl $path.fullname).AreAccessRulesProtected -eq $false) {
        $path.fullname
    }
}

Read-Host "Press Enter for exit..."

