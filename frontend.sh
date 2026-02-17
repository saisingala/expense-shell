#!bin/bash

LOGS_FOLDER=var/log/expense
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
TIMESTAMP=$(date +%d-%m-%Y-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

R="\e[31m"
G="\e[32m"
N="\e[0m"

USER_ID=$(id -u)

CHECK_ROOT(){
    if [ USER_ID -ne 0 ]
    then
        echo "User not having root privilages"
        exit 1
}

VALIDATE(){
     if [ $1 -ne 0 ]
     then 
         echo -e "$2 is $R FAILED $N" | tee -a $LOG_FILE
     else 
         echo -e "$2 is $G SUCCESS $N" | tee -a $LOG_FILE   
         
}

CHECK_ROOT

dnf install nginx -y 
VALIDATE $? "Install nginx"

systemctl enable nginx
VALIDATE $? "Enable nginx"

systemctl start nginx
VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Remove dafault content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Download frontend content"

cd /usr/share/nginx/html
VALIDATE $? "Extract frontend content"

unzip /tmp/frontend.zip
VALIDATE $? "Unzip the the content"

systemctl restart nginx
VALIDATE $? "Restart nginx"