# Moxie - MQTT Pentest Tool

![Moxie - MQTT Recon Tool](moxie.gif)

## Overview

Moxie is a bash script designed for penetration testing MQTT IoT devices. It provides functionalities to test MQTT service on a given target, scan the target for open ports, and perform brute-force attacks for authentication.

## Features

- **MQTT Service Check**: Checks if MQTT service is accessible on a specified IP address and port.
- **Advanced Scan**: Performs an advanced scan using Nmap to gather detailed information about the MQTT service.
- **Brute-force Attack**: Attempts to brute-force the authentication of the MQTT service using provided username and password wordlists.

## Usage

```bash
./moxie.sh <option> [ip] [port]
```

### Options:

- `-c, --check`: Check MQTT service.
- `-s, --scan`: Perform advanced scan.
- `-b, --bruteforce`: Conduct brute-force attack.
- `-h, --help`: Display help message.

## Installation

1. Clone the repository:

```bash
git clone https://github.com/aravind0x7/Moxie.git
cd Moxie
```

2. Make the script executable:

```bash
chmod +x moxie.sh
```

## Examples

- Checking MQTT service:

```bash
./moxie.sh -c 192.168.1.100 1883
```

- Performing advanced scan:

```bash
./moxie.sh -s 192.168.1.100 1883
```

- Conducting brute-force attack:

```bash
./moxie.sh -b 192.168.1.100 1883
```

## Credits

- Created by [aravind0x7](https://aravind0x7.in)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/aravind0x7/Moxie/blob/main/LICENSE) file for details.
