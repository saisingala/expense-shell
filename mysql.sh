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

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing MYSQL server"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "Enabled mysql server"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "Started mysql server"

mysql -h mysql.khaleja.fun -u root pExpenseApp@1 -e 'show databases;' &>> $LOG_FILE

if [ $? -ne 0 ]
then
    echo "Mysql root password is not setup.. setting uo now.." &>> $LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Root password is setup done"
else
    echo "Mysql root password is already setup..skipping" |tee -a $LOG_FILE
fi

