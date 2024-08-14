: '
THis script creates tag for each DDB table with name : TableName same as that of the name of the table.
This tag can be used to create costAllocationTags which can be used to track the cost incurred by this table.
By default, the CostExplorer propvides no way to categirize the cost and hence this is a better way.

Usage:
BashScripts> chmod +x tagAWSTablesForCostAllocationtags
BashScripts> ./tagAWSTablesForCostAllocationtags
'

#!/bin/bash

# Get the list of all DynamoDB tables
tables=$(aws dynamodb list-tables --query "TableNames[]" --output text)

# Loop through each table and tag it if the tag does not already exist
for table in $tables; do
    echo "Checking tags for table: $table"
    
    # Get the current tags for the table
    current_tags=$(aws dynamodb list-tags-of-resource --resource-arn arn:aws:dynamodb:$(aws configure get region):$(aws sts get-caller-identity --query Account --output text):table/$table --query "Tags[?Key=='TableName'].Value" --output text)
    
    # Check if the tag already exists
    if [ -z "$current_tags" ]; then
        echo "Tagging table: $table"
        aws dynamodb tag-resource --resource-arn arn:aws:dynamodb:$(aws configure get region):$(aws sts get-caller-identity --query Account --output text):table/$table --tags Key=TableName,Value=$table
    else
        echo "Table $table already has the tag: TableName=$current_tags"
    fi
    break
done

echo "Tagging process completed."
