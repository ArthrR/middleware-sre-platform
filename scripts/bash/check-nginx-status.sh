#!/bin/bash

###############################################################################
# Nginx Health Check Script
# Description: Monitors Nginx service status, configuration, and performance
# Usage: ./check-nginx-status.sh
###############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== Nginx Health Check ===${NC}"
echo -e "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')\n"

# Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    echo -e "${RED}✗ Nginx is not installed${NC}"
    exit 1
fi

# Check Nginx service status
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✓ Nginx service is running${NC}"
    SERVICE_STATUS="running"
else
    echo -e "${RED}✗ Nginx service is not running${NC}"
    SERVICE_STATUS="stopped"
fi

# Check configuration validity
echo -e "\n${CYAN}--- Configuration Test ---${NC}"
if nginx -t 2>&1 | grep -q "syntax is ok"; then
    echo -e "${GREEN}✓ Nginx configuration is valid${NC}"
    CONFIG_STATUS="valid"
else
    echo -e "${RED}✗ Nginx configuration has errors${NC}"
    nginx -t
    CONFIG_STATUS="invalid"
fi

# Get Nginx version
NGINX_VERSION=$(nginx -v 2>&1 | awk -F'/' '{print $2}')
echo -e "\n${CYAN}--- Version Information ---${NC}"
echo -e "Nginx version: ${NGINX_VERSION}"

# Check listening ports
echo -e "\n${CYAN}--- Listening Ports ---${NC}"
netstat -tlnp 2>/dev/null | grep nginx || ss -tlnp | grep nginx

# Check active connections (if status module enabled)
if curl -s http://localhost/nginx_status &> /dev/null; then
    echo -e "\n${CYAN}--- Active Connections ---${NC}"
    curl -s http://localhost/nginx_status
fi

# Check error log for recent issues (last 10 lines)
if [ -f /var/log/nginx/error.log ]; then
    echo -e "\n${CYAN}--- Recent Errors (last 10 lines) ---${NC}"
    tail -n 10 /var/log/nginx/error.log | grep -i error || echo "No recent errors"
fi

# Summary
echo -e "\n${CYAN}=== Summary ===${NC}"
echo -e "Service Status: ${SERVICE_STATUS}"
echo -e "Config Status: ${CONFIG_STATUS}"
echo -e "Version: ${NGINX_VERSION}"

# Export to log file
LOG_FILE="nginx-health-check-$(date +%Y%m%d_%H%M%S).log"
{
    echo "Nginx Health Check - $(date)"
    echo "Service: ${SERVICE_STATUS}"
    echo "Config: ${CONFIG_STATUS}"
    echo "Version: ${NGINX_VERSION}"
} > "${LOG_FILE}"

echo -e "\nHealth check logged to: ${LOG_FILE}"
echo ""

# Exit with appropriate code
if [ "$SERVICE_STATUS" == "running" ] && [ "$CONFIG_STATUS" == "valid" ]; then
    exit 0
else
    exit 1
fi
