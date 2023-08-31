#!/bin/bash
## Tested on Ubuntu and similar flavors
## This script generates config.sh for deploying Outline
echo "! gen-config.sh started"
echo "---"

usage()
{ # print usage
  echo '> generates Outline Wiki config values'
  echo '$ ./gen-config.sh <app URL> <host port> <minio URL> <minio bucket>'
}

# argument variables
app_url=
hostport=
minio_url=
minio_bucket=
minio_accesskey=
minio_secretkey=

# -h or --help displays usage message
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	usage
  exit
fi

# assign app_url to $1 or prompt for app_url
if [[ -z "$1" ]]; then
  while [[ -z "$app_url" ]]
  do
    read -p "> Instance URL (e.g. https://outline.wiki.com): " app_url
  done
else
  app_url=$1
  echo "! Instance URL: $app_url"
fi
# after app_url is set, determine network name
network_name="$(echo $app_url | sed "s|https://||g" | sed "s|http://||g" | sed "s|:|_|g" | sed "s|\.||g")_net"
echo "! Network name: $network_name"

# assign $hostport to $2 or prompt for host port
if [ -z "$2" ]; then
  while [[ -z "$hostport" ]]
  do
    read -p "> Host port (e.g. 4427): " hostport
  done
else
  hostport=$2
  echo "! Host port: $hostport"
fi

# assign $minio_url to $3 or prompt for minio url
if [ -z "$3" ]; then
  while [[ -z "$minio_url" ]]
  do
    read -p "> Minio URL (e.g. https://obj.data.com): " minio_url
  done
else
  minio_url=$3
  echo "! Minio URL: $minio_url"
fi

# assign $minio_bucket to $4 or prompt for bucket name
if [ -z "$4" ]; then
  while [[ -z "$minio_bucket" ]]
  do
    read -p "> Minio bucket (e.g objdatabucket): " minio_bucket
  done
else
  minio_bucket=$4
  echo "! Minio bucket: $minio_bucket"
fi

# if $MINIO_ACCESS_KEY is not set, prompt for minio access key
if [ -z "$MINIO_ACCESS_KEY" ]; then
  while [[ -z "$minio_accesskey" ]]
  do
    read -p "> minio access key: " minio_accesskey
  done
else
  minio_accesskey=$MINIO_ACCESS_KEY
  echo "! minio access key: $minio_accesskey"
fi

# if $MINIO_SECRET_KEY is not set, prompt for minio secret key
if [ -z "$MINIO_SECRET_KEY" ]; then
  while [[ -z "$minio_secretkey" ]]
  do
    read -p "> minio secret key: " minio_secretkey
  done
else
  minio_secretkey=$MINIO_SECRET_KEY
  echo "! minio secret key: $minio_secretkey"
fi

# ask to configure email delivery
read -n1 -p "> configure email delivery? [Y/y] " key
if [[ "$key" == "y" || "$key" == "Y" ]] ; then
  while [[ -z "$smtp_host" ]]
  do
    echo ''; read -p "> SMTP hostname: " smtp_host
  done
  while [[ -z "$smtp_port" ]]
  do
    read -p "> SMTP port: " smtp_port
  done
  while [[ -z "$smtp_email" ]]
  do
    read -p "> SMTP email: " smtp_email
  done
  while [[ -z "$smtp_pass" ]]
  do
    read -sp "> SMTP password: " smtp_pass
  done
fi

# ask to use the latest versions or prompt
echo ''; read -n1 -p "> use latest versions? [Y/y] " key
if [[ "$key" == "y" || "$key" == "Y" ]] ; then
  outline_v=latest
  postgres_v=latest
  minio_v=latest
  minio_mc_v=latest
else
  outline_v=0.71.0
  postgres_v=15.2-alpine3.17
  minio_v=RELEASE.2022-11-17T23-20-09Z
  minio_mc_v=RELEASE.2022-11-17T21-20-39Z
fi

# ask to set the timezone or continue
echo ''; read -n1 -p "> configure the timezone? [Y/y] " key
if [[ "$key" == "y" || "$key" == "Y" ]] ; then
  echo ''; 
  while [[ -z "$timezone" ]]
  do
    read -p "> timezone (default is 'UTC'): " timezone
  done
else
  echo ''; 
fi

# remove preexisting config.sh if exists
if [[ -f ./scripts/config.sh ]] ; then
  echo "> deleting existing ./scripts/config.sh"
  rm -f ./scripts/config.sh
fi
# replace placeholder values with bash variables
echo "> copying config.sh.tmpl to config.sh"
cp ./scripts/config.sh.tmpl ./scripts/config.sh

# replace placeholder values with bash variables
echo "> updating config.sh variables with sed"
# main
sed -i "s|URL=|URL=${app_url}|g" scripts/config.sh
sed -i "s|NETWORKS=|NETWORKS=${network_name}|g" scripts/config.sh
sed -i "s|HTTP_PORT_IP=8888|HTTP_PORT_IP=${hostport}|g" scripts/config.sh
# email
sed -i "s|SMTP_HOST=|SMTP_HOST=${smtp_host}|g" scripts/config.sh
sed -i "s|SMTP_PORT=|SMTP_PORT=${smtp_port}|g" scripts/config.sh
sed -i "s|SMTP_USERNAME=|SMTP_USERNAME=${smtp_email}|g" scripts/config.sh
sed -i "s|SMTP_PASSWORD=|SMTP_PASSWORD=${smtp_pass}|g" scripts/config.sh
sed -i "s|SMTP_FROM_EMAIL=|SMTP_FROM_EMAIL=${smtp_email}|g" scripts/config.sh
sed -i "s|SMTP_REPLY_EMAIL=|SMTP_REPLY_EMAIL=${smtp_email}|g" scripts/config.sh
# versions
sed -i "s|OUTLINE_VERSION=|OUTLINE_VERSION=${outline_v}|g" scripts/config.sh
sed -i "s|POSTGRES_VERSION=|POSTGRES_VERSION=${postgres_v}|g" scripts/config.sh
sed -i "s|MINIO_VERSION=|MINIO_VERSION=${minio_v}|g" scripts/config.sh
sed -i "s|MINIO_MC_VERSION=|MINIO_MC_VERSION=${minio_mc_v}|g" scripts/config.sh
# minio
sed -i "s|MINIO_URL=|MINIO_MC_VERSION=${minio_url}|g" scripts/config.sh
sed -i "s|MINIO_BUCKET=|MINIO_BUCKET=${minio_bucket}|g" scripts/config.sh
sed -i "s|MINIO_ACCESS_KEY=|MINIO_ACCESS_KEY=${minio_accesskey}|g" scripts/config.sh
sed -i "s|MINIO_SECRET_KEY=|MINIO_SECRET_KEY=${minio_secretkey}|g" scripts/config.sh
# timezone
sed -i "s|TIME_ZONE=UTC|TIME_ZONE=${timezone}|g" scripts/config.sh

echo "---"
echo "! to review the configuration:"
echo "less scripts/config.sh"
echo "! gen-config.sh finished"