#!/bin/sh
# Generate self-signed certificate

# set -e
# set -x

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"

# usage output
function usage {
    echo "Self-signed certificate generator"
    echo "Generates self signed certificate and key files using openssl"
    echo "Usage: ./generate_ss_keys.sh -n mycert"
    echo "Outcome: mycert.csr, mycert.key and mycert.crt files"
    echo "  -h --help   Show help text for this script"
    echo "  -n --name   Name of the certificate, by default it uses my_self_signed string to name the files"
    exit 1
}

KEY_NAME=my_self_signed

while [ $# -gt 0 ]; do
    case $1 in
        -n | --name)
            shift
            KEY_NAME="${1}"
            ;;
        -h | --help)
            usage
            ;;
        *)
            usage
            ;;
	esac
done


echo "Key and certificate name will be: ${KEY_NAME}"

# Generate private key
openssl genrsa -out ${KEY_NAME}.key 2048 

# Generate CSR 
openssl req -new -key ${KEY_NAME}.key -out ${KEY_NAME}.csr

# Generate Self Signed Key
openssl x509 -req -days 365 -in ${KEY_NAME}.csr -signkey ${KEY_NAME}.key -out ${KEY_NAME}.crt
