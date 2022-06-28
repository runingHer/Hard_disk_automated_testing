#!/bin/bash
export nvme_info=$(nvme list | grep "nvme" | awk '{print $1}' | awk -F "/" '{print $NF}')
export sata_info=$(lsscsi | grep "/dev/sd" | awk -F "/" '{print $NF}')
install_fio() {
  yum install -y libaio-devel || apt install -y libaio-dev
  yum install -y nvme*
  yum install -y fio || apt install -y fio
  yum install -y sysstat || apt install -y sysstat
  yum install -y smartmontools || apt install -y smartmontools
}
