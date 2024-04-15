# PQ certificate generation scripts

## Description

This collection of scripts automates the generation of Post-quantum digital certificates, through Open Quantum Safe's fork of [OpenSSL](https://github.com/open-quantum-safe/openssl). It generates certificates for two parties, a server and a client, signed by a CA in PEM format, in DER format and as a plain ".txt" file, ready to be used in an array in C code, for devices without a file system.


## Prerequisites

These scripts assume that OQS's fork of [OpenSSL](https://github.com/open-quantum-safe/openssl) is already installed in your system. If not, follow the [intructions](https://github.com/open-quantum-safe/openssl#quickstart) from their repository.

## Usage

1. Create a directory that the certificates will be saved.

```
mkdir certs
cd certs
```

2. Clone the scripts from this repository in this directory

```
git clone https://github.com/GeorgeTasop/pq-certs-scripts.git
```

3. Edit the `certs.sh` at line 9 with the path of the installed `openssl` directory from OQS.

E.g: If the OQS is installed in `/home/user/oqs-openssl` then the path to `openssl_d` variable should be set to `/home/user/oqs-openssl`


4. Run the "top-level" script `create-all.sh`:

```
./create-all.sh
```
or
```
bash create-all.sh
```

 This will create a directory for every PQ algorithm that is selected.

You can edit the desired PQ algorithms by editing `create-all.sh` at line 7. You can add any algorithm that is **marked with an asterisk** [here](https://github.com/open-quantum-safe/openssl#authentication).

5. If you want to delete the repositories and build them again you can run:

```
./create-all.sh clean
```

## Certificates

These scripts create a directory for every algorithm that is enabled. Inside each of these directories there are subdirectories that contain the certificates in various useful formats. E.g the structure of `dilithium2` directory is as follows:

```
dilithium2
|
├── DER
│   ├── ca-cert.der
│   ├── ca-key.der
│   ├── client-cert.der
│   ├── client-key.der
│   ├── server-cert.der
│   └── server-key.der
├── DER-TXT
│   ├── ca-cert.txt
│   ├── ca-key.txt
│   ├── client-cert.txt
│   ├── client-key.txt
│   ├── server-cert.txt
│   └── server-key.txt
├── PEM
│   ├── ca-cert.crt
│   ├── ca-cert.srl
│   ├── ca-key.key
│   ├── client-cert.crt
│   ├── client-key.key
│   ├── client-req.csr
│   ├── server-cert.crt
│   ├── server-key.key
│   └── server-req.csr
└── PEM-TXT
    ├── ca-cert.txt
    ├── ca-key.txt
    ├── client-cert.txt
    ├── client-key.txt
    ├── server-cert.txt
    └── server-key.txt
```

`PEM`: In PEM directory, we can find the certificates and private keys of the CA, a server and a client. The .srl and .csr files are the signing requests files and we can ignore them. 

`PEM-TXT`: In PEM-TXT directory we can find the certificates and keys in PEM format but in as a ".txt" file. This means that this certificate/key is formatted so it can be easily copied/pasted in an array in a C file. This is particulary usefull for restrained devices that lack a file system.

`DER`: In this directory we can find the certificates and private keys of the PEM dir but transformed into the DER format.

`DER-TXT`: In the same sense as PEM-TXT, the DER-TXT directory include the files in DER format but in a ".txt" file, for easy copy/paste in C code.

## Acknowledgment

The python script are provided by [gntouts](https://github.com/gntouts).
