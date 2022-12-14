#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ -z $1 ]]
  then
  echo -e "Welcome to My Salon, how can I help you?\n"
  else
  echo -e $MAIN_MENU $1
  fi
#get the services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")  
#custom the list of services
  echo "$SERVICES" | sed -e "s/[\|]/) /g"
  read SERVICE_ID_SELECTED
  SERVICE_REQUESTED=$($PSQL "SELECT name FROM services WHERE $SERVICE_ID_SELECTED = service_id")  
#if service doesn't exist
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]$ ]]
    then
    #send to main menu
    MAIN_MENU "\nI could not find that service. What would you like today?"
    else
    #get phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    PHONE_NUMBER=$($PSQL "SELECT phone FROM customers WHERE '$CUSTOMER_PHONE' = phone")
    #if phone number doesn't exist
    if [[ -z $PHONE_NUMBER ]]
     then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      #get customer name
      read CUSTOMER_NAME
      echo -e "\nWhat time would you like your $SERVICE_REQUESTED, $CUSTOMER_NAME?"
      #insert new customer
      INSERT_CUSTOMER_NAME_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
     else
      #if it does exist
      echo -e "\nWhat time would you like your $SERVICE_REQUESTED, $CUSTOMER_NAME?"
    fi
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME' AND '$CUSTOMER_PHONE' = phone")
      INSERT_APPOINTMENT_TABLE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_REQUESTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU