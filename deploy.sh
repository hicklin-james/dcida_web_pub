SUCCESS=true
tput setaf 4
echo -e "-------------------------------------------------------"
echo -e "Starting DCIDA web app deployment"
echo -e "-------------------------------------------------------\n"
COM1='rm -f /var/www/dcida_web/current/log && rm -rf /var/www/dcida_web/current && mkdir -p /var/www/dcida_web/current'
tput setaf 3
echo "EXECUTE: $COM1"
tput sgr0
if ssh jameshicklin@159.203.30.238 $COM1; then
  tput setaf 2
  echo "SUCCESS! $COM1"
  tput sgr0
else
  tput setaf 1
  echo "ERROR! $COM1"
  SUCCESS=false
  tput sgr0
fi
tput setaf 3
echo -e "\nEXECUTE: scp -r dist/. jameshicklin@159.203.30.238:/var/www/dcida_web/current/"
tput sgr0
if scp -r dist/. jameshicklin@159.203.30.238:/var/www/dcida_web/current/; then
  tput setaf 2
  echo "SUCCESS! scp -r dist/. jameshicklin@159.203.30.238:/var/www/dcida_web/current/"
  tput sgr0
else
  tput setaf 1
  echo "ERROR! scp -r dist/. jameshicklin@159.203.30.238:/var/www/dcida_web/current/"
  SUCCESS=false
  tput sgr0
fi
COM2='ln -s /var/www/dcida_web/shared/log /var/www/dcida_web/current/log'
tput setaf 3
echo -e "\nEXECUTE: $COM2"
tput sgr0
if ssh jameshicklin@159.203.30.238 $COM2; then
  tput setaf 2
  echo "SUCCESS! $COM2"
  tput sgr0
else
  tput setaf 1
  echo "ERROR! $COM2"
  SUCCESS=false
  tput sgr0
fi
if [ "$SUCCESS" = true ]; then
  tput setaf 2
  echo -e "\nDeploy complete"
  tput sgr0
else
  tput setaf 1
  echo -e "\nDeploy complete, but errors occured"
  tput sgr0
fi