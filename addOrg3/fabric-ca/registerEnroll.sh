#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

function createOrg {
	infoln "Enrolling the CA admin"
	mkdir -p ../organizations/peerOrganizations/${ORG_NAME}.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-${ORG_NAME} --tls.certfiles "${PWD}/fabric-ca/${ORG_NAME}/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/msp/config.yaml"

	infoln "Registering peer0"
  set -x
	fabric-ca-client register --caname ca-${ORG_NAME} --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/fabric-ca/${ORG_NAME}/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-${ORG_NAME} --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/fabric-ca/${ORG_NAME}/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-${ORG_NAME} --id.name ${ORG_NAME}admin --id.secret ${ORG_NAME}adminpw --id.type admin --tls.certfiles "${PWD}/fabric-ca/${ORG_NAME}/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-${ORG_NAME} -M "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/msp" --csr.hosts peer0.${ORG_NAME}.example.com --tls.certfiles "${PWD}/fabric-ca/${ORG_NAME}/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-${ORG_NAME} -M "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/tls" --enrollment.profile tls --csr.hosts peer0.${ORG_NAME}.example.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/${ORG_NAME}/tls-cert.pem"
  { set +x; } 2>/dev/null


  cp "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/tls/ca.crt"
  cp "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/tls/signcerts/"* "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/tls/server.crt"
  cp "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/tls/keystore/"* "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/tls/server.key"

  mkdir "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/msp/tlscacerts"
  cp "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/msp/tlscacerts/ca.crt"

  mkdir "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/tlsca"
  cp "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/tlsca/tlsca.${ORG_NAME}.example.com-cert.pem"

  mkdir "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/ca"
  cp "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/peers/peer0.${ORG_NAME}.example.com/msp/cacerts/"* "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/ca/ca.${ORG_NAME}.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-${ORG_NAME} -M "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/users/User1@${ORG_NAME}.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/${ORG_NAME}/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/users/User1@${ORG_NAME}.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
	fabric-ca-client enroll -u https://${ORG_NAME}admin:${ORG_NAME}adminpw@localhost:11054 --caname ca-${ORG_NAME} -M "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/users/Admin@${ORG_NAME}.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/${ORG_NAME}/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/${ORG_NAME}.example.com/users/Admin@${ORG_NAME}.example.com/msp/config.yaml"
}
