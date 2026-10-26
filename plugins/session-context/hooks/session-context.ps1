# SessionStart: 브랜치·변경 파일·가상환경 상태를 Claude 맥락에 주입한다.
# 어느 폴더에서 실행돼도 실패하지 않아야 하므로, 확인 불가한 항목은 조용히 건너뛴다.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'SilentlyContinue'

$lines = @()

if ((Get-Command git) -and ((git rev-parse --is-inside-work-tree 2>$null) -eq 'true')) {
    $branch = git branch --show-current
    if (-not $branch) { $branch = '(detached HEAD) ' + (git rev-parse --short HEAD) }
    $lines += "브랜치: $branch"
    if ($branch -in 'main', 'master') {
        $lines += '주의: 기본 브랜치입니다. 큰 변경 전에 브랜치를 만드세요.'
    }

    $changed = @(git -c core.quotepath=false status --short)
    if ($changed.Count -eq 0) {
        $lines += '변경 파일: 없음 (clean)'
    } else {
        $lines += "변경 파일: $($changed.Count)개"
        $changed | Select-Object -First 8 | ForEach-Object { $lines += "  $_" }
        if ($changed.Count -gt 8) { $lines += "  ... 외 $($changed.Count - 8)개" }
    }

    $recent = @(git log -3 --oneline)
    if ($recent.Count -gt 0) {
        $lines += '최근 커밋:'
        $recent | ForEach-Object { $lines += "  $_" }
    }
}

# 경로에 사용자 이름이 섞이지 않도록 가상환경은 폴더명만 출력한다.
if (Get-Command python) {
    $lines += "Python: $((python --version 2>&1) -join ' ')"
    if ($env:VIRTUAL_ENV) {
        $lines += "가상환경: 활성 ($(Split-Path $env:VIRTUAL_ENV -Leaf))"
    } else {
        $found = @('.venv', 'venv', 'env') | Where-Object { Test-Path (Join-Path $PWD $_ 'Scripts\activate*') }
        if ($found) {
            $lines += "가상환경: 비활성 ($($found[0]) 폴더가 있으니 활성화 후 pip를 쓰세요)"
        } else {
            $lines += '가상환경: 비활성 (프로젝트 가상환경 없음)'
        }
    }
}

if ($lines.Count -gt 0) {
    '[세션 시작 상태]'
    $lines
}
exit 0
