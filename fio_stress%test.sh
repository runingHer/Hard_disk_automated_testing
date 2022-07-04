#!/bin/bash
#FIO压力测试
path=disktest/disk_stress
#SATA盘压测
sata_test() {
  for HDD in ${sata_info}; do
    mkfs.xfs -f /dev/${HDD}
    if [ $? = 0 ]; then
      for BS in {4k,256k}; do
        for RW in {read,write,randread,randwrite}; do
          fio --name=${HDD} --filename=/dev/${HDD} --direct=1 --ioengine=libaio --time_based=1 --group_reporting --rw=${RW} --bs=${BS} --iodepth=32 --size=100% --numjobs=4 --runtime=${TIME} &
        done
      done
    else
      echo -e "\033[31m Stress test failed！.........................................................please check! \033[0m"
      echo -e "\033[31m Stress test failed！.........................................................please check! \033[0m" >> disktest/disk_result.log
    fi
  done
}
#NVME盘压测
nvme_test() {
  for NVME in ${nvme_info}; do
    mkfs.xfs -f /dev/${NVME}
    if [ $? = 0 ]; then
      for BS in {4k,256k}; do
        for RW in {read,write,randread,randwrite}; do
          fio --name=1 --filename=/dev/${NVME} --direct=1 --ioengine=libaio --time_based=1 --group_reporting --rw=$RW --bs=$BS --iodepth=32 --size=100% --numjobs=1 --runtime=${TIME} &
        done
      done
    else
      echo -e "\033[31m Stress test failed！.........................................................please check! \033[0m"
      echo -e "\033[31m Stress test failed！.........................................................please check! \033[0m" >> disktest/disk_result.log
    fi
  done
}
#执行测试&输出测试结果
while (true); do
  #交互
  read -p "请输入硬盘类型(例:sata/nvme)：" Disk
  read -p "请输入测试时间(例:12h)：" TIME
  if [ ${Disk} = sata ]; then
    sata_test
    if [ $? = 0 ]; then
      echo -e "\033[\e[1;32m performance test completed！.........................................................PASS! \033[0m"
      echo -e "\033[\e[1;32m performance test completed！.........................................................PASS! \033[0m" >> disktest/disk_result.log
    fi
    break
  elif [ ${Disk} = nvme ]; then
    nvme_test
    if [ $? = 0 ]; then
      echo -e "\033[\e[1;32m performance test completed！.........................................................PASS! \033[0m"
      echo -e "\033[\e[1;32m performance test completed！.........................................................PASS! \033[0m" >> disktest/disk_result.log
    fi
    break
  else
    echo "请输入正确的硬盘类型"
  fi
done
