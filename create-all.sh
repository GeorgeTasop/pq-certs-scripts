#!/bin/bash

# Exit if errors occured
set -e

# Define all PQ algorithms
algo=("dilithium2" "dilithium3" "dilithium5" "falcon512" "falcon1024")

# If arg is clean, delete directories and exit
if [[ $1 == "clean" ]];
then
	for a in ${algo[@]}; do
		rm -rf $a
	done
	exit 1
fi


# Iterate through algo and create ALL certificates
for a in ${algo[@]}; do

	if [[ ! -d ${a} ]];
	then

		echo "Creating certificates for ${a}"
		echo 
		# Create algorithm directory for the certificates
		mkdir $a

		# Call the certificate generation script
		./certs.sh $a server
		./certs.sh $a client


		# Move the output files in the respective folders
		mv DER $a/DER
		mv DER-TXT $a/DER-TXT
		mv PEM $a/PEM
		mv PEM-TXT $a/PEM-TXT

	else
		echo "Skipping ${a} certs; they already exist"
	fi
		# Echo empty lines and continue
		echo 
		echo "--------"
		echo
done

