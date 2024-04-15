#!/bin/bash

# Exit if errors occured
set -e



# User should set this path to OQS openssl install path
openssl_d=''

if [[ ${openssl_d} == '' ]];
then
	echo "Error: User should set this variable to OQS openssl install path!"
	exit 1;
fi



# Path to OQS openssl binary
oqs=${openssl_d}'/apps/openssl'

# If no argument provided, echo usage and exit
if [[ $# == 0 ]];
then
	echo "Please provide 2 arguments."
	echo 
	echo "Examples: ./certs.sh dilithium2 server"
	echo "	  ./certs.sh dilithium2 client"
	echo "or"
	echo "	  ./certs.sh clean"
	echo "To clean all the created files"
	exit 1;
fi

# If arg is clean, delete directories and exit
if [[ $1 == "clean" ]];
then
	rm -rf PEM
	rm -rf PEM-TXT
	rm -rf DER
	rm -rf DER-TXT
	exit 1
fi

# Set the desired PQ algo
algo=$1

# Set the desired peer (server or client)
peer=$2

# If openssl program exists, enter
if [[ -x ${openssl_d} ]]; 
then

	# Create the directories for the files to be created
	mkdir DER -p
	mkdir DER-TXT -p
	mkdir PEM -p
	mkdir PEM-TXT -p


	# Generate CA keypair, Server or Client cert and get the CA to sign it; everything in PEM format.
	if [[ ! -f PEM/ca-key.key && ! -f PEM/ca-cert.crt ]];
	then
		echo "CA PEM files do not exist; creating them."
		$oqs req -x509 -new -newkey ${algo} -keyout PEM/ca-key.key -out PEM/ca-cert.crt -nodes -subj "/CN=oqstest CA" -days 730 -config ${openssl_d}/apps/openssl.cnf -sha512
	fi
	$oqs genpkey -algorithm ${algo} -out PEM/${peer}-key.key
	$oqs req -new -key PEM/${peer}-key.key -out PEM/${peer}-req.csr -nodes -subj "/CN=oqstest ${peer}" -config ${openssl_d}/apps/openssl.cnf -sha512
	$oqs x509 -req -in PEM/${peer}-req.csr -out PEM/${peer}-cert.crt -CA PEM/ca-cert.crt -CAkey PEM/ca-key.key -CAcreateserial -days 730 -sha512

	# Convert the PEM format to a static const array, ready to be used in C.
	if [[ ! -f PEM-TXT/ca-key.txt && ! -f PEM-TXT/ca-cert.txt ]];
	then
		echo "CA PEM-TXT files do not exist; creating them."
		xxd -i PEM/ca-key.key > PEM-TXT/ca-key.txt
		xxd -i PEM/ca-cert.crt > PEM-TXT/ca-cert.txt
	fi
	xxd -i PEM/${peer}-key.key > PEM-TXT/${peer}-key.txt
	xxd -i PEM/${peer}-cert.crt > PEM-TXT/${peer}-cert.txt

	# Convert everything from PEM format in DER format using the openssl program.
	if [[ ! -f DER/ca-key.der && ! -f DER/ca-cert.der ]];
	then
		echo "CA DER files do not exist; creating them."
		$oqs x509 -inform pem -in PEM/ca-cert.crt -outform der -out DER/ca-cert.der
		$oqs pkcs8 -topk8 -inform PEM -outform DER -in PEM/ca-key.key -out DER/ca-key.der -nocrypt
	fi
	$oqs x509 -inform pem -in PEM/${peer}-cert.crt -outform der -out DER/${peer}-cert.der
	$oqs pkcs8 -topk8 -inform PEM -outform DER -in PEM/${peer}-key.key -out DER/${peer}-key.der -nocrypt


	# Convert the DER format to a static const array, ready to be used in C.
	if [[ ! -f DER-TXT/ca-key.txt && ! -f DER-TXT/ca-cert.txt ]];
	then
		echo "CA DER-TXT files do not exist; creating them."
		xxd -i DER/ca-key.der > DER-TXT/ca-key.txt
		xxd -i DER/ca-cert.der > DER-TXT/ca-cert.txt
	fi
	xxd -i DER/${peer}-key.der > DER-TXT/${peer}-key.txt
	xxd -i DER/${peer}-cert.der > DER-TXT/${peer}-cert.txt

else
	# Print error and exit
	echo "Error: ${openssl_d} not found"
	exit 1
fi
