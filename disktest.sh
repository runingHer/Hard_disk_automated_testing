#!/bin/bash
#硬盘测试开始
#环境变量配置
while (true); do
    read -p "需要对那种类型磁盘进行测试(sata/nvme)：" DISK
    if [ ${DISK} = sata ]; then
      break
    elif [ ${DISK} = nvme ]; then
      break
    else
      echo "请输入正确的磁盘类型！"
    fi
done
cp environment_variable.sh /etc/profile.d/
source /etc/profile.d/environment_variable.sh
if [ $? = 0 ]; then
  #依赖包安装
  install_all

  #校验OS中硬盘信息脚本
  bash check_info%test.sh ${DISK}
  echo "10秒后进行硬盘分区校验测试："
  sleep 10

  #创建分区校验测试
  bash partition_inspection%test.sh ${DISK}
  echo 3 >/proc/sys/vm/drop_caches
  echo "10秒后进行删除分区校验测试："
  sleep 10

  #删除分区校验测试
  bash delete_partition%test.sh
  echo "20秒后进行dd测试I/O稳定性："
  echo "请打开一个终端输入命令：iostat -m 1"
  sleep 30

  #io稳定性测试
  dd if=/dev/zero of=/dev/* bs=1M count=1000
  echo 3 >/proc/sys/vm/drop_caches
  echo "I/O稳定性测试已完成，准备进行fio性能测试："
  sleep 10

  #fio性能测试
  bash fio_performance_tool%test.sh ${DISK}
  echo 3 >/proc/sys/vm/drop_caches
  echo "fio性能测试已完成，准备进行iozone性能测试："
  sleep 10

  #iozone性能测试
  bash iozone_performance%test.sh
  echo 3 >/proc/sys/vm/drop_caches
  echo "iozone测试已完成，准备进行fio压力测试："
  sleep 10

  #fio压力测试
  bash fio_stress%test.sh ${DISK}
  echo 3 >/proc/sys/vm/drop_caches
  echo "fio压力测试已完成"
  sleep 30

  #dmesg日志
  dmesg | grep "error" >>disktest/dmesg.log
  sleep 10

  #提取fio测试结果
  bash get_log%fio.sh ${DISK}

  #删除环境变量及安装包
  delete_all
  echo -e "\033[\e[1;32m The hard disk test is completed.........................................................please verify the result! \033[0m"
  echo -e "\033[\e[1;32m The hard disk test is completed.........................................................please verify the result! \033[0m" >>disktest/disk_result
else
  echo "环境变量配置错误，请检查!"
fi
