#!/bin/bash
#校验OS中硬盘信息脚本
path=disktest/disk_info
mkdir -p $path
#获取磁盘设备号
device_no=$(lspci | grep "Non-Volatile memory" | awk '{print $1}')
pcie_info=$(lspci -vvvs ${device_no} | grep "LnkSta:")
#获取nvme_smart信息
check_nvme_info() {
  for nvme in ${nvme_info}; do
    smartctl -i /dev/${nvme} >${path}/${nvme}.log
    cat ${path}/${nvme}.log
  done
}
#获取sata_smart信息
check_sata_info() {
  for sata in ${sata_info}; do
    smartctl -i /dev/${sata} >${path}/${sata}.log
    cat ${path}/${sata}.log
  done
}
#获取nvme_pcie速率
check_pcie_info() {
  echo ${pcie_info} > ${path}/${device_no}
  cat ${path}/${device_no}
}
echo "请校验nvme硬盘信息："
check_nvme_info
if [ $? = 0 ]; then
    echo "nvme info,PASS....................................!"
else
    echo "nvme info,FAIL....................................!"
fi
echo "请校验sata硬盘信息："
check_sata_info
if [ $? = 0 ]; then
    echo "sata info,PASS....................................!"
else
    echo "sata info,FAIL....................................!"
fi
echo "请校验nvme_pcie速率信息："
check_pcie_info
if [ $? = 0 ]; then
    echo "pcie info,PASS....................................!"
else
    echo "pcie info,FAIL....................................!"
fi
