#!/bin/bash

# HiveServer2 connection details
HIVE_SERVER="your_hive_server_url"
PORT="10000" # default HiveServer2 port, change if yours is different
DATABASE_NAME="your_database_name"
USERNAME="your_username"
PASSWORD="your_password"

# JDBC connection string
JDBC_URL="jdbc:hive2://$HIVE_SERVER:$PORT/$DATABASE_NAME"

# Define the output file
OUTPUT_FILE="all_tables_ddl.hql"

# Ensure the output file is empty
> "$OUTPUT_FILE"

# Get list of tables in the database
TABLES=$(beeline -u "$JDBC_URL" -n "$USERNAME" -p "$PASSWORD" --silent=true -e "SHOW TABLES;")

# Loop through each table and append its DDL to the output file
echo "$TABLES" | while read TABLE; do
    if [[ $TABLE =~ ^(tab_name|+)* ]]; then
        continue # Skip header lines
    fi
    echo "Exporting DDL for table: $TABLE"
    echo "-- DDL for $TABLE" >> "$OUTPUT_FILE"
    beeline -u "$JDBC_URL" -n "$USERNAME" -p "$PASSWORD" --silent=true -e "SHOW CREATE TABLE $TABLE;" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE" # Add a newline for readability between table DDLs
done

echo "Export completed. DDLs are saved in $OUTPUT_FILE."
