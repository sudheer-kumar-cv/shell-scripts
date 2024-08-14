: '
In Dynamo DB, when you create a table thru console, default provisioning is 1 by default.
This will cause you to incurr the cost accumulation if you have a lot of tables.
It is best to keep the cost in control by putting the capacity to OnDemand.
The below script does that for all the tables.

Prereq:
Makesure your AWS profile point to the right reqion before running this.
> aws s3 ls  # you can see the s3 tables listed to verify

Usage:
>chmod +x setAllDDBTablesToOnDemand
> ./ setAllDDBTablesToOnDemand

'

#!/bin/bash

# Specify the AWS region
REGION="eu-west-1"

# List all DynamoDB tables in the specified region
TABLES=$(aws dynamodb list-tables --region $REGION --query "TableNames[]" --output text)

# Loop through all tables
for TABLE in $TABLES; do
    echo "Checking billing mode for table $TABLE..."

    # Get the current billing mode of the table
    BILLING_MODE=$(aws dynamodb describe-table --table-name $TABLE --region $REGION --query "Table.BillingModeSummary.BillingMode" --output text)

    # Check if the billing mode is already ON_DEMAND
    if [ "$BILLING_MODE" == "PAY_PER_REQUEST" ]; then
        echo "Table $TABLE is already on On-Demand capacity mode."
    else
        # If not, update the table to On-Demand capacity mode
        echo "Updating table $TABLE to On-Demand capacity mode..."
        aws dynamodb update-table \
            --table-name $TABLE \
            --billing-mode PAY_PER_REQUEST \
            --region $REGION
        if [ $? -eq 0 ]; then
            echo "Table $TABLE updated successfully."
        else
            echo "Failed to update table $TABLE."
        fi
    fi
done

echo "All tables processed."
