#!/bin/bash

# Namespace
NAMESPACE="fullstack-app"

# Wait for the MySQL deployment to be ready
echo "Waiting for MySQL deployment to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/mysql -n $NAMESPACE

# Get the MySQL pod name dynamically
MYSQL_POD=$(kubectl get pod -n $NAMESPACE -l app=mysql -o jsonpath="{.items[0].metadata.name}")

if [[ -z "$MYSQL_POD" ]]; then
    echo "MySQL pod not found. Exiting."
    exit 1
fi

echo "MySQL pod found: $MYSQL_POD"

# Execute the SQL command inside the MySQL pod
kubectl exec -it $MYSQL_POD -n $NAMESPACE -- bash -c "
  echo 'Waiting for MySQL service to be ready...';

  # Loop until MySQL is ready
  until mysqladmin ping -h127.0.0.1 -u root -ppassword --silent; do
    echo 'MySQL is not ready yet. Waiting...';
    sleep 5
  done

  echo 'MySQL is ready. Creating todos table...';

  mysql -u root -ppassword -D fullstack-app-db -e \"
    CREATE TABLE IF NOT EXISTS todos (
      id INT AUTO_INCREMENT PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      description TEXT
    );
  \"

  echo 'Table creation complete. Showing table schema:';
  mysql -u root -ppassword -D fullstack-app-db -e \"SHOW CREATE TABLE todos;\"

  echo 'Inserting demo data...';
  mysql -u root -ppassword -D fullstack-app-db -e \"
    INSERT INTO todos (title, description) VALUES
    ('Buy groceries', 'Milk, Bread, Eggs, Fruits'),
    ('Complete project', 'Finish the report and submit'),
    ('Workout', '1-hour gym session');
  \"

  echo 'Checking if table has any records:';
  mysql -u root -ppassword -D fullstack-app-db -e \"SELECT * FROM todos;\"
"

echo "Script execution completed."
