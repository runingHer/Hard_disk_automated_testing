#!/bin/bash
#提取fio日志脚本
path=disktest/disk_performance
result=$(cat ${path}/result)
mkdir -p ${path}/get_result
#提取seq日志
extract_log() {
  for i in $1; do
    for BS in {4,512}; do
      for RW in {randread,randwrite,read,write}; do
        if [ -f ${path}/fio_${BS}K_${RW}_${i}.log ]; then
          IOPS=$(cat ${path}/fio_${BS}K_${RW}_${i}.log | grep IOPS | awk -F ',' '{print $1}' | awk -F ':' '{print $NF}')
          BW=$(cat ${path}/fio_${BS}K_${RW}_${i}.log | grep BW | awk -F ',' '{print $2}' | awk '{print $1}')
          AVG=$(cat ${path}/fio_${BS}K_${RW}_${i}.log | grep "\<lat\>" | grep avg | awk -F ',' '{print $(NF-1)}')

          echo -e "${BS}K_${RW}_${i}\t \c" >>${path}/get_result/test_log.xlsx
          echo -e "${IOPS}\t \c" >>${path}/get_result/test_log.xlsx
          echo -e "${BW}\t \c" >>${path}/get_result/test_log.xlsx
          echo -e "${AVG}" >>${path}/get_result/test_log.xlsx
        fi
      done
    done
    DISK_SN=$(smartctl -i /dev/${i} | grep "Serial Number" | awk -F ' ' '{print $NF}')
    if [ -f ${path}/fio_${BS}K_${RW}_${i}.log ]; then
      echo ${DISK_SN} >>${path}/get_result/DISK_SN.xlsx
    fi
  done
}
#提取random日志
extract_rw_log() {
  for i in $1; do
    for BS in {4,512}; do
      if [ -f ${path}/fio_${BS}K_randrw_${i}.log ]; then
        IOPS_rw_read=$(cat ${path}/fio_${BS}K_randrw_${i}.log | grep IOPS | awk -F ',' '{print $1}' | awk -F ':' '{print $NF}' | sed -n '1p')
        IOPS_rw_write=$(cat ${path}/fio_${BS}K_randrw_${i}.log | grep IOPS | awk -F ',' '{print $1}' | awk -F ':' '{print $NF}' | sed -n '2p')
        BW_rw_read=$(cat ${path}/fio_${BS}K_randrw_${i}.log | grep BW | awk -F ',' '{print $2}' | awk '{print $1}' | sed -n '1p')
        BW_rw_write=$(cat ${path}/fio_${BS}K_randrw_${i}.log | grep BW | awk -F ',' '{print $2}' | awk '{print $1}' | sed -n '2p')
        AVG_rw_read=$(cat ${path}/fio_${BS}K_randrw_${i}.log | grep "\<lat\>" | grep avg | awk -F ',' '{print $(NF-1)}' | sed -n '1p')
        AVG_rw_write=$(cat ${path}/fio_${BS}K_randrw_${i}.log | grep "\<lat\>" | grep avg | awk -F ',' '{print $(NF-1)}' | sed -n '2p')

        echo -e "${BS}K_randrw_${i}_read\t \c" >>${path}/get_result/rw_test_log.xlsx
        echo -e "${IOPS_rw_read}\t \c" >>${path}/get_result/rw_test_log.xlsx
        echo -e "${BW_rw_read}\t \c" >>${path}/get_result/rw_test_log.xlsx
        echo -e "${AVG_rw_read}" >>${path}/get_result/rw_test_log.xlsx

        echo -e "${BS}K_randrw_${i}_write\t \c" >>${path}/get_result/rw_test_log.xlsx
        echo -e "${IOPS_rw_write}\t \c" >>${path}/get_result/rw_test_log.xlsx
        echo -e "${BW_rw_write}\t \c" >>${path}/get_result/rw_test_log.xlsx
        echo -e "${AVG_rw_write}" >>${path}/get_result/rw_test_log.xlsx
      fi
    done
  done
}
#执行测试&输出测试结果
while (true); do
  if [ ${result} = PASS ]; then
    read -p "请输入磁盘类型(nvme/sata)：" DISK
    if [ $DISK = nvme ]; then
      extract_log ${nvme_info} &>/dev/null
      extract_rw_log ${nvme_info} &>/dev/null
      if [ $? = 0 ]; then
        echo -e "\033[\e[1;32m get log success,.........................................................PASS! \033[0m"
        echo -e "\033[\e[1;32m get log success,.........................................................PASS! \033[0m" >>disktest/disk_result
        break
      else
        echo -e "\033[31m get log fail,.........................................................please check! \033[0m"
        echo -e "\033[31m get log fail,.........................................................please check! \033[0m" >>disktest/disk_result
        break
      fi
    elif [ $DISK = sata ]; then
      extract_log ${sata_info} &>/dev/null
      extract_rw_log ${sata_info} &>/dev/null
      if [ $? = 0 ]; then
        echo -e "\033[\e[1;32m get log success,.........................................................PASS! \033[0m"
        echo -e "\033[\e[1;32m get log success,.........................................................PASS! \033[0m" >>disktest/disk_result
        break
      else
        echo -e "\033[31m get log fail,.........................................................please check! \033[0m"
        echo -e "\033[31m get log fail,.........................................................please check! \033[0m" >>disktest/disk_result
        break
      fi
    else
      echo "请输入正确的磁盘类型！"
    fi
  else
    echo "校验失败，请检查result.log!"
  fi
done
