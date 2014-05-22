#!/bin/bash
# -*- mode:shell-script; coding:utf-8; -*-
#
# Load data into an Apigee Edge Key-Value Map.
#
# See the doc on the API at: http://apigee.com/docs/api/keyvalue-maps
#
#
# Created: <Wed May 21 21:35:20 2014>
# Last Updated: <2014-May-22 08:31:42>
#

scriptname=loadEdgeKvm
defaultmgmtserver=http://mgmt1.karmalab.example.com
apigeeuser=
apigeepassword=
orgname=ORGNAME
envname=
apiname=
mapname=
propfile=
testonly=0
# use this dot-file to store creds if you like
credsfile=.credentials
verbosity=2
TAB=$'\t'


function usage() {
  local CMD=`basename $0`
  echo "$CMD: load a Key-Value Map in Apigee Edge with data. "
  echo "  This script reads a properties file for entries like KEY=VALUE,"
  echo "   then formats a request to load that data into a KVM, and sends it."
  echo "usage: "
  echo "  $CMD [options] "
  echo "options: "
  echo "  -u user      user that has admin access."
  echo "  -p password  password for the given user"
  echo "  -s server    base url for the Edge management server"
  echo "  -m mapname   name of the map to load (and potentially overwrite)"
  echo "  -f propfile  name of file containing KEY=VALUE properties"
  echo "  -e env       environment. Specify if desiring environment-scoped map"
  echo "  -a api       api name. Specify if desiring API-scoped map"
  echo "  -t           test only; do not execute the command."
  echo
  echo "To avoid passing credentials on the command line, you can store credentials"
  echo "in a file called .credentials. The contents should be like this: "
  echo "     apigeeuser=username"
  echo "     apigeepassword=password"
  exit 1
}

function get_password() {
  local password
  echo
  echo -n "  Admin password for ${apigeeuser} on ${mgmtserver}? :: " 
  read -s password
  echo
  apigeepassword=$password
}

function get_user() {
  local user
  echo
  read -p "  Admin user at ${mgmtserver}? :: " user
  echo
  apigeeuser=$user
}

function get_mapname() {
  local name
  echo
  read -p "  KVM name? :: " name
  echo
  mapname=$name
}

function get_mgmtserver() {
  local name
  echo
  read -p "  Which mgmt server (${defaultmgmtserver}) :: " name
  name="${name:-$defaultmgmtserver}"
  mgmtserver=$name
  echo "  mgmt server = ${mgmtserver}"
}

function check_org() {
  echo "  verifying access to org ${orgname}..."
  MYCURL -u ${credentials} -X GET  ${mgmtserver}/v1/o/${orgname}
  if [ ${CURL_RC} -eq 200 ]; then
    check_org=0
  else
    check_org=1
  fi
}

function choose_org() {
  local all_done
  all_done=0
  while [ $all_done -ne 1 ]; do
      echo
      read -p "  Which org? " orgname
      check_org 
      if [ ${check_org} -ne 0 ]; then
        echo "cannot read that org with the given creds."
        echo
        all_done=0
      else
        all_done=1
      fi
  done
  echo
}

function determine_kvm_url_and_verb() {
  local url 
  if [ "X${apiname}" != "X" ]; then
    if [ "X${envname}" != "X" ]; then
      echo "inconsistent input. Specify -a or -e, not both." 
      CleanUp
      usage
    fi
    url=${mgmtserver}/v1/o/${orgname}/apis/${apiname}/keyvaluemaps
  elif [ "X${envname}" != "X" ]; then
    url=${mgmtserver}/v1/o/${orgname}/e/${envname}/keyvaluemaps
  else 
    url=${mgmtserver}/v1/o/${orgname}/keyvaluemaps
  fi 

  namedkvmurl=${url}/${mapname}
  ## test if the map already exists
  MYCURL -u ${credentials} -X GET ${url}/${mapname}
  if [ ${CURL_RC} -eq 200 ]; then
    verb=PUT
    url=${namedkvmurl}
  else
    verb=POST
  fi

  kvmurl=$url
}



