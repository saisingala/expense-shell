#!bin/bash

LOGS_FOLDER=/var/log/expense
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
TIMESTAMP=$(date +%d-%m-%Y-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

USERID=$(id -u)

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
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

dnf module disable nodejs -y &>> LOG_FILE
VALIDATE $? "Disabling Node JS old version"

dnf module enable nodejs:20 -y &>> LOG_FILE
VALIDATE $? "Enable Node JS latest version"

dnf install nodejs -y &>> LOG_FILE
VALIDATE $? "Install Noda js"

id expense  &>> LOG_FILE
  if [ $? -ne 0 ]
  then
      echo -e "$R Expense user is not exists, $G now creating it $N" | tee -a $LOG_FILE
      useradd expense &>> LOG_FILE
      VALIDATE $? "Creating expense user"
    else 
       echo -e "$Y Expense user already exists..$G Skipping $N" | tee -a $LOG_FILE
    fi     


mkdir -p /app
VALIDATE $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> LOG_FILE
VALIDATE $? "Downloading backend application code"

cd /app &>> LOG_FILE

rm -rf /app/* #remove existing code
unzip /tmp/backend.zip &>> LOG_FILE
VALIDATE $? "Extracting backend application code"

npm install &>> LOG_FILE
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#load the data before running backend 

dnf install mysql -y &>> LOG_FILE
VALIDATE $? "Installing mysql client"

mysql -h mysql.khaleja.fun -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> LOG_FILE
VALIDATE $? "Connect to Database"

systemctl daemon-reload &>> LOG_FILE
VALIDATE $? "Load the service"

systemctl enable backend &>> LOG_FILE
VALIDATE $? "Enable the service"

systemctl restart backend &>> LOG_FILE
VALIDATE $? "Restart the service"
