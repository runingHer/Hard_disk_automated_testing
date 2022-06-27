#!/bin/bash
#解压工具包
decompress() {
  if [ ! -d iozone3_430 ]; then
    tar -xvf iozone3_430.tar
  fi
}
#编译
compile() {
  cd iozone3_430/src/current
  make linux
}
#iozone测试
iozone_test() {
  for ((i = 1; i <= 3; i++)); do
    for size in {16g,8g,4g}; do
      ./iozone -a -i 0 -i 1 -i 2 -r 16m -s ${size} >>${size}_Iozone.log
      sleep 5
    done
  done
}
#执行测试&输出测试结果
decompress
compile
echo "正在进行iozone测试"
iozone_test
if [ $? = 0 ]; then
  echo -e "\033[\e[1;32m performance test completed！.........................................................PASS! \033[0m"
  echo -e "\033[\e[1;32m performance test completed！.........................................................PASS! \033[0m" >> disktest/disk_result
else
  echo -e "\033[31m performance test fail！.........................................................please check! \033[0m"
  echo -e "\033[31m performance test fail！.........................................................please check! \033[0m" >> disktest/disk_result
fi
