#!/bin/bash
#删除分区测试脚本
path=disktest/disk_parted
result=$(cat ${path}/result)
disk_name_result=$(cat ${path}/disk_name)
if [ $result = PASS ]; then
  #卸载分区
  for disk_name in ${disk_name_result}; do
    for i in {1..3}; do
      umount /dev/${disk_name}${i} &>/dev/null || umount /dev/${disk_name}p${i} &>/dev/null
    done
    if [ $? = 0 ]; then
      echo "卸载分区成功"
      #删除分区
      for i in {1..3}; do
        parted -s /dev/${disk_name} rm ${i}
      if [ $? = 0 ]; then
        lsblk
        echo "删除分区成功"
        echo -e "\033[\e[1;32m Delete partition test passed!.........................................................please check the result! \033[0m"
        echo -e "\033[\e[1;32m Delete partition test passed!.........................................................please check the result! \033[0m" >>disktest/disk_result
      else
        echo "删除分区失败"
      fi
      done
    else
      echo "卸载分区失败,请检查"
    fi
  done
else
  echo -e "\033[31m Delete partition test failed!.........................................................please check! \033[0m"
  echo -e "\033[31m Delete partition test failed!.........................................................please check! \033[0m" >>disktest/disk_result
fi
