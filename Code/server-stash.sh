#!/bin/bash

# Formatting variables
BOLD="\033[1m"
GREEN="\033[0;32m"
RESET="\033[0m"

echo -e "${BOLD}============================================${RESET}"
echo -e "${BOLD}       SERVER PERFORMANCE STATS             ${RESET}"
echo -e "${BOLD}============================================${RESET}"

# --- STRETCH GOAL: System Info ---
echo -e "${GREEN}[System Information]${RESET}"
echo "OS Version:    $(cat /etc/os-release | grep "PRETTY_NAME" | cut -d '"' -f 2)"
echo "Uptime:        $(uptime -p)"
echo "Load Average:  $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
echo "Logged Users:  $(who | wc -l)"
echo ""

# --- 1. Total CPU Usage ---
# We calculate CPU usage by taking 100% and subtracting the idle time
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
echo -e "${GREEN}[CPU Usage]${RESET}"
echo "Total CPU Usage: ${CPU_USAGE}%"
echo ""

# --- 2. Total Memory Usage ---
echo -e "${GREEN}[Memory Usage]${RESET}"
free -m | awk 'NR==2{printf "Used: %sMB / Total: %sMB (%.2f%%)\nFree: %sMB\n", $3, $2, $3*100/$2, $4}'
echo ""

# --- 3. Total Disk Usage ---
echo -e "${GREEN}[Disk Usage]${RESET}"
df -h --total | grep 'total' | awk '{printf "Used: %s / Total: %s (%s)\nFree: %s\n", $3, $2, $5, $4}'
echo ""

# --- 4. Top 5 Processes by CPU Usage ---
echo -e "${GREEN}[Top 5 Processes by CPU Usage]${RESET}"
ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6
echo ""

# --- 5. Top 5 Processes by Memory Usage ---
echo -e "${GREEN}[Top 5 Processes by Memory Usage]${RESET}"
ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 6
echo ""

# --- STRETCH GOAL: Failed Login Attempts ---
echo -e "${GREEN}[Security]${RESET}"
if [ -f /var/log/auth.log ]; then
    FAILED=$(grep "Failed password" /var/log/auth.log | wc -l)
    echo "Failed login attempts: $FAILED"
elif [ -f /var/log/secure ]; then
    FAILED=$(grep "Failed password" /var/log/secure | wc -l)
    echo "Failed login attempts: $FAILED"
else
    echo "Failed login log not found (check /var/log/auth.log)."
fi

echo -e "${BOLD}============================================${RESET}"a