$ErrorActionPreference = "Stop"
$gh = "$env:LOCALAPPDATA\gh-cli\bin\gh.exe"
$root = $PSScriptRoot

if (-not (Test-Path $gh)) {
  Write-Error "GitHub CLI не найден. Переустановите gh или выполните авторизацию вручную."
}

Set-Location $root

& $gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host "Сначала войдите в GitHub:"
  & $gh auth login -h github.com -p https -w --skip-ssh-key -s repo
}

$user = & $gh api user -q .login
$repoName = "todo-list"

if (git remote get-url origin 2>$null) {
  git push -u origin HEAD
} elseif (& $gh repo view "$user/$repoName" 2>$null) {
  git remote add origin "https://github.com/$user/$repoName.git"
  git push -u origin HEAD
} else {
  & $gh repo create $repoName --public --source=. --remote=origin --push --description "Список дел на HTML/CSS/JS с localStorage"
}

Write-Host "Готово: https://github.com/$user/$repoName"
