#!/bin/bash
# If user entered less than 5 arguments show the error.
if [ $# -ne 5 ]; then
  echo "Please enter valid number of arguments!"
  exit 1
fi

# Store Values of passed arguments in variables
psql_hostname=$1 #localhost
psql_port=$2 #5432
psql_dbname=$3 #host_agent
psql_username=$4 #Database Username in case of creating the database
psql_password=$5 #Database password

# Collect cpu host information and store it into variables
hostname=$(hostname -f)
lscpu_out=`lscpu`
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "Architecture:" | awk '{print $2}'| xargs)
cpu_model=$(echo "$lscpu_out"  | egrep "^Model name:" | awk '{print $3,$4,$5,$6,$7}' | xargs)
cpu_mhz=$(echo "$lscpu_out"  | egrep "CPU MHz:" | awk '{print $3}' | xargs)
L2_cache=$(echo "$lscpu_out"  | egrep "L2 cache" | awk '{print $3}'| tr -d 'K' | xargs)
total_mem=$(echo $(grep MemTotal /proc/meminfo) | awk '{print $2}'| tr -d "kB" | xargs)
timestamp=$(date +"%F %T")

# Just print information that is stored into tables
echo "Information to store is as below:"
echo "CPU Number: $cpu_number"
echo "CPU Architecture: $cpu_architecture"
echo "CPU Model: $cpu_model"
echo "CPU MHz: $cpu_mhz"
echo "L2 Cache: $L2_cache"
echo "Total Memory: $total_mem"
echo "Timestamp: $timestamp"

#sql query to insert data into table
insert_query="INSERT INTO host_info (hostname,cpu_number,cpu_architecture,cpu_model,cpu_mhz,L2_cache,total_mem,timestamp)
                          VALUES('${hostname}','${cpu_number}','${cpu_architecture}','${cpu_model}','${cpu_mhz}','${L2_cache}','${total_mem}','${timestamp}');"

psql -h "$psql_hostname" -p "$psql_port" -U "$psql_username" -d "$psql_dbname" -c "$insert_query"
exit $?