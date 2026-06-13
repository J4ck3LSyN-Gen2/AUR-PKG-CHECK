# Overview
`aur-pkg-integrity-test.sh` is an simple integrity validator designed for Arch Linux-based systems. Rather than relying on _fragile_, _signature-based malware scanning_, this tool leverages the system's native package manager (pacman) to identify unauthorized modifications to system files. All it does it wrap around the `pacman -Qkk` call and looks for things via `wc`. 

> [!WARNING] 
> This is a diagnostic tool for post-compromise identification, not an antivirus solution.
> _NOTE:_ This script is pretty simple and can be ran manually via `sudo pacman -Qkk`.... 

## Core Functionality
The script automates the `pacman -Qkk` verification process to detect:  
* **Modified Binaries:** Detects changes in system executables that deviate from the installed package's original checksum.  
* **Missing Files:** Identifies critical system files that have been deleted or moved.  
* **Anomalous Drift:** Highlights unexpected deviations in system state that often signify persistence or unauthorized tampering.  

## Usage
The script must be executed with root privileges to access the package database:

```bash
sudo ./aur-pkg-integrity-test.sh
```

The output will be saved to /tmp/audit_report_<timestamp>.log. If anomalies are detected, the script will output the first 20 violations directly to your terminal.

## Disclaimer
__This tool identifies anomalies, not malware. If this script reports altered or missing files, do not attempt to "fix" them manually or rely on pacman -S to overwrite them.__

## Verification Workflow
* **Isolate:** Remove the host from the network.  
* **Analyze:** Examine the reported files in the log for signs of malicious injection or unauthorized persistence.  
* **Remediate:** In a confirmed compromise scenario, the only secure path forward is a full system wipe and restoration from a known-good backup.  

## Possible Quicker One-Shot
```bash
raw=$(curl -fsSL "https://md.archlinux.org/s/SxbqukK6IA")
mapfile -t INFECTED < <(echo "$raw" | grep -oE '^[a-z0-9][a-z0-9_.+\-]*[a-z0-9]$' | sort -u)
comm -12 <(pacman -Qmq | sort) <(printf "%s\n" "${INFECTED[@]}" | sort)
```
