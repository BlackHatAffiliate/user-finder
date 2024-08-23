#!/bin/bash

# Define MySQL credentials
MYSQL_USER="your_mysql_username"
MYSQL_PASSWORD="your_mysql_password"
MYSQL_HOST="localhost" # Change if necessary

# Date filter for accounts registered after August 1st, 2024
DATE_FILTER="2024-08-01 00:00:00"

# List all databases, suppressing the password warning
databases=$(mysql --silent --skip-column-names --user=$MYSQL_USER --password=$MYSQL_PASSWORD --host=$MYSQL_HOST -e "SHOW DATABASES;" 2>/dev/null | grep -v information_schema | grep -v performance_schema)

# Initialize an associative array to store unique user_nicenames
declare -A unique_nicenames

# Loop through each database and check for the tables
for db in $databases; do
    for table in wp_users customstring_users; do
        # Check if the table exists in the database
        table_exists=$(mysql --silent --skip-column-names --user=$MYSQL_USER --password=$MYSQL_PASSWORD --host=$MYSQL_HOST -D $db -e "SHOW TABLES LIKE '$table';" 2>/dev/null)
        if [[ ! -z $table_exists ]]; then
            # Query the user_nicename and filter by user_registered date
            query="SELECT user_nicename FROM $table WHERE user_registered > '$DATE_FILTER';"
            nicenames=$(mysql --silent --skip-column-names --user=$MYSQL_USER --password=$MYSQL_PASSWORD --host=$MYSQL_HOST -D $db -e "$query" 2>/dev/null)
            if [[ ! -z $nicenames ]]; then
                for nicename in $nicenames; do
                    # If the nicename is not already in the array, output it and add to the array
                    if [[ -z "${unique_nicenames[$db,$nicename]}" ]]; then
                        unique_nicenames[$db,$nicename]=1
                        echo "$db, $nicename"
                    fi
                done
            fi
        fi
    done
done
