#!/bin/bash
echo "[*] Welcome to basti564's automatic fakesigner"
if [[ $EUID -eq 0 ]]; then
  echo "[!] Please don't run this script as root!"
  exit
fi
if [[ $(command -v sudo -u brew) == "" ]]; then
    echo "[!] Hombrew not installed!"
    echo "[!] Please run the following command!"
    echo '[!] /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    exit
else
    echo "[§] Found Homebrew"
    if brew ls --versions ldid > /dev/null; then
      echo "[§] Found ldid"
    else
      echo "[!] ldid not found!"
      echo "[!] Please install ldid with the following command"
      echo "[!] brew install ldid"
    fi
fi
if [ -z "$1" ]
  then
    echo "[!] No .ipa file supplied!"
    exit
fi

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
