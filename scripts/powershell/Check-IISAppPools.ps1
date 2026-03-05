<#
.SYNOPSIS
    IIS Application Pool Health Check
.DESCRIPTION
    Monitors IIS application pools status and displays health summary
.EXAMPLE
    .\Check-IISAppPools.ps1
#>

Import-Module WebAdministration -ErrorAction SilentlyContinue

Write-Host "`n=== IIS Application Pools Health Check ===" -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Gray

try {
    $pools = Get-ChildItem IIS:\AppPools -ErrorAction Stop

    $healthData = @()

    foreach ($pool in $pools) {
        $name = $pool.Name
        $state = $pool.State
        $startMode = $pool.StartMode
        $recycleTime = $pool.Recycling.PeriodicRestart.Time
        $recycleRequests = $pool.Recycling.PeriodicRestart.Requests

        $status = if ($state -eq "Started") { "✓" } else { "✗" }
        $color = if ($state -eq "Started") { "Green" } else { "Red" }

        Write-Host "$status $name" -ForegroundColor $color
        Write-Host "   State: $state | Start Mode: $startMode" -ForegroundColor Gray
        Write-Host "   Recycle Time: $recycleTime | Recycle Requests: $recycleRequests`n" -ForegroundColor Gray

        $healthData += [PSCustomObject]@{
            AppPool = $name
            State = $state
            StartMode = $startMode
        }
    }

    Write-Host "=== Summary ===" -ForegroundColor Cyan
    $total = $pools.Count
    $running = ($pools | Where-Object {$_.State -eq "Started"}).Count
    $stopped = $total - $running

    Write-Host "Total Pools: $total" -ForegroundColor White
    Write-Host "Running: $running" -ForegroundColor Green
    Write-Host "Stopped: $stopped" -ForegroundColor $(if ($stopped -eq 0) { "Green" } else { "Yellow" })

    # Export to CSV for monitoring integration
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $exportPath = "iis-health-check-$timestamp.csv"
    $healthData | Export-Csv -Path $exportPath -NoTypeInformation
    Write-Host "`nHealth data exported to: $exportPath" -ForegroundColor Gray

} catch {
    Write-Host "ERROR: Unable to access IIS. Ensure you're running as Administrator and IIS is installed." -ForegroundColor Red
    Write-Host "Error details: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
