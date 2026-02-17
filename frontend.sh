#!bin/bash

LOGS_FOLDER=var/log/expense
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
TIMESTAMP=$(date +%d-%m-%Y-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

R="\e[31m"
G="\e[32m"
N="\e[0m"

USERID=$(id -u)

CHECK_ROOT(){
    if [ $USER_ID -ne 0 ]
    then
        echo "User not having root privilages"
        exit 1
     fi   
}

VALIDATE(){
     if [ $1 -ne 0 ]
     then 
         echo -e "$2 is $R FAILED $N" | tee -a $LOG_FILE
     else 
         echo -e "$2 is $G SUCCESS $N" | tee -a $LOG_FILE   
      fi   
}

CHECK_ROOT

dnf install nginx -y  &>> $LOG_FILE
VALIDATE $? "Install nginx"

systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "Enable nginx"

systemctl start nginx &>> $LOG_FILE
VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
VALIDATE $? "Removing dafault website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOG_FILE
VALIDATE $? "Download frontend Code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $LOG_FILE
VALIDATE $? "Extract frontend code"

systemctl restart nginx 
