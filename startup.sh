# add ppa to source list
echo "deb http://ppa.launchpad.net/vbernat/haproxy-1.7/ubuntu xenial main" > /etc/apt/sources.list.d/vbernat-ubuntu-haproxy-1_7-xenial.list

apt-get update
apt-get install -y vim
apt-get install -y curl
apt-get install -y apache2-utils
apt-get install -y iputils-ping
apt-get install -y nginx
apt-get install -y openssh-server

mkdir -p /var/run/sshd
chmod 0755 /var/run/sshd

if [ $(hostname) == "balancer" ]; then
  # install and configure proxy servers
  yes | apt-get install haproxy
  cp /demo/config/balancer.haproxy /etc/default/haproxy
  cp /demo/config/balancer.haproxy.cfg /etc/haproxy/haproxy.cfg
  cp /demo/config/balancer.default.nginx.conf /etc/nginx/sites-available/default

  ping node1 -c1 | grep "node1" | awk '{print $5}' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| awk '{print $0" node1"}' >> /etc/hosts
  ping node2 -c1 | grep "node2" | awk '{print $5}' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| awk '{print $0" node2"}' >> /etc/hosts
  ping node3 -c1 | grep "node3" | awk '{print $5}' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| awk '{print $0" node3"}' >> /etc/hosts

  if [ "$TESTING" == "haproxy" ]; then
    service haproxy start
  else
    service nginx start
  fi
fi

# print node name to index.html
hostname | tee /var/www/html/index.nginx-debian.html

if [[ $(hostname) =~ ^node.* ]]; then
  service nginx start
fi

# # foreground process
/usr/sbin/sshd -D
