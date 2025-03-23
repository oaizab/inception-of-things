curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" sh -

sleep 10

NODE_TOKEN='/var/lib/rancher/k3s/server/node-token'

while [ ! -f $NODE_TOKEN ]; do
    sleep 2
done

cp $NODE_TOKEN /vagrant/

cp /etc/rancher/k3s/k3s.yaml /vagrant/k3s.yaml