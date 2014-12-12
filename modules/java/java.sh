set -e
test -f /usr/bin/java && exit 0
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/6u31-b04/jdk-6u31-linux-x64.bin
chmod u+x jdk-6u31-linux-x64.bin
mkdir /usr/jdk1.6.0_31
cd /usr/jdk1.6.0_31
~/jdk-6u31-linux-x64.bin -noregister
mkdir /usr/java
ln -s /usr/jdk1.6.0_31/jdk1.6.0_31 /usr/java/default
ln -s /usr/java/default/bin/java /usr/bin/java
