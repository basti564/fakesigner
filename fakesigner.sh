#!/bin/bash
echo "[*] Welcome to basti564's automatic fakesigner"

# Ensure this command is not run from root
if [[ $EUID -eq 0 ]]; then
  echo "[!] Please don't run this script as root!"
  exit
fi

# Ensure ldid command exists
if ! [ -x "$(command -v ldid)" ]; then
    echo "[!] ldid not found!"
    
    if [[ $(command -v sudo -u brew) == "" ]]; then
        echo "[!] Hombrew not installed!"
        echo "[!] Please run the following command!"
        echo '[!] /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
        exit
    else
        echo "[+] Found Homebrew, installing ldid"
        brew install ldid
    fi
fi

# Ensure an ipa file is supplied
if [ -z "$1" ]
  then
    echo "[!] No .ipa file supplied!"
    exit
fi

# Start processing
ipa=$1
echo [*] unpacking..
cd $(dirname $ipa)
unzip "$ipa"
cd Payload
app=$(ls -1)
echo "[*] fakesigning ${app:0:${#app}-4}"
ldid -S "$app/${app:0:${#app}-4}"
echo "[*] fakesigning all Frameworks.."
for f in $app/Frameworks/*.dylib; do
  echo "[*] fakesigning $f"
  ldid -S "$f"
done
cd ..
echo "[*] packaging.."
zip -r "$ipa-fakesigned.ipa" Payload
rm -f -r Payload
echo [*] Created "$ipa-fakesigned.ipa"
