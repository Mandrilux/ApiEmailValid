#!/bin/bash
if [ "$#" -eq  "0" ]
then
    echo "No arguments supplied"
    exit 42
fi
email=$1
echo $email

regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"

if [[ $email =~ $regex ]] ; then
    echo "FORMAT EMAIL OK"
else
    echo "format email invalide"
    exit 42 
fi

domain="$(cut -d @ -f2 <<<$email)"
echo "domaine = " $domain
dns=0
nslookup -q=mx $domain | grep "mail exchanger" && dns=1
if [ $dns == 1 ]
then
    echo "DNS OK"
else
       echo "DNS KO"
       exit 42
fi
mx="$(nslookup -q=mx $domain | grep "mail exchanger" | head -n 1 | cut -d ' ' -f 5)"

echo "le mx  = " $mx
#(sleep 1; echo "helo hi"; sleep 1; echo "mail from: <toto@gmail.com>"; sleep 1; echo "rcpt to: <email@domaine.fr>"; sleep 1; echo "exit") | telnet $mx 25
value="$((sleep 1; echo "helo hi"; sleep 1; echo "mail from: <toto@gmail.com>"; sleep 1; echo "rcpt to: <$email>"; sleep 1; echo "exit") | telnet $mx 25 | grep "250" | wc -l)"
echo $value
if [ $value != 3 ]
then
        echo "Problem with this email"
	exit 42
fi
echo "Email found"
exit 0
