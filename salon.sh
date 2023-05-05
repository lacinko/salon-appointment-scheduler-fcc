#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\nWelcome to Ladi's hair salon.\nWhat would you like to have?\n"
  SERVICES_MENU
}
APPOINTMENT() {
  SERVICE_ID="$1"
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")

  echo -e "\nOK, can I get your number for the appointment?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nYou are new here, what is your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE') RETURNING customer_id")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo $CUSTOMER_ID
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\nWelcome back!"
  fi
  echo -e "\nWhat time you would like to $SERVICE_NAME your hair? $CUSTOMER_NAME.\nFormat: ##:## AM/PM"
  read SERVICE_TIME
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")
  echo $INSERT_APPOINTMENT_RESULT
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    MAIN_MENU "There was an error. We need to repeat the process."
  fi
}
CUT_SERVICE() {
  APPOINTMENT "1"
}
TRIM_SERVICE(){
  APPOINTMENT "2"
}
STYLE_SERVICE(){
  APPOINTMENT "3"
}
COLOR_SERVICE(){
  APPOINTMENT "4"
}
EXIT(){
  echo -e "\nThank you for stopping in.\n"
}
SERVICES_MENU() {
  SERVICES=$($PSQL "SELECT service_id, name, price FROM services")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE PRICE
  do
    DOLLARS=$(($PRICE/100))
    CENTS=$(printf "%02d" $(($PRICE%100)))
    FORMATTED_PRICE=$(echo "$DOLLARS.$CENTS" | awk '{printf("$%.2f", $1)}')
    echo -e "$SERVICE_ID) $SERVICE"
  done
  SERVICES_COUNT=$($PSQL "SELECT COUNT(service_id) FROM services")
  EXIT_NUMBER=$(($SERVICES_COUNT + 1 ))
  #echo "$EXIT_NUMBER) Exit"
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    1) CUT_SERVICE ;;
    2) TRIM_SERVICE ;;
    3) STYLE_SERVICE ;;
    4) COLOR_SERVICE ;;
    #5) EXIT ;;
    *) SERVICES_MENU "Please enter a valid option." ;;
  esac
}
MAIN_MENU
