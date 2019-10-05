#!/bin/bash
apt update
apt install apache2 -y
echo "HELLO EVERYONE HOW R U">/var/www/html/index.html
mkdir d1
cd d1
touch f{1..100}

