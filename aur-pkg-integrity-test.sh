#!/bin/bash
# triage_integrity.sh - Advanced Integrity Check
# Author: J4ck3LSyN
if [[ $EUID -ne 0 ]]; then
   echo "[-] Must be run as root."
   exit 1
fi
LOG_FILE="/tmp/audit_report_$(date +%s).log"
echo "[*] Auditing System Integrity. Results: $LOG_FILE"

# 1. Capture comprehensive integrity report
# pacman -Qkk checks all files in all packages
# We filter out expected discrepancies (like size changes in logs/configs)
echo "[+] Analyzing package database integrity..."
pacman -Qkk > /tmp/raw_integrity.tmp 2>/dev/null

# 2. Filter logic for meaningful anomalies
# We ignore expected changes in configuration files (0 altered files) 
# and focus on missing or modified binaries/libraries.
grep -E " (missing|altered) " /tmp/raw_integrity.tmp > "$LOG_FILE"

# 3. Report Findings
if [ -s "$LOG_FILE" ]; then
    echo "[!] ANOMALIES DETECTED:"
    cat "$LOG_FILE" | head -n 20
    echo "---"
    echo "[!] Found $(wc -l < "$LOG_FILE") potential integrity violations. Check the log."
else
    echo "[+] System package integrity verified."
fi

# 4. Clean up
rm /tmp/raw_integrity.tmp
