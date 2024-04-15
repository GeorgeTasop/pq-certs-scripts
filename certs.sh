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
		python3 Asn1-to-const.py PEM/ca-key.key
		python3 Asn1-to-const.py PEM/ca-cert.crt
	fi
	python3 Asn1-to-const.py PEM/${peer}-key.key
	python3 Asn1-to-const.py PEM/${peer}-cert.crt

	# Move everything to the appropriate folder
	mv PEM/*.txt PEM-TXT

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
		python3 Asn1-to-const.py DER/ca-key.der
		python3 Asn1-to-const.py DER/ca-cert.der
	fi
	python3 Asn1-to-const.py DER/${peer}-cert.der
	python3 Asn1-to-const.py DER/${peer}-key.der

	# Move everything to the appropriate folder
	mv DER/*.txt DER-TXT

else
	# Print error and exit
	echo "Error: ${openssl_d} not found"
	exit 1
fi
