source ../.common

#export CONFIG_NTP_VERSION=4.2.8p17
#export NTP_OUTPUT_PATH=${OUTPUT_PATH}/${NTP}
#export NTP_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${NTP}

#export CONFIG_OPENSSL=1.0.2t
export OPENSSL_OUTPUT_PATH=`dirname ${NTP_OUTPUT_PATH}`/.static
export OPENSSL_OUTPUT_PATH_HOST=`dirname ${NTP_OUTPUT_PATH_HOST}`/.static
export CONFIG_OPENSSL_STATIC_BULID=y


## 配置NTP当前服务器IP
#export CONFIG_NTP_SERVER_IP="192.168.1.1"
## 配置NTP上一层服务器IP(可选)
#export CONFIG_NTP_OTHER_SERVER_IP="192.168.1.2"
## 配置NTP服务器drift文件路径
#export CONFIG_NTP_SERVER_DRIFTFILE"/var/ntp/drift"
## 配置NTP服务器PID文件路径
#export CONFIG_NTP_SERVER_PIDFILE="/var/run/ntpd.pid"
## 配置NTP服务器Log文件路径(建议搭建初期打开)
#export CONFIG_NTP_SERVER_LOGFILE="/var/log/ntp.log"

make_ntp
#make_ntp_host
