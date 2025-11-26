#!/bin/bash

echo "Starting all travel-app containers..."

# 1. MySQL
docker run -d --name mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=travel \
  -p 3306:3306 \
  mysql:8

# 2. Booking Service
docker run -d --name booking-service \
  -p 8083:8083 \
  travel-app_booking-service:latest

# 3. Frontend Service
docker run -d --name frontend-service \
  -p 3000:3000 \
  travel-app_frontend-service:latest

# 4. Gateway Service
docker run -d --name gateway-service \
  -p 8080:8080 \
  travel-app_gateway-service:latest

# 5. Notification Service
docker run -d --name notification-service \
  -p 8085:8085 \
  travel-app_notification-service:latest

# 6. Payment Service
docker run -d --name payment-service \
  -p 8084:8084 \
  travel-app_payment-service:latest

# 7. Search Service
docker run -d --name search-service \
  -p 8082:8082 \
  travel-app_search-service:latest

# 8. User Service
docker run -d --name user-service \
  -p 8081:8081 \
  travel-app_user-service:latest

echo "All containers started!"

