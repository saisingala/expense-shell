#!bin/bash
LOGS_FOLDER=/var/log/expense
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
TIMESTAMP=$(date +%d-%m-%Y-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ];
      then
      echo -e " $R Please run the script with root privilages $N" &>> $LOG_FILE
      exit 1
    fi
}

VALIDATE (){
   
    if [ $1 -ne 0 ]; then
        echo -e " $2 is ... $R Failed $N" | tee -a  $LOG_FILE
        exit 1
    else 
        echo -e "$2 is .... $G Success $N" | tee -a  $LOG_FILE
    fi        
}


echo "Script started executing: $(date)" | tee -a  $LOG_FILE
CHECK_ROOT

dnf install mysql-server -y
VALIDATE $? "Installing MYSQL server"| tee -a  $LOG_FILE

systemctl enable mysqld
VALIDATE $? "Enabled mysql server"| tee -a  $LOG_FILE

systemctl start mysqld
VALIDATE $? "Started mysql server"| tee -a  $LOG_FILE

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting up mysql password"| tee -a  $LOG_FILE
