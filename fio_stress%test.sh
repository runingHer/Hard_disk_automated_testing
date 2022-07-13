#!/bin/bash
path=disktest/disk_stress
#FIO压力测试
fio_stress_test() {
    mkfs.xfs -f /dev/$1
    if [ $? = 0 ]; then
      for BS in {4k,256k}; do
        for RW in {read,write,randread,randwrite}; do
          fio --name=$1 --filename=/dev/$1 --direct=1 --ioengine=libaio --time_based=1 --group_reporting --rw=${RW} --bs=${BS} --iodepth=32 --size=100% --numjobs=4 --runtime=12h &
        done
      done
    else
      echo -e "\033[31m Stress test failed.........................................................please check! \033[0m"
      echo -e "\033[31m Stress test failed.........................................................please check! \033[0m" >>disktest/disk_result
    fi
}
#执行测试&输出测试结果
if [ $1 = sata ]; then
  for traverse in ${sata_info}; do
    fio_stress_test ${traverse}
  done
  if [ $? = 0 ]; then
    echo -e "\033[\e[1;32m Stress test begins.........................................................PASS! \033[0m"
    echo -e "\033[\e[1;32m Stress test begins.........................................................PASS! \033[0m" >>disktest/disk_result
  filename
elif [ $1 = nvme ]; then
  for traverse in ${nvme_info}; do
    fio_stress_test ${traverse}
  done
  if [ $? = 0 ]; then
    echo -e "\033[\e[1;32m Stress test begins.........................................................PASS! \033[0m"
    echo -e "\033[\e[1;32m Stress test begins.........................................................PASS! \033[0m" >>disktest/disk_result
  fi
fi
