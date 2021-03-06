#!/bin/bash

export MUJINA_CERT=MIICHzCCAYgCCQD7KMJ17XQa7TANBgkqhkiG9w0BAQUFADBUMQswCQYDVQQGEwJO\
TDEQMA4GA1UECAwHVXRyZWNodDEQMA4GA1UEBwwHVXRyZWNodDEQMA4GA1UECgwH\
U3VyZm5ldDEPMA0GA1UECwwGQ29uZXh0MB4XDTEyMDMwODA4NTQyNFoXDTEzMDMw\
ODA4NTQyNFowVDELMAkGA1UEBhMCTkwxEDAOBgNVBAgMB1V0cmVjaHQxEDAOBgNV\
BAcMB1V0cmVjaHQxEDAOBgNVBAoMB1N1cmZuZXQxDzANBgNVBAsMBkNvbmV4dDCB\
nzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA2slVe459WUDL4RXxJf5h5t5oUbPk\
PlFZ9lQysSoS3fnFTdCgzA6FzQzGRDcfRj0HnWBdA1YH+LxBjNcBIJ/nBc7Ssu4e\
4rMO3MSAV5Ouo3MaGgHqVq6dCD47f52b98df6QTAA3C+7sHqOdiQ0UDCAK0C+qP5\
LtTcmB8QrJhKmV8CAwEAATANBgkqhkiG9w0BAQUFAAOBgQCvPhO0aSbqX7g7IkR7\
9IFVdJ/P7uSlYFtJ9cMxec85cYLmWL1aVgF5ZFFJqC25blyPJu2GRcSxoVwB3ae8\
sPCECWwqRQA4AHKIjiW5NgrAGYR++ssTOQR8mcAucEBfNaNdlJoy8GdZIhHZNkGl\
yHfY8kWS3OWkGzhWSsuRCLl78A==
export MUJINA_KEY=MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBANrJVXuOfVlAy+EV8SX+YebeaFGz\
5D5RWfZUMrEqEt35xU3QoMwOhc0MxkQ3H0Y9B51gXQNWB/i8QYzXASCf5wXO0rLuHuKzDtzEgFeT\
rqNzGhoB6launQg+O3+dm/fHX+kEwANwvu7B6jnYkNFAwgCtAvqj+S7U3JgfEKyYSplfAgMBAAEC\
gYBaPvwkyCTKYSD4Co37JxAJJCqRsQtv7SyXoCl8zKcVqwaIz4rUQRVN/Hv3/WjIFzqB3xLe4mjN\
YBIF31YWt/6ZslaLL5YJIXISrMgDuQzPKL8VqvvsH9XEpi/qSUsVAWa9Vaqqwa8JTPELK8QhHKaX\
TxGtatEuW1x6kSNXFCoasQJBAPUaYdj9oCDOGTaOaupF0GB6TIgIItpQESY1Dfpn4cvwB0jH8wBJ\
SBVeBqSa6dg4RI5ydD3J82xlF7NrQnvWpYkCQQDkg26KzQckoJ39HX2gYS4olSeQDAyIDzeCMkj7\
McDhigy0cL6k9nOQrKlq6V3vkBISTRg7JceJ4z3QE00edXWnAkEAoggv2WBJxIYbOurJmVhP2gff\
oiomyEYYIDcAp6KXLdffKOkuJulLIv0GzTiwEMWZ5MWbPOHN78Gg+naU/AM5aQJBALfbsANpt4eW\
28ceBUgXKMZqS+ywZRzL8YOF5gaGH4TYSCSeWiXsTUtoQN/OaFAqAQBMm2Rrn0KoXcGe5fvN0h0C\
QQDgNLxVcByrVgmRmTPTwLhSfIveOqE6jBlQ8o0KyoQl4zCSDDtMEb9NEFxxvI7NNjgdZh1RKrzZ\
5JCAUQcdrEQJ

STATUS_IDP=$(curl -v --silent http://localhost:8080 2>&1 | grep "Identity Provider Home Page" | wc -l)
until [ "$STATUS_IDP" -ge "1" ]; do
  >&2 echo "Waiting for the IDP server to be ready"
  STATUS_IDP=$(curl -v --silent http://localhost:8080 2>&1 | grep "Identity Provider Home Page" | wc -l)
  sleep 5
done
>&2 echo "Running IDP API setup commands"

curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X POST -d "{\"certificate\": \"$MUJINA_CERT\",\"key\":\"$MUJINA_KEY\"}" \
        http://localhost:8080/api/signing-credential

curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X PUT -d '{"url": "http://localhost/saml/acs"}' \
        http://localhost:8080/api/acsendpoint

curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X PUT -d '{"name": "test", "password": "test", "authorities": ["ROLE_USER", "ROLE_ADMIN"]}' \
        http://localhost:8080/api/users

curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X PUT -d '{"value": "ALL"}' \
        http://localhost:8080/api/authmethod

STATUS_SP=$(curl -v --silent http://localhost:8080 2>&1 | grep "Identity Provider Home Page" | wc -l)
until [ "$STATUS_SP" -ge "1" ]; do
  >&2 echo "Waiting for the IDP server to be ready"
  STATUS_SP=$(curl -v --silent http://localhost:8080 2>&1 | grep "Identity Provider Home Page" | wc -l)
  sleep 5
done
>&2 echo "Running SP API setup commands"

curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X POST -d "{\"certificate\": \"$MUJINA_CERT\",\"key\":\"$MUJINA_KEY\"}" \
        http://localhost:9090/api/signing-credential

curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X PUT -d '{"value": "http://localhost:8080/SingleSignOnService"}' \
        http://localhost:9090/api/ssoServiceURL

curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X PUT -d '{"value": "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"}' \
        http://localhost:9090/api/protocolBinding
