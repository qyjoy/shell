#!/bin/bash modified from lala 2024 March 9th by Joy
#24H AUTO LIVE STREAM 
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 顏色選擇
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
font="\033[0m"

ffmpeg_install(){
# 安裝FFMPEG
read -p "你的機器內是否已經安裝過FFmpeg4.x?安裝FFmpeg才能正常推流,是否現在安裝FFmpeg?(yes/no):" Choose
if [ $Choose = "yes" ];then
	yum -y install wget
	wget --no-check-certificate https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.0.3-64bit-static.tar.xz
	tar -xJf ffmpeg-4.0.3-64bit-static.tar.xz
	cd ffmpeg-4.0.3-64bit-static
	mv ffmpeg /usr/bin && mv ffprobe /usr/bin && mv qt-faststart /usr/bin && mv ffmpeg-10bit /usr/bin
fi
if [ $Choose = "no" ]
then
    echo -e "${yellow} 你選擇不安裝FFmpeg,請確定你的機器內已經自行安裝過FFmpeg,否則程式無法正常運作! ${font}"
    sleep 2
fi
	}

stream_start(){
# 定義推流位址和推流碼
read -p "輸入你的推流位址和推流碼(rtmp協定):" rtmp

# 判斷使用者輸入的位址是否合法
if [[ $rtmp =~ "rtmp://" ]];then
	echo -e "${green} 推流地址輸入正確,程序將進行下一步操作. ${font}"
  	sleep 2
	else  
  	echo -e "${red} 你輸入的地址不合法,請重新運行程式並輸入! ${font}"
  	exit 1
fi 

# 定義影片存放目錄
read -p "輸入你的視訊存放目錄 (格式只支持mp4,並且要絕對路徑,例如/opt/video):" folder

# 判斷是否需要加入浮水印
read -p "是否需要為影片添加浮水印?水印位置預設在右上方,需要較好CPU支持(yes/no):" watermark
if [ $watermark = "yes" ];then
	read -p "輸入你的水印圖片存放絕對路徑,例如/opt/image/watermark.jpg (格式支援jpg/png/bmp):" image
	echo -e "${yellow} 添加水印完成,程序將開始推流. ${font}"
	# 循環
	while true
	do
		cd $folder
		for video in $(ls *.mp4)
		do
		ffmpeg -re -i "$video" -i "$image" -filter_complex overlay=W-w-5:5 -c:v libx264 -maxrate 2000k -bufsize 2000k -c:a aac -b:a 192k -strict -2 -f flv ${rtmp}
		done
	done
fi
if [ $watermark = "no" ]
then
    echo -e "${yellow} 你選擇不添加浮水印,程序將開始推流. ${font}"
    # 循環
	while true
	do
		cd $folder
		for video in $(ls *.mp4)
		do
		ffmpeg -re -i "$video" -c:v copy -c:a aac -strict -2 -maxrate 1500k -f flv ${rtmp}
		done
	done
fi
	}

# 停止推流
stream_stop(){
	screen -S stream -X quit
	killall ffmpeg
	}

# 開始選單設定
echo -e "${yellow} CentOS7 X86_64 FFmpeg無人值守循環推流 For LALA.IM ${font}"
echo -e "${red} 請確定此腳本目前是在screen視窗內執行的! ${font}"
echo -e "${green} 1.安裝FFmpeg (機器要安裝FFmpeg才能正常推流) ${font}"
echo -e "${green} 2.開始無人值守循環推流 ${font}"
echo -e "${green} 3.停止推流 ${font}"
start_menu(){
    read -p "请输入数字(1-3),选择你要进行的操作:" num
    case "$num" in
        1)
        ffmpeg_install
        ;;
        2)
        stream_start
        ;;
        3)
        stream_stop
        ;;
        *)
        echo -e "${red} 請輸入正確的數字 (1-3) ${font}"
        ;;
    esac
	}
# 運行開始選單
start_menu
