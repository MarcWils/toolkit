**Private key exporteren**

`openssl pkcs12 -in cert-to-convert.pfx -nocerts -out private-key.pem`


**Public key exporteren**

`openssl pkcs12 -in cert-to-convert.pfx -clcerts -out public-key.pem`


**Sleutel van private key halen**

`openssl rsa -in private-key.pem -out private.key`


**Nieuw certificaat maken**

`openssl pkcs12 -export -in public-key.pem -inkey private.key -CSP "Microsoft Enhanced RSA and AES Cryptographic Provider" -out cert-with-new-csp.pfx`
