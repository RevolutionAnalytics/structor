# Copyright 2011 Revolution Analytics
#
# Licensed under the Apache License, Version 2.0 (the License);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an AS IS BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -e
#For some reason these dependencies of RRO does not get installed, so do it here
sudo yum -y install libXmu-devel || apt-get install -y libxmu-dev
sudo yum -y install gcc-gfortran || apt-get install -y gcc-gfortan

#download and install RRO
ls RRO.rpm || curl -L http://mran.revolutionanalytics.com/install/RRO-8.0-Beta-el6.x86_64.rpm > RRO.rpm
rpm -q RRO || sudo rpm --install RRO.rpm

# this is for devtools
sudo yum -y install curl curl-devel || apt-get install -y curl curl-devel

#Install rJava

sudo yum -y install java-1.7.0-openjdk.x86_64 || apt-get install -y java-1.7.0-openjdk.x86_64
sudo -E R CMD javareconf 
sudo R --no-save << EOF
install.packages("rJava", lib="/usr/lib64/RRO-8.0/R-3.1.1/lib64/R/library")
EOF

#download rmr  quickcheck ravro rhdfs
sudo rm -rf rmr2* quickcheck* ravro* rhdfs*
wget  --no-verbose --no-check-certificate https://github.com/RevolutionAnalytics/rhdfs/archive/master.tar.gz -O - | tar zx
wget  --no-verbose --no-check-certificate https://github.com/RevolutionAnalytics/rmr2/archive/master.tar.gz -O - | tar zx
wget  --no-verbose --no-check-certificate https://github.com/RevolutionAnalytics/quickcheck/archive/master.tar.gz -O - | tar zx
wget  --no-verbose --no-check-certificate https://github.com/RevolutionAnalytics/ravro/archive/master.tar.gz -O - | tar zx
mv rmr2* rmr2
mv quickcheck* quickcheck
mv ravro* ravro
mv rhdfs* rhdfs

#Install dependencies for all pakgs
sudo R --no-save << EOF
lib='/usr/lib64/RRO-8.0/R-3.1.1/lib64/R/library'
install.packages("devtools", lib = lib)
library(devtools)
install_deps_libpath = 
  function(pkgs) {
    deps = c("Imports", "Depends", "Suggests")
    sapply(
      pkgs, 
        function(pkg)
           with_libpaths(
             devtools::install_deps(
               pkg, 
               dependencies = deps), 
             new = lib))}
install_deps_libpath(c("ravro/pkg/ravro", "rmr2/pkg", "quickcheck/pkg", "rhdfs/pkg"))
EOF


sudo R CMD INSTALL  rmr2/pkg/
sudo R CMD INSTALL quickcheck/pkg/
sudo R CMD INSTALL ravro/pkg/ravro

export HADOOP
sudo -E  R CMD INSTALL rhdfs/pkg

#set the environment variables
sudo su << EOF1
cat >> /etc/profile << EOF

export HADOOP_CMD=`which hadoop`
export HADOOP_STREAMING=`find / -name *streaming*jar 2>/dev/null | head -1`

EOF
EOF1





