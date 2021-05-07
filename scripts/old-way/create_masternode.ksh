IP=${1:-18.197.51.218}
OUTPUT=master.out
TOKENFILE=mytoken.tmp

rm -f $TOKENFILE
rm -f *.out

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
echo "--> Creating master node"
sudo k0s install controller --single

echo "--> Enable System start k0s service"
sudo systemctl start k0scontroller.service
sudo systemctl enable k0scontroller

echo "--> Run first kubectl command"
sudo k0s kubectl get pods

echo "--> Create token file"
sudo k0s token create --role=worker > /tmp/token.txt
echo "=========================================================="
sudo cat /tmp/token.txt

_EOF

# GET TOKEN FROM OUTPUT
typeset -i TRIGGER=0
rm -f $TOKENFILE
while read REGEL
do
	# Then recreate tokenfile
	if [ $TRIGGER -eq 1 ]
	then
		echo "$REGEL" >> $TOKENFILE
	fi

	# Wait for ====
	if [ `echo "$REGEL" | grep "====" | wc -l` -eq 1 ]
	then
          typeset -i TRIGGER=1
	fi
done < $OUTPUT


