#!/usr/bin/env python3
"""
Tomcat Health Check Script
Description: Monitors Tomcat server status via manager API and HTTP endpoints
Usage: python3 tomcat-health-check.py
"""

import requests
import sys
from datetime import datetime
from requests.auth import HTTPBasicAuth
import json

# Configuration
TOMCAT_HOST = "localhost"
TOMCAT_PORT = 8080
TOMCAT_USER = "admin"  # Change to your Tomcat manager user
TOMCAT_PASS = "password"  # Change to your Tomcat manager password

# Color codes for terminal output
class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    RESET = '\033[0m'

def print_header(text):
    print(f"\n{Colors.CYAN}=== {text} ==={Colors.RESET}")

def print_success(text):
    print(f"{Colors.GREEN}✓ {text}{Colors.RESET}")

def print_error(text):
    print(f"{Colors.RED}✗ {text}{Colors.RESET}")

def check_tomcat_status():
    """Check if Tomcat is responding"""
    print_header("Tomcat Health Check")
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    health_data = {
        "timestamp": datetime.now().isoformat(),
        "checks": {}
    }

    # Check 1: HTTP connectivity
    try:
        url = f"http://{TOMCAT_HOST}:{TOMCAT_PORT}"
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            print_success(f"Tomcat is responding on {url}")
            health_data["checks"]["http_connectivity"] = "OK"
        else:
            print_error(f"Unexpected status code: {response.status_code}")
            health_data["checks"]["http_connectivity"] = f"ERROR: {response.status_code}"
    except requests.exceptions.RequestException as e:
        print_error(f"Cannot connect to Tomcat: {e}")
        health_data["checks"]["http_connectivity"] = f"ERROR: {str(e)}"
        return health_data

    # Check 2: Manager application status
    try:
        manager_url = f"http://{TOMCAT_HOST}:{TOMCAT_PORT}/manager/text/list"
        response = requests.get(
            manager_url,
            auth=HTTPBasicAuth(TOMCAT_USER, TOMCAT_PASS),
            timeout=5
        )

        if response.status_code == 200:
            print_success("Manager application is accessible")

            # Parse deployed applications
            apps = response.text.strip().split('\n')[1:]  # Skip header
            running_apps = 0
            stopped_apps = 0

            print(f"\n{Colors.CYAN}--- Deployed Applications ---{Colors.RESET}")
            for app in apps:
                parts = app.split(':')
                if len(parts) >= 2:
                    app_path = parts[0]
                    app_status = parts[1]

                    if app_status == "running":
                        print(f"{Colors.GREEN}✓{Colors.RESET} {app_path} - running")
                        running_apps += 1
                    else:
                        print(f"{Colors.YELLOW}!{Colors.RESET} {app_path} - {app_status}")
                        stopped_apps += 1

            health_data["checks"]["manager_access"] = "OK"
            health_data["apps_running"] = running_apps
            health_data["apps_stopped"] = stopped_apps

        else:
            print_error(f"Manager application returned status: {response.status_code}")
            print("Note: Check credentials in script configuration")
            health_data["checks"]["manager_access"] = "WARN: Credentials needed"

    except requests.exceptions.RequestException as e:
        print_error(f"Cannot access manager application: {e}")
        health_data["checks"]["manager_access"] = f"ERROR: {str(e)}"

    # Check 3: Server info
    try:
        info_url = f"http://{TOMCAT_HOST}:{TOMCAT_PORT}/manager/text/serverinfo"
        response = requests.get(
            info_url,
            auth=HTTPBasicAuth(TOMCAT_USER, TOMCAT_PASS),
            timeout=5
        )

        if response.status_code == 200:
            print(f"\n{Colors.CYAN}--- Server Information ---{Colors.RESET}")
            for line in response.text.strip().split('\n'):
                if 'Tomcat Version' in line or 'JVM Version' in line or 'OS Name' in line:
                    print(f"  {line}")
            health_data["checks"]["server_info"] = "OK"
    except:
        pass  # Server info is optional

    # Summary
    print_header("Summary")
    total_checks = len(health_data["checks"])
    passed_checks = sum(1 for v in health_data["checks"].values() if v == "OK")

    print(f"Checks passed: {passed_checks}/{total_checks}")
    if "apps_running" in health_data:
        print(f"Applications running: {health_data['apps_running']}")
        print(f"Applications stopped: {health_data['apps_stopped']}")

    # Export health data
    log_file = f"tomcat-health-check-{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(log_file, 'w') as f:
        json.dump(health_data, f, indent=2)

    print(f"\nHealth data exported to: {log_file}\n")

    return health_data

if __name__ == "__main__":
    try:
        health_data = check_tomcat_status()

        # Exit with error if any check failed
        if any("ERROR" in str(v) for v in health_data["checks"].values()):
            sys.exit(1)
        else:
            sys.exit(0)

    except KeyboardInterrupt:
        print("\n\nHealth check interrupted by user")
        sys.exit(130)
    except Exception as e:
        print_error(f"Unexpected error: {e}")
        sys.exit(1)
