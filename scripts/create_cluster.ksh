IP1=${1:0}
IP2=${2:0}
IP3=${3:0}

TEMPLATEFILE=/home/ec2-user/TF/3nodes_k0s/templates/cluster.yaml
RESULT=/home/ec2-user/TF/3nodes_k0s/scripts/cluster.yaml

rm -f ${RESULT}*

cat ${TEMPLATEFILE} | sed "s|<IP1>|${IP1}|g" > ${RESULT}.1
cat ${RESULT}.1 | sed "s|<IP2>|${IP2}|g" > ${RESULT}.2
cat ${RESULT}.2 | sed "s|<IP3>|${IP3}|g" > ${RESULT}

if [ ! -f /usr/local/bin/k0sctl ] 
then
	sudo cp k0sctl /usr/local/bin/
fi

k0sctl apply --config ${RESULT}

k0sctl kubeconfig --config ${RESULT} > k0s.config

echo "NODES:"
kubectl get nodes --kubeconfig k0s.config
echo "RUNNING PODS:"
kubectl get pods --kubeconfig scripts/k0s.config --all-namespaces

echo "WANT THIS IN LENS - Copy kubeconfig from scripts/k0s.config"
