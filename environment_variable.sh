#!/bin/bash
#设置环境变量及安装包
export nvme_info=$(nvme list | grep "nvme" | awk '{print $1}' | awk -F "/" '{print $NF}')
export sata_info=$(lsscsi | grep "/dev/sd" | awk -F "/" '{print $NF}')
install_fio() {
  yum install -y libaio-devel || apt install -y libaio-dev
  yum install -y nvme*
  yum install -y fio || apt install -y fio
  yum install -y sysstat || apt install -y sysstat
  yum install -y smartmontools || apt install -y smartmontools
}
#删除环境变量及安装包
delete_all() {
  rm -f /etc/profile.d/environment_variable.sh
  yum autoremove -y libaio-devel || apt autoremove -y libaio-dev
  yum autoremove -y nvme*
  yum autoremove -y fio || apt autoremove -y fio
  yum autoremove -y sysstat || apt autoremove -y sysstat
  yum autoremove -y smartmontools || apt autoremove -y smartmontools
}
