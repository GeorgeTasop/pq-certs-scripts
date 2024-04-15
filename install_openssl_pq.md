## Notes on installing liboqs and openssl from OQS


* Install these requiredpackages

`sudo apt install cmake gcc libtool libssl-dev make ninja-build git`

* Replace `<OPENSSL_DIR>` with the name of your choosing and run the following: 
```
mkdir openssl_pq
cd openssl_pq
git clone --branch OQS-OpenSSL_1_1_1-stable https://github.com/open-quantum-safe/openssl.git <OPENSSL_DIR>
cd <OPENSSL_DIR>
mkdir oqs

```

3. Navigate to <OPENSSL_DIR> directory and run:

```
git clone --branch main https://github.com/open-quantum-safe/liboqs.git
cd liboqs
mkdir build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX=<OPENSSL_DIR>/oqs -DOQS_USE_OPENSSL=OFF ..
ninja
ninja install
```

4. Navigate to <OPENSSL_DIR> directory and run:
	
```
./Configure no-shared linux-x86_64 -lm
make -j
```