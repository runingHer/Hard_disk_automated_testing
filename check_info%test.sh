#!/bin/bash
#校验OS中硬盘信息脚本
path=disktest/disk_info
mkdir -p $path
lsscsi >${path}/lsscsi.log
#获取硬盘smart信息
check_info() {
  declare -p $1 &>/dev/null
  if [ $? = 0 ]; then
    for name in $2; do
      smartctl -i /dev/${name} >${path}/${name}.log
      cat ${path}/${name}.log
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
if [ $1 = sata ]; then
  echo "请校验sata硬盘信息："
  check_info sata_info ${sata_info}
elif [ $1 = nvme ]; then
  echo "请校验nvme硬盘信息："
  check_info nvme_info ${nvme_info}
  echo "请校验nvme_pcie速率信息："
  check_pcie_info
else
  echo -e "\033[31m 请输入正确的磁盘类型，如sata/nvme.........................................................please check! \033[0m"
fi
