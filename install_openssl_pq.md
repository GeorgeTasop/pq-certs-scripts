#2 Notes on instsalling liboqs and openssl from OQS

1. `sudo apt install cmake gcc libtool libssl-dev make ninja-build git`

2.  
```
cd ~
mkdir openssl_pq
cd openssl_pq
git clone --branch OQS-OpenSSL_1_1_1-stable https://github.com/open-quantum-safe/openssl.git <OPENSSL_DIR>
cd <OPENSSL_DIR>
mkdir oqs

```

3. ```
git clone --branch main https://github.com/open-quantum-safe/liboqs.git
cd liboqs
mkdir build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX=<OPENSSL_DIR>/oqs -DOQS_USE_OPENSSL=OFF ..
ninja
ninja install
```

4. Navigate to <OPENSSL_DIR> dir
```
./Configure no-shared linux-x86_64 -lm
make -j
```