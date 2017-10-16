echo options dummy numdummies=1 >> /etc/modprobe.d/dummy.conf
sudo yum update -y
sudo tee /etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
sudo yum install bridge-utils net-tools docker-engine -y
sudo service docker start
sudo chkconfig docker on

