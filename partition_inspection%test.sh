#!/bin/bash
#磁盘自动分区测试脚本
#获取路径
path=disktest/disk_parted
#建立挂载点
mount_path() {
  for i in $(seq 1 3); do
    mkdir -p ${path}/${1}/${i}
  done
}
#磁盘分区创建及挂载
sata_mkfs() {
  for i in $(seq 1 ${2}); do
    mkfs.xfs -f /dev/${1}${i}
    sleep 3
  done
}
nvme_mkfs() {
  for i in $(seq 1 ${2}); do
    mkfs.xfs -f /dev/${1}p${i}
    sleep 3
  done
}
sata_mount() {
  for i in $(seq 1 ${2}); do
    mount /dev/${1}${i} ${path}/${1}/${i}
  done
}
nvme_mount() {
  for i in $(seq 1 ${2}); do
    mount /dev/${1}p${i} ${path}/${1}/${i}
  done
}
disk_partition() {
  disk=$1
  num=$(fdisk -l /dev/${disk} | grep "^/dev/${disk}" | wc -l)
  echo ${disk} >>${path}/disk_name
  if [ $num = 0 ]; then
    #建立分区表
    parted -s /dev/${disk} mktable gpt
    echo "已建立分区表"
    #创建主分区1
    parted -s /dev/${disk} mkpart primary xfs 2050 40000
    if [ $? = 0 ]; then
      echo "已创建主分区1"
      #创建主分区2
      parted -s /dev/${disk} mkpart primary xfs 40001 100000
      if [ $? = 0 ]; then
        echo "已创建主分区2"
        #创建主分区3
        parted -s /dev/${disk} mkpart primary xfs 100001 120000
        if [ $? = 0 ]; then
          echo "已创建主分区3"
          #格式化
          after_num=$(fdisk -l /dev/${disk} | grep "^/dev/${disk}" | wc -l)
          ${2} ${disk} ${after_num}
          if [ $? = 0 ]; then
            lsblk
            echo "已完成分区格式化"
          fi
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
    ${3} ${disk} ${after_num}
    if [ $? = 0 ]; then
      lsblk
      echo "已完成分区挂载"
    fi
  else
    echo "该磁盘或已存在分区，无法进行分区操作！"
  fi
}
#执行磁盘分区操作
if [ $1 = sata ]; then
  for traverse in ${sata_info}; do
    mount_path ${traverse}
    disk_partition ${traverse} sata_mkfs sata_mount
  done
  if [ $? = 0 ]; then
    echo "PASS" >${path}/result
    echo -e "\033[\e[1;32m Disk partition test passed!.........................................................please check the result! \033[0m"
    echo -e "\033[\e[1;32m Disk partition test passed!.........................................................please check the result! \033[0m" >>disktest/disk_result
  else
    echo -e "\033[31m disk partition test failed!.........................................................please check! \033[0m"
    echo -e "\033[31m disk partition test failed!.........................................................please check! \033[0m" >>disktest/disk_result
  fi
elif [ $1 = nvme ]; then
  for traverse in ${nvme_info}; do
    mount_path ${traverse}
    disk_partition ${traverse} nvme_mkfs nvme_mount
  done
  if [ $? = 0 ]; then
    echo "PASS" >${path}/result
    echo -e "\033[\e[1;32m Disk partition test passed!.........................................................please check the result! \033[0m"
    echo -e "\033[\e[1;32m Disk partition test passed!.........................................................please check the result! \033[0m" >>disktest/disk_result
  else
    echo -e "\033[31m disk partition test failed!.........................................................please check! \033[0m"
    echo -e "\033[31m disk partition test failed!.........................................................please check! \033[0m" >>disktest/disk_result
  fi
else
  echo -e "\033[31m 请输入正确的磁盘类型，如sata/nvme.........................................................please check! \033[0m"
fi
