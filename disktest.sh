#!/bin/bash
#硬盘测试开始
#环境变量配置
cat environment_variable >> ~/.bashrc
source ~/.bashrc
if [ $? = 0 ]; then
  #依赖包安装
  install_fio
  #校验OS中硬盘信息脚本
  bash check_info%test.sh
  if [ $? = 0 ]; then
    echo "10秒后进行硬盘分区校验测试："
    sleep 10
    bash partition_inspection%test.sh
    if [ $? = 0 ]; then
      echo "10秒后进行删除分区校验测试："
      sleep 10
      bash delete_partition%test.sh
      if [ $? = 0 ]; then
        echo "20秒后进行dd测试I/O稳定性："
        echo "请打开一个终端输入命令：iostat -m 1"
        sleep 20
        dd if=/dev/zero of=/dev/* bs=1M count=1000
        if [ $? = 0 ]; then
          echo "I/O稳定性测试已完成，准备进行fio性能测试："
          sleep 10
          bash fio_performance_tool%test.sh
          if [ $? = 0 ]; then
            echo "fio性能测试已完成，准备进行iozone性能测试："
            sleep 10
            bash iozone_performance%test.sh
            if [ $? = 0 ]; then
              echo "iozone测试已完成，准备进行fio压力测试："
              sleep 10
              bash fio_stress%test.sh
              if [ $? = 0 ]; then
                dmesg | grep "error" >>disktest/dmesg.log
                echo "fio压力测试已完成"
                sleep 10
                bash get_log%fio.sh
                if [ $? = 0 ]; then
                  echo -e "\033[\e[1;32m The hard disk test is completed!.........................................................please verify the result! \033[0m"
                  echo -e "\033[\e[1;32m The hard disk test is completed!.........................................................please verify the result! \033[0m" >>disktest/disk_result
                fi
              fi
            fi
          fi
        fi
      fi
    fi
  fi
else
  echo "环境变量配置错误，请检查!"
fi
