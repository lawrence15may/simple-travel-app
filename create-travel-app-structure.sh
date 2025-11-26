#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="travel-app"

echo "Creating project structure under ./$BASE_DIR"

mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

# Top-level files
touch README.md
touch docker-compose.yml

############################
# booking-service
############################
mkdir -p booking-service/src/main/java/com/travel/booking/controller
mkdir -p booking-service/src/main/java/com/travel/booking/model
mkdir -p booking-service/src/main/java/com/travel/booking/repo
mkdir -p booking-service/src/main/resources

touch booking-service/Dockerfile
touch booking-service/pom.xml

touch booking-service/src/main/java/com/travel/booking/BookingServiceApplication.java
touch booking-service/src/main/java/com/travel/booking/controller/BookingController.java
touch booking-service/src/main/java/com/travel/booking/model/Booking.java
touch booking-service/src/main/java/com/travel/booking/repo/BookingRepository.java

touch booking-service/src/main/resources/application.yml

############################
# frontend-service
############################
mkdir -p frontend-service

touch frontend-service/Dockerfile
touch frontend-service/index.html
touch frontend-service/package.json
touch frontend-service/server.js

############################
# gateway-service
############################
mkdir -p gateway-service/src/main/java/com/travel/gateway/config
mkdir -p gateway-service/src/main/java/com/travel/gateway/controller
mkdir -p gateway-service/src/main/resources

touch gateway-service/Dockerfile
touch gateway-service/pom.xml

touch gateway-service/src/main/java/com/travel/gateway/GatewayServiceApplication.java
touch gateway-service/src/main/java/com/travel/gateway/config/AppConfig.java
touch gateway-service/src/main/java/com/travel/gateway/controller/GatewayController.java

touch gateway-service/src/main/resources/application.properties
touch gateway-service/src/main/resources/application.yml

############################
# mysql-service
############################
mkdir -p mysql-service/init

touch mysql-service/Dockerfile
touch mysql-service/init/01-schema.sql
touch mysql-service/init/02-data.sql
touch mysql-service/my.cnf

############################
# notification-service
############################
mkdir -p notification-service/src/main/java/com/travel/notification/controller
mkdir -p notification-service/src/main/java/com/travel/notification/model
mkdir -p notification-service/src/main/java/com/travel/notification/repo
mkdir -p notification-service/src/main/resources

touch notification-service/Dockerfile
touch notification-service/pom.xml

touch notification-service/src/main/java/com/travel/notification/NotificationServiceApplication.java
touch notification-service/src/main/java/com/travel/notification/controller/NotificationController.java
touch notification-service/src/main/java/com/travel/notification/model/Notification.java
touch notification-service/src/main/java/com/travel/notification/repo/NotificationRepository.java

touch notification-service/src/main/resources/application.properties
touch notification-service/src/main/resources/application.yml

############################
# payment-service
############################
mkdir -p payment-service/src/main/java/com/travel/payment/controller
mkdir -p payment-service/src/main/java/com/travel/payment/model
mkdir -p payment-service/src/main/java/com/travel/payment/repo
mkdir -p payment-service/src/main/resources

touch payment-service/Dockerfile
touch payment-service/pom.xml

touch payment-service/src/main/java/com/travel/payment/PaymentServiceApplication.java
touch payment-service/src/main/java/com/travel/payment/controller/PaymentController.java
touch payment-service/src/main/java/com/travel/payment/model/Payment.java
touch payment-service/src/main/java/com/travel/payment/repo/PaymentRepository.java

touch payment-service/src/main/resources/application.properties
touch payment-service/src/main/resources/application.yml

############################
# search-service
############################
mkdir -p search-service/src/main/java/com/travel/search/controller
mkdir -p search-service/src/main/java/com/travel/search/model
mkdir -p search-service/src/main/java/com/travel/search/repo
mkdir -p search-service/src/main/resources

touch search-service/Dockerfile
touch search-service/pom.xml

touch search-service/src/main/java/com/travel/search/SearchServiceApplication.java
touch search-service/src/main/java/com/travel/search/controller/SearchController.java
touch search-service/src/main/java/com/travel/search/model/SearchItem.java
touch search-service/src/main/java/com/travel/search/repo/SearchRepository.java

touch search-service/src/main/resources/application.properties
touch search-service/src/main/resources/application.yml

############################
# user-service
############################
mkdir -p user-service/src/main/java/com/travel/user/controller
mkdir -p user-service/src/main/java/com/travel/user/model
mkdir -p user-service/src/main/java/com/travel/user/repo
mkdir -p user-service/src/main/resources

touch user-service/Dockerfile
touch user-service/pom.xml

touch user-service/src/main/java/com/travel/user/UserServiceApplication.java
touch user-service/src/main/java/com/travel/user/controller/UserController.java
touch user-service/src/main/java/com/travel/user/model/User.java
touch user-service/src/main/java/com/travel/user/repo/UserRepository.java

touch user-service/src/main/resources/application.properties
touch user-service/src/main/resources/application.yml

echo "Done. Project structure created."

