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
export PGPASSWORD=$psql_password

# Fetch cpu_usage data and store it into variables
hostname=$(hostname -f)
vmstat=`vmstat -t --unit M | tail -1`
timestamp=$(date +"%F %T")
memory_free=$(echo "$vmstat" | awk '{print $4}')
cpu_idle=$(echo "$vmstat" | awk '{print $15}')
cpu_kernel=$(echo "$vmstat" | awk '{print $14}')
disk_io=$(vmstat -d | tail -1 | awk '{print $10}')
disk_available=$(df -BM /dev/sda2 | tail -1 | awk '{print $4}' | tr -d "M")

echo "Information to store is as below:"
echo "Free Memory: $memory_free"
echo "Idle CPU: $cpu_idle"
echo "CPU kernel: $cpu_kernel"
echo "Number of disk I/O: $disk_io"
echo "Root directory available disk: $disk_available"

# Insert data into table
insert_query="INSERT INTO host_usage (timestamp,host_id, memory_free,cpu_idle,cpu_kernel,disk_io,disk_available)
                        VALUES('${timestamp}',(select id from host_info WHERE host_info.hostname = '${hostname}'),'${memory_free}','${cpu_idle}','${cpu_kernel}','${disk_io}','${disk_available}');"
psql -h "$psql_hostname" -p "$psql_port" -U "$psql_username" -d "$psql_dbname" -c "$insert_query"
exit $?