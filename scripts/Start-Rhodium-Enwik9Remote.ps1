& {
    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2
    $Repo = 'BlackboxLogicCore/rhodium-benchmarks'
    $Workflow = 'enwik9-remote-rhodium.yml'
    $Gh = (Get-Command gh.exe -ErrorAction Stop).Source
    $Request = [Guid]::NewGuid().ToString('N')
    $Created = New-Object 'System.Collections.Generic.List[string]'
    $RuntimeRoots = @(
        'C:\Rhodium-Germany\Runtime\MatrixLiveV1',
        'D:\Rhodium-Germany\Runtime\MatrixLiveV1',
        'D:\Rhodium-Germany.__MIGRATION__\Runtime\MatrixLiveV1',
        'D:\Rhodium-Archive-C\Runtime\MatrixLiveV1'
    )
    $Definitions = @(
        @{ Name='ENGINE'; File='matrix_live.py'; Hash='55672321E50A48C7AD9673950D8A5C315CE3EDA225A2CB0101CCAA7CC51135C1' },
        @{ Name='HARNESS'; File='matrix_blackbox.py'; Hash='AC459654CC3249E1652EC2A3CADDBA34A3CF29A23315E97A92DCD8E7EF00C53D' },
        @{ Name='ADAPTER'; File='matrix_blackbox_earthscope_adapter.py'; Hash='EB40EF04A23634ACC89BBA4A200BB111B52034158059E4F189444BF3FDA7C2F7' }
    )
    $Selected = @{}
    foreach ($Definition in $Definitions) {
        $Candidates = @($RuntimeRoots | ForEach-Object { Join-Path $_ $Definition.File })
        if ($Definition.Name -eq 'ADAPTER') {
            $Candidates += 'C:\Rhodium-Live-Proof\RHODIUM-EARTHSCOPE-20260905-064225\matrix_blackbox_earthscope_adapter.py'
        }
        foreach ($Candidate in $Candidates) {
            if ((Test-Path -LiteralPath $Candidate -PathType Leaf) -and
                ((Get-FileHash -LiteralPath $Candidate -Algorithm SHA256).Hash -eq $Definition.Hash)) {
                $Selected[$Definition.Name] = $Candidate
                break
            }
        }
        if (!$Selected.ContainsKey($Definition.Name)) {
            throw ('VERIFIED_RUNTIME_FILE_MISSING=' + $Definition.File)
        }
    }
    & $Gh auth status --hostname github.com
    if ($LASTEXITCODE -ne 0) { throw 'GITHUB_AUTH_REQUIRED' }
    $ExistingJson = & $Gh secret list --repo $Repo --json name
    if ($LASTEXITCODE -ne 0) { throw 'SECRET_INVENTORY_FAILED' }
    $Existing = @(($ExistingJson | ConvertFrom-Json) | ForEach-Object { $_.name })
    foreach ($Definition in $Definitions) {
        $Name = 'RHODIUM_ENWIK9_' + $Definition.Name + '_GZ_B64'
        if ($Existing -contains $Name) { throw ('TEMPORARY_SECRET_ALREADY_EXISTS=' + $Name) }
    }
    try {
        foreach ($Definition in $Definitions) {
            $Name = 'RHODIUM_ENWIK9_' + $Definition.Name + '_GZ_B64'
            $Bytes = [IO.File]::ReadAllBytes($Selected[$Definition.Name])
            $Memory = New-Object IO.MemoryStream
            $Gzip = New-Object IO.Compression.GZipStream($Memory, [IO.Compression.CompressionMode]::Compress, $true)
            try { $Gzip.Write($Bytes, 0, $Bytes.Length) } finally { $Gzip.Dispose() }
            $Payload = [Convert]::ToBase64String($Memory.ToArray())
            $Memory.Dispose()
            if ($Payload.Length -gt 46000) { throw 'RUNTIME_PAYLOAD_TOO_LARGE' }
            $Start = New-Object Diagnostics.ProcessStartInfo
            $Start.FileName = $Gh
            $Start.Arguments = "secret set $Name --repo $Repo"
            $Start.UseShellExecute = $false
            $Start.CreateNoWindow = $true
            $Start.RedirectStandardInput = $true
            $Start.RedirectStandardOutput = $true
            $Start.RedirectStandardError = $true
            $Process = New-Object Diagnostics.Process
            $Process.StartInfo = $Start
            [void]$Created.Add($Name)
            try {
                [void]$Process.Start()
                $Process.StandardInput.Write($Payload)
                $Process.StandardInput.Close()
                $Process.WaitForExit()
                if ($Process.ExitCode -ne 0) { throw ('SECRET_UPLOAD_FAILED=' + $Name) }
            } finally {
                $Process.Dispose()
                $Payload = $null
                $Bytes = $null
            }
        }
        Write-Host 'VERIFIED_RUNTIME_UPLOAD=PASS'
        & $Gh workflow run $Workflow --repo $Repo --ref main --field "request_id=$Request"
        if ($LASTEXITCODE -ne 0) { throw 'REMOTE_DISPATCH_FAILED' }
        $RunId = $null
        for ($Try = 0; $Try -lt 30; $Try++) {
            Start-Sleep -Seconds 2
            $RunsJson = & $Gh run list --repo $Repo --workflow $Workflow --limit 20 --json databaseId,displayTitle,url
            if ($LASTEXITCODE -ne 0) { throw 'RUN_LOOKUP_FAILED' }
            foreach ($Run in @($RunsJson | ConvertFrom-Json)) {
                if ($Run.displayTitle -eq "enwik9 - $Request") {
                    $RunId = [string]$Run.databaseId
                    Write-Host ('REMOTE_RUN=' + $Run.url)
                    break
                }
            }
            if ($RunId) { break }
        }
        if (!$RunId) { throw 'DISPATCHED_RUN_ID_NOT_FOUND' }
        Write-Host 'ENWIK9_DOWNLOAD_LOCATION=GITHUB_UBUNTU'
        Write-Host 'LOCAL_BOX_MODIFIED=NO'
        # Keep temporary runtime available until the dispatched run finishes.
        & $Gh run watch $RunId --repo $Repo --exit-status
        $RunExit = $LASTEXITCODE
        & $Gh run view $RunId --repo $Repo --log
        if ($RunExit -ne 0) { throw ('REMOTE_TEST_FAILED_RUN=' + $RunId) }
    } finally {
        foreach ($Name in $Created) {
            & $Gh secret delete $Name --repo $Repo
            if ($LASTEXITCODE -ne 0) {
                Write-Warning ('TEMPORARY_SECRET_DELETE_FAILED=' + $Name)
            }
        }
        foreach ($Definition in $Definitions) {
            if ((Get-FileHash -LiteralPath $Selected[$Definition.Name] -Algorithm SHA256).Hash -ne $Definition.Hash) {
                Write-Error ('LOCAL_RUNTIME_HASH_CHANGED=' + $Definition.Name)
            }
        }
    }
}
