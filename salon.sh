#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~"
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "


MAIN(){
#print message 
if [[ $1 ]]
then 
  echo -e "\n$1"
fi
#get list of services
echo -e "Here is a list of services we offer :\n"
AVAILABLE_SERVICES=$($PSQL "select service_id,name from services order by service_id")
echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
#select service
echo -e "\nWhich one do you prefer?\n"
read SERVICE_ID_SELECTED
SELECTION $SERVICE_ID_SELECTED
}

SELECTION(){
SERVICE_ID_SELECTED=$1
#if input not a number
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  #go to services 
  MAIN "\nSorry.We don't have that service."
else
  SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
  #if service doesn't exist
  if [[ -z $SERVICE_ID ]]
  then
    #go to services
    MAIN "\nSorry.We don't have that service."
  else
    #ask for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_PHONE_AVAILABILITY=$($PSQL "select phone from customers where phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_PHONE_AVAILABILITY ]]
      then
        #new customer
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_INFO=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      else
        #get customer name
        CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    fi
    echo -e "\nWhat is the appointment time?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "select customer_id from customers where name='$CUSTOMER_NAME'")
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values('$CUSTOMER_ID', $SERVICE_ID, '$SERVICE_TIME')")
    if [[ $INSERT_CUSTOMER_RESULT == 'INSERT 0 1' ]]
      then
        SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID")
        echo -e "\nI have put you down for a $(echo $SERVICE_NAME) at $(echo $SERVICE_TIME), $(echo $CUSTOMER_NAME)."
      else
        echo ERROR
    fi  
  fi
fi


}


MAIN

