#!/bin/bash
#FIO性能测试
path=disktest/disk_performance
mkdir -p ${path}
#解压fio工具包
decompress() {
  if [ ! -d FIO安装包及脚本 ]; then
    unzip -O GBK FIO安装包及脚本.zip
  fi
  cd FIO安装包及脚本/fio性能测试/
  if [ ! -d fio-3.20 ]; then
    tar -xvf fio-3.20.tar.bz2
  fi
}
#编译安装
path_make() {
  cd fio-3.20
  ./configure
  make
  make install
  cd ../../..
}
#SATA性能测试
sata_test() {
  for HDD in ${sata_info}; do
    mkfs.xfs -f /dev/${HDD}
    if [ $? = 0 ]; then
      bash FIO安装包及脚本/fio性能测试/fio_steady.sh /dev/${HDD}
    else
      echo "FAIL" > ${path}/result
      echo -e "\033[31m performance test failed！.........................................................please check! \033[0m"
      echo -e "\033[31m performance test failed！.........................................................please check! \033[0m" >> disktest/disk_result
    fi
  done
}
#NVME性能测试
nvme_test() {
  for NVME in ${nvme_info}; do
    mkfs.xfs -f /dev/${NVME}
    if [ $? = 0 ]; then
      bash FIO安装包及脚本/fio性能测试/fio_steady.sh /dev/${NVME}
    else
      echo "FAIL" > ${path}/result
      echo -e "\033[31m performance test failed！.........................................................please check! \033[0m"
      echo -e "\033[31m performance test failed！.........................................................please check! \033[0m" >> disktest/disk_result
    fi
  done
}
decompress
#执行测试&输出测试结果
while (true); do
  #交互
  read -p "请输入硬盘类型(例:nvme/sata)：" Disk
  if [ ${Disk} = sata ]; then
    path_make
    sata_test
    if [ $? = 0 ]; then
      cp /sf/log/vs/vst_perf/* ${path}
      echo "PASS" > ${path}/result
      echo -e "\033[\e[1;32m performance test completed！.........................................................PASS! \033[0m"
      echo -e "\033[\e[1;32m performance test completed！.........................................................PASS! \033[0m" >> disktest/disk_result
    fi
    break
  elif [ ${Disk} = nvme ]; then
    path_make
    nvme_test
    if [ $? = 0 ]; then
      echo "PASS" > ${path}/result
      echo -e "\033[\e[1;32m performance test completed！.........................................................PASS! \033[0m"
      echo -e "\033[\e[1;32m performance test completed！.........................................................PASS! \033[0m" >> disktest/disk_result
    fi
    break
  else
    echo "请输入正确的硬盘类型！"
  fi
done