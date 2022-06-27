#!/bin/bash
#删除分区测试脚本
path=disktest/disk_parted
result=$(cat ${path}/result)
disk_name=$(cat ${path}/disk_name)
if [ $result = PASS ]; then
  #卸载分区
  umount /dev/${disk_name}1 /dev/${disk_name}2 /dev/${disk_name}3
  if [ $? = 0 ]; then
    echo "卸载分区成功"
    #删除分区
    for i in {1..3}; do
      parted /dev/${disk_name} rm ${i}
    done
    if [ $? = 0 ]; then
      echo -e "\033[\e[1;32m Delete partition test passed!.........................................................please check the result! \033[0m"
      echo -e "\033[\e[1;32m Delete partition test passed!.........................................................please check the result! \033[0m" >> disktest/disk_result
    else
      echo -e "\033[31m Delete partition test failed!.........................................................please check! \033[0m"
      echo -e "\033[31m Delete partition test failed!.........................................................please check! \033[0m" >> disktest/disk_result
    fi
  else
    echo "卸载分区失败,请检查"
  fi
else
  echo "测试失败,请检查!"
fi
