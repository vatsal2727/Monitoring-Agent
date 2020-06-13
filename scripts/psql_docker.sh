#!/bin/bash

# Store Values of passed arguments in variables
userAction=$1 #Start or Stop
db_username=$2 #Database Username in case of creating the database
db_password=$3 #Database password

#If user entered less than 1 or more than 3 argument than show error message
if [[ "$#" -lt 1 ]]||[[ "$#" -gt 3 ]]; then
    echo "Please Enter valid number of arguments."
    exit 1
fi

# If docker is not running then start the docker.
# shellcheck disable=SC2046
if [ $(systemctl status docker | wc -l) != 20 ]; then
   sudo systemctl start docker
fi

#If user selected create option
if [ "$userAction" == "create" ]; then

   #In create action, if exactly 3 arguments are not passed then show error
   if [ $# -ne 3 ]; then
        echo "Must Pass 3 arguments to create docker container using psql image."
        echo "You must enter Database Username and Database Password!"
        exit 1
   fi

   # If a docker container named jrvs-psql already exist
   if [ "$(docker container ls -a -f name=jrvs-psql | wc -l)" == "2" ]; then
    echo "A docker container named \"jrvs-psql\" already exist!"
    exit 0
   fi

   # otherwise create a new container
   docker run --name jrvs-psql -e POSTGRES_PASSWORD=$db_password -e POSTGRES_USER=$db_username -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres
   exit $?

# if user opted for start action
elif [ "$userAction" == "start" ]; then
  if [ "$(docker container ls -a -f name=jrvs-psql | wc -l)" != 2 ]; then
    echo "Container does not exist!"
    exit 1
  else
    PSQL_CONTAINTER_NAME=jrvs-psql
    docker container start $PSQL_CONTAINTER_NAME
    echo "Successfully started the container"
    exit $?
  fi

# if user opted for stop action
elif [ "$userAction" = "stop" ]; then
  PSQL_CONTAINTER_NAME=jrvs-psql
  docker container stop $PSQL_CONTAINTER_NAME
  echo "Successfully stopped the container"
  exit $?

# If none of the above three action selected by user
else
  echo "Please enter valid command."
  exit 1
# exit the if loop with success code
fi
exit 0
