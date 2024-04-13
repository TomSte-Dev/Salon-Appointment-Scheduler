#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

SERVICES_MENU() {
  #Displays any prompts provided
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #Display services
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo -e "Services:"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  #Ask the user to pick a service
  echo -e "\nPlease select a service"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  #if not a service id
  if [[ -z $SERVICE_NAME ]]
  then
    #return to service menu
    SERVICES_MENU "Please enter a valid option e.g '1'"
  else
    #get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE' ;")
        
    #if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      #get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      #insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
    fi

    #ask for a service time
    echo -e "\nWhat time would you like to schedule this service?"
    read SERVICE_TIME

    #Get Customer ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

    #Insert into appointments
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    
    #Display a message to inform the user of the input of their appointment
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
  fi
}

SERVICES_MENU