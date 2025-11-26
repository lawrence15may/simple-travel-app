# simple-travel-app
Simple microservice travel application for testing CI/CD on Single Docker server, Self managed cloud server, Kubernetes and ECS
travel-app
├── README.md
├── booking-service
│   ├── Dockerfile
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── travel
│           │           └── booking
│           │               ├── BookingServiceApplication.java
│           │               ├── controller
│           │               │   └── BookingController.java
│           │               ├── model
│           │               │   └── Booking.java
│           │               └── repo
│           │                   └── BookingRepository.java
│           └── resources
│               └── application.yml
├── docker-compose.yml
├── frontend-service
│   ├── Dockerfile
│   ├── index.html
│   ├── package.json
│   └── server.js
├── gateway-service
│   ├── Dockerfile
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── travel
│           │           └── gateway
│           │               ├── GatewayServiceApplication.java
│           │               ├── config
│           │               │   └── AppConfig.java
│           │               └── controller
│           │                   └── GatewayController.java
│           └── resources
│               ├── application.properties
│               └── application.yml
├── mysql-service
│   ├── Dockerfile
│   ├── init
│   │   ├── 01-schema.sql
│   │   └── 02-data.sql
│   └── my.cnf
├── notification-service
│   ├── Dockerfile
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── travel
│           │           └── notification
│           │               ├── NotificationServiceApplication.java
│           │               ├── controller
│           │               │   └── NotificationController.java
│           │               ├── model
│           │               │   └── Notification.java
│           │               └── repo
│           │                   └── NotificationRepository.java
│           └── resources
│               ├── application.properties
│               └── application.yml
├── payment-service
│   ├── Dockerfile
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── travel
│           │           └── payment
│           │               ├── PaymentServiceApplication.java
│           │               ├── controller
│           │               │   └── PaymentController.java
│           │               ├── model
│           │               │   └── Payment.java
│           │               └── repo
│           │                   └── PaymentRepository.java
│           └── resources
│               ├── application.properties
│               └── application.yml
├── search-service
│   ├── Dockerfile
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── travel
│           │           └── search
│           │               ├── SearchServiceApplication.java
│           │               ├── controller
│           │               │   └── SearchController.java
│           │               ├── model
│           │               │   └── SearchItem.java
│           │               └── repo
│           │                   └── SearchRepository.java
│           └── resources
│               ├── application.properties
│               └── application.yml
├── start-all-containers.sh
├── start-stopped-containers.sh
└── user-service
    ├── Dockerfile
    ├── pom.xml
    └── src
        └── main
            ├── java
            │   └── com
            │       └── travel
            │           └── user
            │               ├── UserServiceApplication.java
            │               ├── controller
            │               │   └── UserController.java
            │               ├── model
            │               │   └── User.java
            │               └── repo
            │                   └── UserRepository.java
            └── resources
                ├── application.properties
                └── application.yml

69 directories, 58 files

