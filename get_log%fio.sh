#!/bin/bash
#提取fio日志脚本
path=disktest/disk_performance
mkdir -p ${path}/get_result
#提取seq日志
extract_log() {
  for BS in {4,512}; do
    for RW in {randread,randwrite,read,write}; do
      if [ -f ${path}/fio_${BS}K_${RW}_${1}.log ]; then
        IOPS=$(cat ${path}/fio_${BS}K_${RW}_${1}.log | grep IOPS | awk -F ',' '{print $1}' | awk -F ':' '{print $NF}')
        BW=$(cat ${path}/fio_${BS}K_${RW}_${1}.log | grep BW | awk -F ',' '{print $2}' | awk '{print $1}')
        AVG=$(cat ${path}/fio_${BS}K_${RW}_${1}.log | grep "\<lat\>" | grep avg | awk -F ',' '{print $(NF-1)}')

        echo -e "${BS}K_${RW}_${1}\t \c" >>${path}/get_result/test_log.xlsx
        echo -e "${IOPS}\t \c" >>${path}/get_result/test_log.xlsx
        echo -e "${BW}\t \c" >>${path}/get_result/test_log.xlsx
        echo -e "${AVG}" >>${path}/get_result/test_log.xlsx
      fi
    done
  done
  DISK_SN=$(smartctl -i /dev/${1} | grep "Serial Number" | awk -F ' ' '{print $NF}')
  if [ -f ${path}/fio_${BS}K_${RW}_${1}.log ]; then
    echo ${DISK_SN} >>${path}/get_result/DISK_SN.xlsx
  fi
}
#提取random日志
extract_rw_log() {
  for BS in {4,512}; do
    if [ -f ${path}/fio_${BS}K_randrw_${1}.log ]; then
      IOPS_rw_read=$(cat ${path}/fio_${BS}K_randrw_${1}.log | grep IOPS | awk -F ',' '{print $1}' | awk -F ':' '{print $NF}' | sed -n '1p')
      IOPS_rw_write=$(cat ${path}/fio_${BS}K_randrw_${1}.log | grep IOPS | awk -F ',' '{print $1}' | awk -F ':' '{print $NF}' | sed -n '2p')
      BW_rw_read=$(cat ${path}/fio_${BS}K_randrw_${1}.log | grep BW | awk -F ',' '{print $2}' | awk '{print $1}' | sed -n '1p')
      BW_rw_write=$(cat ${path}/fio_${BS}K_randrw_${1}.log | grep BW | awk -F ',' '{print $2}' | awk '{print $1}' | sed -n '2p')
      AVG_rw_read=$(cat ${path}/fio_${BS}K_randrw_${1}.log | grep "\<lat\>" | grep avg | awk -F ',' '{print $(NF-1)}' | sed -n '1p')
      AVG_rw_write=$(cat ${path}/fio_${BS}K_randrw_${1}.log | grep "\<lat\>" | grep avg | awk -F ',' '{print $(NF-1)}' | sed -n '2p')

      echo -e "${BS}K_randrw_${1}_read\t \c" >>${path}/get_result/rw_test_log.xlsx
      echo -e "${IOPS_rw_read}\t \c" >>${path}/get_result/rw_test_log.xlsx
      echo -e "${BW_rw_read}\t \c" >>${path}/get_result/rw_test_log.xlsx
      echo -e "${AVG_rw_read}" >>${path}/get_result/rw_test_log.xlsx

      echo -e "${BS}K_randrw_${1}_write\t \c" >>${path}/get_result/rw_test_log.xlsx
      echo -e "${IOPS_rw_write}\t \c" >>${path}/get_result/rw_test_log.xlsx
      echo -e "${BW_rw_write}\t \c" >>${path}/get_result/rw_test_log.xlsx
      echo -e "${AVG_rw_write}" >>${path}/get_result/rw_test_log.xlsx
    fi
  done
}
#执行测试&输出测试结果
if [ $1 = nvme ]; then
  for traverse in ${nvme_info}; do
    extract_log ${traverse}
    extract_rw_log ${traverse}
  done
  if [ $? = 0 ]; then
    echo -e "\033[\e[1;32m get log success,.........................................................PASS! \033[0m"
    echo -e "\033[\e[1;32m get log success,.........................................................PASS! \033[0m" >>disktest/disk_result
  else
    echo -e "\033[31m get log fail,.........................................................please check! \033[0m"
    echo -e "\033[31m get log fail,.........................................................please check! \033[0m" >>disktest/disk_result
  fi
elif [ $1 = sata ]; then
  for traverse in ${sata_info}; do
  extract_log ${traverse}
  extract_rw_log ${traverse}
  done
  if [ $? = 0 ]; then
    echo -e "\033[\e[1;32m get log success,.........................................................PASS! \033[0m"
    echo -e "\033[\e[1;32m get log success,.........................................................PASS! \033[0m" >>disktest/disk_result
  else
    echo -e "\033[31m get log fail,.........................................................please check! \033[0m"
    echo -e "\033[31m get log fail,.........................................................please check! \033[0m" >>disktest/disk_result
  fi
fi
