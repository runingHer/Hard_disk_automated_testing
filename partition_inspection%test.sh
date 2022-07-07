#!/bin/bash
#磁盘自动分区测试脚本
#获取路径
path=disktest/disk_parted
#建立挂载点
mount_path() {
  for i in $(seq 1 3); do
    for name in $1; do
      mkdir -p ${path}/${name}/${i}
    done
  done
}
#磁盘分区创建及挂载
sata_mkfs() {
  for i in $(seq 1 ${after_num}); do
    mkfs.xfs -f /dev/${disk}${i}
    sleep 3
  done
}
nvme_mkfs() {
  for i in $(seq 1 ${after_num}); do
    mkfs.xfs -f /dev/${disk}p${i}
    sleep 3
  done
}
sata_mount() {
  for i in $(seq 1 ${after_num}); do
    mount /dev/${disk}${i} ${path}/${disk}/${i}
    if [ $? = 0 ]; then
      echo "分区${disk}${i}已挂载"
    else
      echo "分区${disk}${i}挂载失败!"
    fi
  done
}
nvme_mount() {
  for i in $(seq 1 ${after_num}); do
    mount /dev/${disk}p${i} ${path}/${disk}/${i}
    if [ $? = 0 ]; then
      echo "分区${disk}p${i}已挂载"
    else
      echo "分区${disk}p${i}挂载失败!"
    fi
  done
}
disk_partition() {
  for disk in ${sata_info}; do
    num=$(fdisk -l /dev/${disk} | grep "^/dev/${disk}" | wc -l)
    echo ${disk} >>${path}/disk_name
    if [ $num = 0 ]; then
      #建立分区表
      parted /dev/${disk} mktable gpt
      #创建主分区1
      parted /dev/${disk} mkpart primary xfs 2050 40000
      if [ $? = 0 ]; then
        echo "已创建主分区1"
        sleep 1
        #创建主分区2
        parted /dev/${disk} mkpart primary xfs 40001 100000
        if [ $? = 0 ]; then
          echo "已创建主分区2"
          sleep 1
          #创建主分区3
          parted /dev/${disk} mkpart primary xfs 100001 120000
          if [ $? = 0 ]; then
            echo "已创建主分区3"
            sleep 1
            #格式化
            after_num=$(fdisk -l /dev/${disk} | grep "^/dev/${disk}" | wc -l)
            sata_mkfs
            lsblk
            sleep 5
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
      sata_mount
      if [ $? = 0 ]; then
        lsblk
        echo "PASS" >${path}/result
        echo -e "\033[\e[1;32m Disk partition test passed.........................................................please check the result! \033[0m"
        echo -e "\033[\e[1;32m Disk partition test passed.........................................................please check the result! \033[0m" >>disktest/disk_result
      else
        echo -e "\033[31m disk partition test failed.........................................................please check! \033[0m"
        echo -e "\033[31m disk partition test failed.........................................................please check! \033[0m" >>disktest/disk_result
      fi
    else
      echo "该磁盘或已存在分区，无法进行分区操作！"
    fi
  done
}
#执行磁盘分区操作
if [ $1 = sata ]; then
  mount_path ${sata_info}
  disk_partition
elif [ $1 = nvme ]; then
  mount_path ${nvme_info}
  disk_partition
else
  echo -e "\033[31m 请输入正确的磁盘类型，如sata/nvme.........................................................please check! \033[0m"
fi
