#!/bin/bash

# Prompt for region
read -p "Enter your desired region (e.g., us-west1): " REGION

# Set variables
INSTANCE_ID="banking-instance"
DB_ID="banking-db"
TABLE_NAME="Customer"
PROJECT_ID=$(gcloud config get-value project)

echo "Using project: $PROJECT_ID and region: $REGION"

# Step 1: Create Spanner Instance
gcloud spanner instances create $INSTANCE_ID \
--config=regional-$REGION \
--description="Banking Instance" \
--nodes=1

# Step 2: Create Database
gcloud spanner databases create $DB_ID --instance=$INSTANCE_ID

# Step 3: Create Customer Table
gcloud spanner databases ddl update $DB_ID --instance=$INSTANCE_ID --ddl="
CREATE TABLE $TABLE_NAME (
CustomerId STRING(36) NOT NULL,
Name STRING(MAX) NOT NULL,
Location STRING(MAX) NOT NULL
) PRIMARY KEY (CustomerId);
"

# Step 4: Insert Data
gcloud spanner databases execute-sql $DB_ID --instance=$INSTANCE_ID --sql="
INSERT INTO $TABLE_NAME (CustomerId, Name, Location)
VALUES ('bdaaaa97-1b4b-4e58-b4ad-84030de92235', 'Richard Nelson', 'Ada Ohio');
"

gcloud spanner databases execute-sql $DB_ID --instance=$INSTANCE_ID --sql="
INSERT INTO $TABLE_NAME (CustomerId, Name, Location)
VALUES ('b2b4002d-7813-4551-b83b-366ef95f9273', 'Shana Underwood', 'Ely Iowa');
"

# Step 5: Query the data
echo "Running SELECT query:"
gcloud spanner databases execute-sql $DB_ID --instance=$INSTANCE_ID --sql="SELECT * FROM $TABLE_NAME;"

# Step 6: List instances
gcloud spanner instances list

# Step 7: Done
echo "✅ Spanner setup complete!"
