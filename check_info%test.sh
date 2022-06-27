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
    if [ $? = 0 ]; then
    echo -e "\033[\e[1;32m get nvme info success.........................................................please verify the result! \033[0m"
    else
    echo -e "\033[31m get nvme info failed.........................................................please check! \033[0m"
    fi
  done
}
#获取sata_smart信息
check_sata_info() {
  for sata in ${sata_info}; do
    smartctl -i /dev/${sata} >${path}/${sata}.log
    cat ${path}/${sata}.log
    if [ $? = 0 ]; then
    echo -e "\033[\e[1;32m get sata info success.........................................................please verify the result! \033[0m"
    else
    echo -e "\033[31m get sata info failed.........................................................please check! \033[0m"
    fi
  done
}
#获取nvme_pcie速率
check_pcie_info() {
  echo ${pcie_info} > ${path}/${device_no}
  cat ${path}/${device_no}
  if [ $? = 0 ]; then
    echo -e "\033[\e[1;32m get pcie info success.........................................................please verify the result! \033[0m"
  else
    echo -e "\033[31m get pcie info failed.........................................................please check! \033[0m"
  fi
}
echo "请校验nvme硬盘信息："
check_nvme_info
echo "请校验sata硬盘信息："
check_sata_info
echo "请校验nvme_pcie速率信息："
check_pcie_info

