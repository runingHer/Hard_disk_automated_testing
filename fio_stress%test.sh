path=disktest/disk_stress
#FIO压力测试
fio_stress_test() {
  for name in $1; do
    mkfs.xfs -f /dev/${name}
    if [ $? = 0 ]; then
      for BS in {4k,256k}; do
        for RW in {read,write,randread,randwrite}; do
          fio --name=${name} --filename=/dev/${name} --direct=1 --ioengine=libaio --time_based=1 --group_reporting --rw=${RW} --bs=${BS} --iodepth=32 --size=100% --numjobs=4 --runtime=12h &
        done
      done
    else
      echo -e "\033[31m Stress test failed.........................................................please check! \033[0m"
      echo -e "\033[31m Stress test failed.........................................................please check! \033[0m" >>disktest/disk_result.log
    fi
  done
}
#执行测试&输出测试结果
if [ $1 = sata ]; then
  fio_stress_test ${sata_info}
  if [ $? = 0 ]; then
    echo -e "\033[\e[1;32m Stress test begins.........................................................PASS! \033[0m"
    echo -e "\033[\e[1;32m Stress test begins.........................................................PASS! \033[0m" >>disktest/disk_result.log
  fi
elif [ $1 = nvme ]; then
  fio_stress_test ${nvme_info}
  if [ $? = 0 ]; then
    echo -e "\033[\e[1;32m Stress test begins.........................................................PASS! \033[0m"
    echo -e "\033[\e[1;32m Stress test begins.........................................................PASS! \033[0m" >>disktest/disk_result.log
  fi
else
  echo "请输入正确的硬盘类型"
fi
