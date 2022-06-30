#!/bin/bash
#磁盘自动分区测试脚本
#获取路径
path=disktest/disk_parted
#建立挂载点
mkdir -p ${path}/1 ${path}/2 ${path}/3
#磁盘分区创建及挂载
sata_mkfs() {
  sleep 5
  mkfs.xfs -f /dev/${1}1
  sleep 1
  mkfs.xfs -f /dev/${1}2
  sleep 1
  mkfs.xfs -f /dev/${1}3
}
nvme_mkfs() {
  sleep 5
  mkfs.xfs -f /dev/${1}p1
  sleep 1
  mkfs.xfs -f /dev/${1}p2
  sleep 1
  mkfs.xfs -f /dev/${1}p3
}
sata_mount() {
  mount /dev/${1}1 ${path}/1
  mount /dev/${1}2 ${path}/2
  mount /dev/${1}3 ${path}/3
}
nvme_mount() {
  mount /dev/${1}p1 ${path}/1
  mount /dev/${1}p2 ${path}/2
  mount /dev/${1}p3 ${path}/3
}
disk_partition() {
  for disk in $1; do
    num=$(fdisk -l /dev/${disk} | grep "^/dev/${disk}" | wc -l)
    echo ${disk} >>${path}/disk_name
    if [ $num = 0 ]; then
      #建立分区表
      parted /dev/${disk} mktable gpt
      #创建主分区1
      parted /dev/${disk} mkpart primary xfs 2050 40000
      if [ $? = 0 ]; then
        #创建主分区2
        parted /dev/${disk} mkpart primary xfs 40001 100000
        if [ $? = 0 ]; then
          #创建主分区3
          parted /dev/${disk} mkpart primary xfs 100001 120000
          if [ $? = 0 ]; then
            $2 ${disk}
          else
            echo "创建分区3失败!"
          fi
        else
          echo "创建分区2失败!"
        fi
      else
        echo "创建分区1失败!"
      fi
      #挂载
      $3 ${disk}
      if [ $? = 0 ]; then
        echo "PASS" >${path}/result
        echo -e "\033[\e[1;32m Disk partition test passed!.........................................................please check the result! \033[0m"
        echo -e "\033[\e[1;32m Disk partition test passed!.........................................................please check the result! \033[0m" >>disktest/disk_result
      else
        echo -e "\033[31m disk partition test failed!.........................................................please check! \033[0m"
        echo -e "\033[31m disk partition test failed!.........................................................please check! \033[0m" >>disktest/disk_result
      fi
    else
      echo "该磁盘或已存在分区，无法进行分区操作！"
      break
    fi
  done
}
#执行磁盘分区操作
while (true); do
  read -p "需要对那种类型磁盘进行分区操作(sata/nvme)：" DISK
  if [ $DISK = sata ]; then
    disk_partition ${sata_info} ${sata_mkfs} ${sata_mount}
    break
  elif [ $DISK = nvme ]; then
    disk_partition ${nvme_info} ${nvme_mkfs} ${nvme_mount}
    break
  else
    echo -e "\033[31m 请输入正确的磁盘类型，如sata/nvme.........................................................please check! \033[0m"
  fi
done
