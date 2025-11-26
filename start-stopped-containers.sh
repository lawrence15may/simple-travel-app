#!/bin/bash

echo "Starting the containers..."

# 1 --> MySQL Port-3305
docker start mysql-service

# 2 --> Gateway-microservice Port-8080
docker start gateway-service

# 3 --> User-microservice Port-8081
docker start user-service

# 4 --> Search-microservice Port-8082
docker start search-service

# 5 --> Booking-microservice Port-8083
docker start booking-service

# 6 --> Payment-microservice Port-8084
docker start payment-service

# 7 --> Notification-microservice Port-8085
docker start notification-service

# 8 --> Frontend-microservice Port-3000
docker start frontend-service

echo "All 8 containers are started!"
