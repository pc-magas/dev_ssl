#/usr/bin/env bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "${BASH_SOURCE}")
# Absolute path this script is in, thus /home/user/bin
BASEDIR=$(dirname ${SCRIPT})


FINAL_CERTPATH=${BASEDIR}

CA_CERT=${BASEDIR}/ca.cert
CA_KEY=${BASEDIR}/ca.key

if  [[ ! -f ${CA_CERT} ]] || [[ ! -f ${CA_KEY} ]]; then
    echo "GENERATING CA CERTIFICATE"
    openssl genrsa -out ${CA_KEY} 2048
    openssl req -x509 -new -nodes \
        -key ${CA_KEY} -subj "/CN=example.local/C=GR/L=ATTICA" \
        -days 1825 -out ${CA_CERT}
    echo "DONE"
    ls -l
    echo "#####################################################"
fi

CERT_BASENAME="www"
CERTIFICATE_PATH=${BASEDIR}/${CERT_BASENAME}.crt
KEY_PATH=${BASEDIR}/${CERT_BASENAME}.key
SIGNING_REQUEST=${BASEDIR}/${CERT_BASENAME}.csr

echo "CREATING CERTIFICATE"

openssl req -new -sha512 -keyout ${KEY_PATH} -nodes -out ${SIGNING_REQUEST} -config ${BASEDIR}/ssl_config
echo "SIGNING CERTIFICATE using CA"

openssl x509 -req -days 9000 -sha512 -in ${SIGNING_REQUEST} -CAkey ${CA_KEY} -CA ${CA_CERT} -CAcreateserial -out ${CERTIFICATE_PATH} 

rm -rf ${SIGNING_REQUEST}

echo "#######################################"
echo "IMPORT these cert into your system as CA cert:"
echo ${CA_CERT}