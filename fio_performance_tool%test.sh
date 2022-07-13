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
#fio性能测试
fio_test() {
  mkfs.xfs -f /dev/$1
  if [ $? = 0 ]; then
    bash FIO安装包及脚本/fio性能测试/fio_steady.sh /dev/$1
  else
    echo "FAIL" >${path}/result
    echo -e "\033[31m ${1} performance test failed.........................................................please check! \033[0m"
    echo -e "\033[31m ${1} performance test failed.........................................................please check! \033[0m" >>disktest/disk_result
  fi
}
decompress
#执行测试&输出测试结果
if [ $1 = sata ]; then
  path_make
  for traverse in ${sata_info}; do
    fio_test ${traverse}
  done
  if [ $? = 0 ]; then
    cp /sf/log/vs/vst_perf/* ${path}
    echo "PASS" >${path}/result
    echo -e "\033[\e[1;32m performance test completed.........................................................PASS! \033[0m"
    echo -e "\033[\e[1;32m performance test completed.........................................................PASS! \033[0m" >>disktest/disk_result
  fi
elif [ $1 = nvme ]; then
  path_make
  for traverse in ${nvme_info}; do
    fio_test ${traverse}
  done
  if [ $? = 0 ]; then
    cp /sf/log/vs/vst_perf/* ${path}
    echo "PASS" >${path}/result
    echo -e "\033[\e[1;32m performance test completed.........................................................PASS! \033[0m"
    echo -e "\033[\e[1;32m performance test completed.........................................................PASS! \033[0m" >>disktest/disk_result
  fi
fi
