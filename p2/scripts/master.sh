curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" sh -

sleep 10

K3SYAML='/etc/rancher/k3s/k3s.yaml'

while [ ! -f $K3SYAML ]; do
    sleep 2
done

cp /etc/rancher/k3s/k3s.yaml /vagrant/k3s.yaml
sed -i 's/server: https:\/\/127.0.0.1:6443/server: https:\/\/192.168.56.110:6443/' /vagrant/k3s.yaml
