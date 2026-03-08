#!/usr/bin/env bash
set -u

# colors
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RESET=$'\033[0m'
BOLD=$'\033[1m'

# Total CPU usage
read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
total_cpu_time=$((user + nice + system + idle + iowait + irq \
		  + softirq + steal))
cpu_usage_pct=$((100 * (total_cpu_time - idle) /  total_cpu_time))

echo -e "${CYAN}CPU usage:${RESET}
${YELLOW}+-- Total:${RESET} ${GREEN}$cpu_usage_pct%${RESET} used"
echo ""



# Total memory usage (Free vs Used including percentage)
read mem_total mem_available  < <(awk '/MemTotal|MemAvailable/ {print $2}' \
			      /proc/meminfo \
			      | xargs)
memory_pct=$((100 * (mem_total - mem_available) / mem_total))

echo -e "${CYAN}Memory usage:${RESET}
${YELLOW}|-- Available:${RESET} ${GREEN}$((mem_available/1024)) MB${RESET}
${YELLOW}+-- Total:${RESET}     ${GREEN}$((mem_total/1024)) MB${RESET} (${GREEN}$memory_pct%${RESET} used)"
echo ""



# Total disk usage (Free vs Used including percentage)
read disk_total disk_used disk_available disk_pct \
	<  <(df -m / | awk 'NR==2 {print $2, $3, $4, $5}')

echo -e "${CYAN}Disk usage (Root):${RESET}
${YELLOW}|-- Total:${RESET}     ${GREEN}$disk_total MB${RESET}
${YELLOW}|-- Used:${RESET}      ${GREEN}$disk_used MB${RESET}
${YELLOW}+-- Available:${RESET} ${GREEN}$disk_available MB${RESET} (${GREEN}$disk_pct${RESET})"
echo ""



# Top 5 processes by CPU usage
echo -e "${CYAN}Top 5 processes by CPU usage:${RESET}"
(
  echo -e "${BOLD}PID PPID CMD CPU${RESET}"
  ps -eo pid,ppid,cmd:40,%cpu --no-headers \
  | sort -nrk4 \
  | head -n 5
) | column -t
echo ""



# Top 5 processes by memory usage
echo -e "${CYAN}Top 5 processes by memory usage:${RESET}"
(
  echo -e "${BOLD}PID PPID CMD MEM${RESET}"
  ps -eo pid,ppid,cmd:40,%mem --no-headers \
  | sort -nrk4 \
  | head -n 5
) | column -t
echo ""
