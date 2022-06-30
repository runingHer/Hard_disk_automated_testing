#!/bin/bash
#校验OS中硬盘信息脚本
path=disktest/disk_info
mkdir -p $path
lsscsi >${path}/lsscsi.log
#获取nvme_smart信息
check_nvme_info() {
  declare -p nvme_info &>/dev/null
  if [ $? = 0 ]; then
    for nvme in ${nvme_info}; do
      smartctl -i /dev/${nvme} >${path}/${nvme}.log
      cat ${path}/${nvme}.log
    done
    echo -e "\033[\e[1;32m get nvme info success.........................................................please verify the result! \033[0m"
  else
    echo -e "\033[31m get nvme info failed.........................................................please check! \033[0m"
  fi
}
#获取sata_smart信息
check_sata_info() {
  declare -p sata_info &>/dev/null
  if [ $? = 0 ]; then
    for sata in ${sata_info}; do
      smartctl -i /dev/${sata} >${path}/${sata}.log
      cat ${path}/${sata}.log
    done
    echo -e "\033[\e[1;32m get sata info success.........................................................please verify the result! \033[0m"
  else
    echo -e "\033[31m get sata info failed.........................................................please check! \033[0m"
  fi
}
#获取nvme_pcie速率
check_pcie_info() {
  for device_no in $(lspci | grep "Non-Volatile memory" | awk '{print $1}'); do
    pcie_info=$(lspci -vvvs ${device_no} | grep "LnkSta:")
    echo ${pcie_info} >${path}/${device_no}
    cat ${path}/${device_no}
  done
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
