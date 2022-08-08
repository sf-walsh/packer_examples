#!/bin/bash

# aws s3 ls #Packer Builder would need awscli installed on the base image first and role allowing S3 access
sudo touch /var/www/index.html  >> /tmp/output
sudo ls /var/www/ >> /tmp/output