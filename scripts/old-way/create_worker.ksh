IP=${1:-3.67.91.103}
OUTPUT=worker.out
TOKENFILE=mytoken.tmp

sftp -i ~/.ssh/rohaMirantis.pem ubuntu@${IP} << _EOF
put mytoken.tmp
_EOF

ssh ubuntu@${IP} -o "StrictHostKeyChecking=no" -i ~/.ssh/rohaMirantis.pem  << _EOF > $OUTPUT 2>&1

echo "DOWNLOAD software & INSTALL"
curl -sSfL https://get.k0s.sh | sudo sh
echo "k0s software available?"
k0s version
if [ $? -eq 0 ]
then
  echo "Yes"
else 
  echo "No. EXIT!"
  exit 1
fi
echo "--> Creating WORKER node"
sudo k0s install worker --token-file mytoken.tmp

echo "--> Enable System start k0sworker service"
sudo systemctl start k0sworker

echo "--> Run first kubectl command"
sudo k0s kubectl get nodes

_EOF


cat $OUTPUT
