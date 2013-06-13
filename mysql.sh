echo "Installing MySQL 5.5.."
sudo apt-get install -qqy debconf-utils
cat << EOF | debconf-set-selections
mysql-server-5.0 mysql-server/root_password password azerty
mysql-server-5.0 mysql-server/root_password_again password azerty
mysql-server-5.0 mysql-server/root_password seen true
mysql-server-5.0 mysql-server/root_password_again seen true
EOF
/usr/bin/apt-get -y install mysql-server-5.5 mysql-server