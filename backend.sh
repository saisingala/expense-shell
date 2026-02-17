#!bin/bash

LOGS_FOLDER=/var/log/expense
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
TIMESTAMP=$(date +%d-%m-%Y-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NMAE-$TIMESTAMP.log"
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
      echo -e "$R Expense user is not created, $G now creating it $N" | tee -a $LOG_FILE
      useradd expense &>> LOG_FILE
      VALIDATE $? "Creating expense user"
    else 
       echo -e "$Y Expense user already present $N" | tee -a $LOG_FILE
    fi     


mkdir -p /app
VALIDATE $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> LOG_FILE
VALIDATE $? "Download application code into app directory"

cd /app &>> LOG_FILE
VALIDATE $? "Chang to /app Directory"

rm -rf /app/*
unzip /tmp/backend.zip &>> LOG_FILE
VALIDATE $? "Unzip the downloaded code"

# npm install &>> LOG_FILE
# VALIDATE $? "Install npm"

# systemctl daemon-reload &>> LOG_FILE
# VALIDATE $? "Load the service"

# systemctl start backend &>> LOG_FILE
# VALIDATE $? "Start the service"

# systemctl enable backend &>> LOG_FILE
# VALIDATE $? "Enable the service"

# dnf install mysql -y &>> LOG_FILE
# VAILDATE $? "Install mysql"

# mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> LOG_FILE
# VALIDATE $? "Connect to Database"

# systemctl restart backend &>> LOG_FILE
# VALIDATE $? "Restart the service"
