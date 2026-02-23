
# ==========================================
# Minimal Power System (Final Auto-Start)
# ==========================================

function Start-MinimalPowerSystem {

    $Power = 1

    $Components = @{
        CPU     = 1
        Display = 1
        Storage = 1
        Network = 1
    }

    function Apply-Power {
        $keys = @($Components.Keys)
        foreach ($k in $keys) {
            $Components[$k] = $Power
        }
    }

    function Compute-Services {

        $Kernel      = if ($Power -and $Components.CPU) {1} else {0}
        $Browser     = if ($Kernel -and $Components.Network -and $Components.Display) {1} else {0}
        $MediaPlayer = if ($Kernel -and $Components.Storage -and $Components.Display) {1} else {0}

        return @{
            Kernel      = $Kernel
            Browser     = $Browser
            MediaPlayer = $MediaPlayer
        }
    }

    function Print-State {

        $Services = Compute-Services

        Write-Host ""
        Write-Host "Power       : $Power"
        Write-Host "CPU         : $($Components.CPU)"
        Write-Host "Display     : $($Components.Display)"
        Write-Host "Storage     : $($Components.Storage)"
        Write-Host "Network     : $($Components.Network)"
        Write-Host "Kernel      : $($Services.Kernel)"
        Write-Host "Browser     : $($Services.Browser)"
        Write-Host "MediaPlayer : $($Services.MediaPlayer)"
        Write-Host ""
    }

    function Save-State($file) {

        if (-not $file) {
            $file = "MinimalPowerState.json"
        }

        $Services = Compute-Services

        $State = @{
            Power      = $Power
            Components = $Components
            Services   = $Services
        }

        $State | ConvertTo-Json -Depth 4 | Out-File -Encoding UTF8 $file
        Write-Host "State saved to $file"
    }

    function Show-CompactMenu {
        Write-Host ""
        Write-Host "[ on | off | stop | reset | run | check | cycle n | save file | help | exit ]"
    }

    Write-Host ""
    Write-Host "Minimal Power System Ready"
    Show-CompactMenu

    while ($true) {

        $cmd = Read-Host ">"

        if (-not $cmd) { continue }

        $cmd = $cmd.Trim().ToLower()

        if ($cmd -eq "exit") {
            Write-Host "Exiting..."
            break
        }

        elseif ($cmd -eq "on") {
            $Power = 1
            Apply-Power
            Print-State
        }

        elseif ($cmd -eq "off" -or $cmd -eq "stop") {
            $Power = 0
            Apply-Power
            Print-State
        }

        elseif ($cmd -eq "reset") {
            $Power = 1
            Apply-Power
            Print-State
        }

        elseif ($cmd -eq "run" -or $cmd -eq "check") {
            Apply-Power
            Print-State
        }

        elseif ($cmd -match "^cycle\s+(\d+)$") {
            $n = [int]$matches[1]
            for ($i=1; $i -le $n; $i++) {
                Write-Host "Cycle"
                Apply-Power
                Print-State
            }
        }

        elseif ($cmd -match "^save\s*(.*)$") {
            $file = $matches[1]
            Save-State $file
        }

        elseif ($cmd -eq "help") {
            Show-CompactMenu
            continue
        }

        else {
            Write-Host "Unknown command."
        }

        Show-CompactMenu
    }
}

# Auto-start when script is executed
Start-MinimalPowerSystem