## function MYCURL
## Print the curl command, omitting sensitive parameters, then run it.
## There are side effects:
## 1. puts curl output into file named ${CURL_OUT}. If the CURL_OUT
##    env var is not set prior to calling this function, it is created
##    and the name of a tmp file in /tmp is placed there.
## 2. puts curl http_status into variable CURL_RC
function MYCURL() {
  local outargs
  local allargs
  local ix
  local ix2
  local re
  re="^(-[u]|--user)$" # the curl options to not echo
  # grab the curl args, but skip the basic auth and the payload, if any.
  while [ "$1" ]; do
      allargs[$ix2]=$1
      let "ix2+=1"
      if [[ $1 =~ $re ]]; then
        shift
        allargs[$ix2]=$1
        let "ix2+=1"
      else
        outargs[$ix]=$1
        let "ix+=1"
      fi
      shift
  done

  [ -z "${CURL_OUT}" ] && CURL_OUT=`mktemp /tmp/apigee-${scriptname}.curl.out.XXXXXX`
  [ -f "${CURL_OUT}" ] && rm ${CURL_OUT}

  if [ $verbosity -gt 1 ]; then
    # emit the curl command, without the auth + payload
    echo
    echo "curl ${outargs[@]}"
  fi
  # run the curl command
  CURL_RC=`curl -s -w "%{http_code}" -o "${CURL_OUT}" "${allargs[@]}"`
  if [ $verbosity -gt 1 ]; then
    # emit the http status code
    echo "==> ${CURL_RC}"
    echo
  fi
}

function CleanUp() {
  if [ -f ${CURL_OUT} ]; then
    rm -rf ${CURL_OUT}
  fi
}


# load creds if necessary
[ -f ${credsfile} ] && . ${credsfile}

while getopts "hu:p:m:s:o:e:a:f:t" opt; do
  case $opt in
    h) usage ;;
    u) apigeeuser=$OPTARG ;;
    p) apigeepassword=$OPTARG ;;
    s) mgmtserver=$OPTARG ;;
    o) orgname=$OPTARG ;;
    a) apiname=$OPTARG ;;
    e) envname=$OPTARG ;;
    m) mapname=$OPTARG ;;
    f) propfile=$OPTARG ;;
    t) testonly=1 ;;
    *) echo "unknown arg" && usage ;;
  esac
done


echo
[ "X$mgmtserver" = "X" ] && get_mgmtserver
[ "X$apigeeuser" = "X" ] && get_user
[ "X$apigeepassword" = "X" ] && get_password
credentials=${apigeeuser}:${apigeepassword}

echo
if [ "X$orgname" = "X" ]; then
  choose_org
else
  check_org 
  if [ ${check_org} -ne 0 ]; then
    echoerror "that org cannot be validated"
    CleanUp
    exit 1
  fi
fi 

[ "X$propfile" = "X" ] && echo "specify a properties file." && usage
[ ! -f "${propfile}" ] && echo "that file does not exist." && usage
[ "X$mapname" = "X" ] && get_mapname

# build a json string
payload=
linum=1
while read -r line
do
    IFS='=' read -ra KVPAIR <<< "$line"
    [ ${#KVPAIR[@]} -ne 2 ] && echo "bad input, line ${linum}" && usage
    [ ${linum} -gt 1 ] && payload+=","
    payload+="{ \"name\" : \"${KVPAIR[0]}\" , \"value\" : \"${KVPAIR[1]}\" }"
    let linum+=1
done < "${propfile}"

payload="{ \"entry\" : [ ${payload} ], \"name\" : \"${mapname}\" }" 


# The url and verb varies depending on scope and whether the map
# already exists. This fn determines the needful. 
determine_kvm_url_and_verb

if [ $testonly -gt 0 ]; then 
  echo
  echo "Run this command to load the KVM: "
  echo 
  echo "  curl -X ${verb} -H content-type:application/json \\"
  echo "     ${kvmurl} \\"
  echo "     -d '${payload}'"
  echo 
else
  verbosity+=1
  PAYLOAD_FILE=`mktemp /tmp/apigee-${scriptname}.payload.XXXXXX`
  echo ${payload} > ${PAYLOAD_FILE}
  MYCURL -u ${credentials} -X ${verb} -H content-type:application/json \
     ${kvmurl} \
     -d @${PAYLOAD_FILE}
  if [[ ${CURL_RC} -ne 200 && ${CURL_RC} -ne 201 ]]; then
    echo "There was an error."
    echo "payload: "
    cat ${PAYLOAD_FILE}
    echo
    echo "response: "
    cat ${CURL_OUT}
  else 
    MYCURL -u ${credentials} -X GET ${namedkvmurl}
    cat ${CURL_OUT}
  fi
  [ -f ${PAYLOAD_FILE} ] && rm -f ${PAYLOAD_FILE}
  echo
fi

CleanUp
