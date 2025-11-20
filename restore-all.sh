#!/bin/bash
set -e

BASE="/travel-app"

echo "=== FULL REBUILD of Travel App project into $BASE ==="
mkdir -p "$BASE"
cd "$BASE"

############################################
# 0. MySQL SERVICE (schema + data)
############################################
echo "=== Creating mysql-service ==="
rm -rf mysql-service
mkdir -p mysql-service/init

cat > mysql-service/my.cnf << 'EOF'
[mysqld]
skip-host-cache
skip-name-resolve
EOF

cat > mysql-service/init/01-schema.sql << 'EOF'
CREATE DATABASE IF NOT EXISTS travel;
USE travel;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(150),
  password VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS search_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(50),
  title VARCHAR(200),
  location VARCHAR(100),
  price DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS bookings (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT,
  item_id BIGINT,
  status VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS payments (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  booking_id BIGINT,
  amount DECIMAL(10,2),
  status VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT,
  message VARCHAR(500),
  sent TINYINT(1) DEFAULT 0
);
EOF

cat > mysql-service/init/02-data.sql << 'EOF'
USE travel;

INSERT INTO users (name, email, password) VALUES
('Alice Singh','alice@example.com','pass1'),
('Bob Kumar','bob@example.com','pass2'),
('Carol Jose','carol@example.com','pass3');

INSERT INTO search_items (type, title, location, price) VALUES
('flight','Flight: BLR -> GOA','Goa',199.99),
('hotel','Hotel: Beachside Resort','Goa',89.99),
('package','Weekend: Goa Special','Goa',259.99),
('flight','Flight: DEL -> MUM','Mumbai',129.00);

INSERT INTO bookings (user_id, item_id, status) VALUES
(1,1,'CONFIRMED'),
(2,2,'CREATED');

INSERT INTO payments (booking_id, amount, status) VALUES
(1,199.99,'COMPLETED'),
(2,89.99,'PENDING');

INSERT INTO notifications (user_id, message, sent) VALUES
(1,'Booking confirmed for item 1',1),
(2,'Booking created for item 2',0),
(1,'Payment received for booking 1',1);
EOF

############################################
# Helper: create Java service structure
############################################
create_service() {
  local folder="$1"   # e.g. user-service
  local pkg="$2"      # e.g. user

  echo "=== Creating $folder (package com.travel.$pkg) ==="
  rm -rf "$folder"
  mkdir -p "$folder/src/main/java/com/travel/$pkg/controller"
  mkdir -p "$folder/src/main/java/com/travel/$pkg/model"
  mkdir -p "$folder/src/main/java/com/travel/$pkg/repo"
  mkdir -p "$folder/src/main/resources"
}

############################################
# 1. USER-SERVICE
############################################
create_service "user-service" "user"

cat > user-service/pom.xml << 'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.travel</groupId>
  <artifactId>user-service</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.7.13</version>
    <relativePath/>
  </parent>

  <properties>
    <java.version>17</java.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
      <scope>runtime</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF

cat > user-service/src/main/resources/application.yml << 'EOF'
spring:
  datasource:
    url: jdbc:mysql://mysql-service:3306/travel?allowPublicKeyRetrieval=true&useSSL=false
    username: root
    password: root
  jpa:
    hibernate:
      ddl-auto: none
    show-sql: true
server:
  port: 8081
EOF

cat > user-service/src/main/java/com/travel/user/UserServiceApplication.java << 'EOF'
package com.travel.user;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class UserServiceApplication {
  public static void main(String[] args) {
    SpringApplication.run(UserServiceApplication.class, args);
  }
}
EOF

cat > user-service/src/main/java/com/travel/user/model/User.java << 'EOF'
package com.travel.user.model;

import javax.persistence.*;

@Entity
@Table(name = "users")
public class User {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private String name;
  private String email;
  private String password;

  public User() {}

  public User(Long id, String name, String email, String password) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.password = password;
  }

  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }

  public String getName() { return name; }
  public void setName(String name) { this.name = name; }

  public String getEmail() { return email; }
  public void setEmail(String email) { this.email = email; }

  public String getPassword() { return password; }
  public void setPassword(String password) { this.password = password; }
}
EOF

cat > user-service/src/main/java/com/travel/user/repo/UserRepository.java << 'EOF'
package com.travel.user.repo;

import com.travel.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
}
EOF

cat > user-service/src/main/java/com/travel/user/controller/UserController.java << 'EOF'
package com.travel.user.controller;

import com.travel.user.model.User;
import com.travel.user.repo.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
public class UserController {

  @Autowired
  private UserRepository repo;

  @GetMapping
  public List<User> all() {
    return repo.findAll();
  }

  @GetMapping("/{id}")
  public User one(@PathVariable Long id) {
    return repo.findById(id).orElse(null);
  }

  @PostMapping
  public User create(@RequestBody User user) {
    return repo.save(user);
  }
}
EOF

############################################
# 2. BOOKING-SERVICE
############################################
create_service "booking-service" "booking"

cat > booking-service/pom.xml << 'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.travel</groupId>
  <artifactId>booking-service</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.7.13</version>
    <relativePath/>
  </parent>
  <properties>
    <java.version>17</java.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
      <scope>runtime</scope>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF

cat > booking-service/src/main/resources/application.yml << 'EOF'
spring:
  datasource:
    url: jdbc:mysql://mysql-service:3306/travel?allowPublicKeyRetrieval=true&useSSL=false
    username: root
    password: root
  jpa:
    hibernate:
      ddl-auto: none
    show-sql: true
server:
  port: 8083
EOF

cat > booking-service/src/main/java/com/travel/booking/BookingServiceApplication.java << 'EOF'
package com.travel.booking;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BookingServiceApplication {
  public static void main(String[] args) {
    SpringApplication.run(BookingServiceApplication.class, args);
  }
}
EOF

cat > booking-service/src/main/java/com/travel/booking/model/Booking.java << 'EOF'
package com.travel.booking.model;

import javax.persistence.*;

@Entity
@Table(name = "bookings")
public class Booking {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private Long userId;
  private Long itemId;
  private String status;

  public Booking() {}

  public Booking(Long userId, Long itemId, String status) {
    this.userId = userId;
    this.itemId = itemId;
    this.status = status;
  }

  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }

  public Long getUserId() { return userId; }
  public void setUserId(Long userId) { this.userId = userId; }

  public Long getItemId() { return itemId; }
  public void setItemId(Long itemId) { this.itemId = itemId; }

  public String getStatus() { return status; }
  public void setStatus(String status) { this.status = status; }
}
EOF

cat > booking-service/src/main/java/com/travel/booking/repo/BookingRepository.java << 'EOF'
package com.travel.booking.repo;

import com.travel.booking.model.Booking;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Long> {
  List<Booking> findByUserId(Long userId);
}
EOF

cat > booking-service/src/main/java/com/travel/booking/controller/BookingController.java << 'EOF'
package com.travel.booking.controller;

import com.travel.booking.model.Booking;
import com.travel.booking.repo.BookingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/bookings")
public class BookingController {

  @Autowired
  private BookingRepository repo;

  @GetMapping
  public List<Booking> all() {
    return repo.findAll();
  }

  @GetMapping("/{id}")
  public Booking get(@PathVariable Long id) {
    return repo.findById(id).orElse(null);
  }

  @GetMapping("/user/{userId}")
  public List<Booking> byUser(@PathVariable Long userId) {
    return repo.findByUserId(userId);
  }

  @PostMapping
  public Booking create(@RequestBody Booking b) {
    b.setStatus("CREATED");
    return repo.save(b);
  }
}
EOF

############################################
# 3. PAYMENT-SERVICE
############################################
create_service "payment-service" "payment"

cat > payment-service/pom.xml << 'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.travel</groupId>
  <artifactId>payment-service</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.7.13</version>
    <relativePath/>
  </parent>
  <properties>
    <java.version>17</java.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
      <scope>runtime</scope>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF

cat > payment-service/src/main/resources/application.yml << 'EOF'
spring:
  datasource:
    url: jdbc:mysql://mysql-service:3306/travel?allowPublicKeyRetrieval=true&useSSL=false
    username: root
    password: root
  jpa:
    hibernate:
      ddl-auto: none
    show-sql: true
server:
  port: 8084
EOF

cat > payment-service/src/main/java/com/travel/payment/PaymentServiceApplication.java << 'EOF'
package com.travel.payment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class PaymentServiceApplication {
  public static void main(String[] args) {
    SpringApplication.run(PaymentServiceApplication.class, args);
  }
}
EOF

cat > payment-service/src/main/java/com/travel/payment/model/Payment.java << 'EOF'
package com.travel.payment.model;

import javax.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "payments")
public class Payment {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private Long bookingId;
  private BigDecimal amount;
  private String status;

  public Payment() {}

  public Payment(Long bookingId, BigDecimal amount, String status) {
    this.bookingId = bookingId;
    this.amount = amount;
    this.status = status;
  }

  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }

  public Long getBookingId() { return bookingId; }
  public void setBookingId(Long bookingId) { this.bookingId = bookingId; }

  public BigDecimal getAmount() { return amount; }
  public void setAmount(BigDecimal amount) { this.amount = amount; }

  public String getStatus() { return status; }
  public void setStatus(String status) { this.status = status; }
}
EOF

cat > payment-service/src/main/java/com/travel/payment/repo/PaymentRepository.java << 'EOF'
package com.travel.payment.repo;

import com.travel.payment.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
}
EOF

cat > payment-service/src/main/java/com/travel/payment/controller/PaymentController.java << 'EOF'
package com.travel.payment.controller;

import com.travel.payment.model.Payment;
import com.travel.payment.repo.PaymentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/payments")
public class PaymentController {

  @Autowired
  private PaymentRepository repo;

  @GetMapping
  public List<Payment> all() {
    return repo.findAll();
  }

  @GetMapping("/{id}")
  public Payment get(@PathVariable Long id) {
    return repo.findById(id).orElse(null);
  }

  @PostMapping
  public Payment create(@RequestBody Payment p) {
    p.setStatus("COMPLETED");
    return repo.save(p);
  }
}
EOF

############################################
# 4. NOTIFICATION-SERVICE
############################################
create_service "notification-service" "notification"

cat > notification-service/pom.xml << 'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.travel</groupId>
  <artifactId>notification-service</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.7.13</version>
    <relativePath/>
  </parent>
  <properties>
    <java.version>17</java.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
      <scope>runtime</scope>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF

cat > notification-service/src/main/resources/application.yml << 'EOF'
spring:
  datasource:
    url: jdbc:mysql://mysql-service:3306/travel?allowPublicKeyRetrieval=true&useSSL=false
    username: root
    password: root
  jpa:
    hibernate:
      ddl-auto: none
    show-sql: true
server:
  port: 8085
EOF

cat > notification-service/src/main/java/com/travel/notification/NotificationServiceApplication.java << 'EOF'
package com.travel.notification;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class NotificationServiceApplication {
  public static void main(String[] args) {
    SpringApplication.run(NotificationServiceApplication.class, args);
  }
}
EOF

cat > notification-service/src/main/java/com/travel/notification/model/Notification.java << 'EOF'
package com.travel.notification.model;

import javax.persistence.*;

@Entity
@Table(name = "notifications")
public class Notification {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private Long userId;
  private String message;
  private boolean sent;

  public Notification() {}

  public Notification(Long userId, String message, boolean sent) {
    this.userId = userId;
    this.message = message;
    this.sent = sent;
  }

  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }

  public Long getUserId() { return userId; }
  public void setUserId(Long userId) { this.userId = userId; }

  public String getMessage() { return message; }
  public void setMessage(String message) { this.message = message; }

  public boolean isSent() { return sent; }
  public void setSent(boolean sent) { this.sent = sent; }
}
EOF

cat > notification-service/src/main/java/com/travel/notification/repo/NotificationRepository.java << 'EOF'
package com.travel.notification.repo;

import com.travel.notification.model.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
  List<Notification> findByUserId(Long userId);
}
EOF

cat > notification-service/src/main/java/com/travel/notification/controller/NotificationController.java << 'EOF'
package com.travel.notification.controller;

import com.travel.notification.model.Notification;
import com.travel.notification.repo.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/notifications")
public class NotificationController {

  @Autowired
  private NotificationRepository repo;

  @GetMapping
  public List<Notification> all() {
    return repo.findAll();
  }

  @GetMapping("/user/{userId}")
  public List<Notification> byUser(@PathVariable Long userId) {
    return repo.findByUserId(userId);
  }

  @PostMapping
  public Notification create(@RequestBody Notification n) {
    n.setSent(false);
    return repo.save(n);
  }
}
EOF

############################################
# 5. SEARCH-SERVICE
############################################
create_service "search-service" "search"

cat > search-service/pom.xml << 'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.travel</groupId>
  <artifactId>search-service</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.7.13</version>
    <relativePath/>
  </parent>
  <properties>
    <java.version>17</java.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
      <scope>runtime</scope>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF

cat > search-service/src/main/resources/application.yml << 'EOF'
spring:
  datasource:
    url: jdbc:mysql://mysql-service:3306/travel?allowPublicKeyRetrieval=true&useSSL=false
    username: root
    password: root
  jpa:
    hibernate:
      ddl-auto: none
    show-sql: true
server:
  port: 8082
EOF

cat > search-service/src/main/java/com/travel/search/SearchServiceApplication.java << 'EOF'
package com.travel.search;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SearchServiceApplication {
  public static void main(String[] args) {
    SpringApplication.run(SearchServiceApplication.class, args);
  }
}
EOF

cat > search-service/src/main/java/com/travel/search/model/SearchItem.java << 'EOF'
package com.travel.search.model;

import javax.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "search_items")
public class SearchItem {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private String type;
  private String title;
  private String location;
  private BigDecimal price;

  public SearchItem() {}

  public SearchItem(String type, String title, String location, BigDecimal price) {
    this.type = type;
    this.title = title;
    this.location = location;
    this.price = price;
  }

  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }

  public String getType() { return type; }
  public void setType(String type) { this.type = type; }

  public String getTitle() { return title; }
  public void setTitle(String title) { this.title = title; }

  public String getLocation() { return location; }
  public void setLocation(String location) { this.location = location; }

  public BigDecimal getPrice() { return price; }
  public void setPrice(BigDecimal price) { this.price = price; }
}
EOF

cat > search-service/src/main/java/com/travel/search/repo/SearchRepository.java << 'EOF'
package com.travel.search.repo;

import com.travel.search.model.SearchItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SearchRepository extends JpaRepository<SearchItem, Long> {
  List<SearchItem> findByLocationContainingIgnoreCase(String location);
}
EOF

cat > search-service/src/main/java/com/travel/search/controller/SearchController.java << 'EOF'
package com.travel.search.controller;

import com.travel.search.model.SearchItem;
import com.travel.search.repo.SearchRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/search")
public class SearchController {

  @Autowired
  private SearchRepository repo;

  @GetMapping
  public List<SearchItem> search(@RequestParam(required = false) String location) {
    if (location == null || location.isEmpty()) {
      return repo.findAll();
    }
    return repo.findByLocationContainingIgnoreCase(location);
  }
}
EOF

############################################
# 6. GATEWAY-SERVICE
############################################
echo "=== Creating gateway-service ==="
rm -rf gateway-service
mkdir -p gateway-service/src/main/java/com/travel/gateway/controller
mkdir -p gateway-service/src/main/java/com/travel/gateway
mkdir -p gateway-service/src/main/resources

cat > gateway-service/pom.xml << 'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.travel</groupId>
  <artifactId>gateway-service</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.7.13</version>
    <relativePath/>
  </parent>
  <properties>
    <java.version>17</java.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-webflux</artifactId>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF

cat > gateway-service/src/main/resources/application.yml << 'EOF'
server:
  port: 8080
EOF

cat > gateway-service/src/main/java/com/travel/gateway/GatewayServiceApplication.java << 'EOF'
package com.travel.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
public class GatewayServiceApplication {

  public static void main(String[] args) {
    SpringApplication.run(GatewayServiceApplication.class, args);
  }

  @Bean
  public RestTemplate restTemplate() {
    return new RestTemplate();
  }
}
EOF

cat > gateway-service/src/main/java/com/travel/gateway/controller/GatewayController.java << 'EOF'
package com.travel.gateway.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping("/api")
public class GatewayController {

  @Autowired
  private RestTemplate rest;

  private String USER_URL    = System.getenv().getOrDefault("USER_URL","http://user-service:8081");
  private String BOOKING_URL = System.getenv().getOrDefault("BOOKING_URL","http://booking-service:8083");
  private String SEARCH_URL  = System.getenv().getOrDefault("SEARCH_URL","http://search-service:8082");

  @GetMapping("/users/{id}")
  public Object getUser(@PathVariable Long id){
    String url = USER_URL + "/users/" + id;
    return rest.getForObject(url, Object.class);
  }

  @GetMapping("/users/{id}/bookings")
  public Object userBookings(@PathVariable Long id){
    String url = BOOKING_URL + "/bookings/user/" + id;
    return rest.getForObject(url, Object.class);
  }

  @GetMapping("/search")
  public Object search(@RequestParam String location){
    String url = SEARCH_URL + "/search?location=" + location;
    return rest.getForObject(url, Object.class);
  }
}
EOF

############################################
# 7. FRONTEND-SERVICE
############################################
echo "=== Creating frontend-service ==="
rm -rf frontend-service
mkdir -p frontend-service

cat > frontend-service/index.html << 'EOF'
<!doctype html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>Travel POC</title>
</head>
<body>
  <h1>Travel POC Frontend</h1>
  <div>
    <h3>Get User</h3>
    <input id="uid" placeholder="user id" value="1"/>
    <button onclick="getUser()">Get User</button>
    <pre id="userout"></pre>
  </div>

  <div>
    <h3>Search</h3>
    <input id="loc" placeholder="location" value="Goa"/>
    <button onclick="search()">Search</button>
    <pre id="searchout"></pre>
  </div>

<script>
const API = window.API_URL || "http://localhost:8080/api";

function getUser(){
  const id = document.getElementById('uid').value;
  fetch(API + '/users/' + id)
    .then(r=>r.json())
    .then(j => { document.getElementById('userout').innerText = JSON.stringify(j, null, 2); })
    .catch(err => { document.getElementById('userout').innerText = err; });
}

function search(){
  const loc = document.getElementById('loc').value;
  fetch(API + '/search?location=' + encodeURIComponent(loc))
    .then(r=>r.json())
    .then(j => { document.getElementById('searchout').innerText = JSON.stringify(j, null, 2); })
    .catch(err => { document.getElementById('searchout').innerText = err; });
}
</script>
</body>
</html>
EOF

cat > frontend-service/package.json << 'EOF'
{
  "name": "travel-frontend",
  "version": "1.0.0",
  "description": "Simple static frontend served by Nginx",
  "scripts": {
    "start": "echo 'Frontend is served by Nginx container'"
  }
}
EOF

############################################
# Dockerfiles for all services
############################################
echo "=== Creating Dockerfiles ==="

for svc in user-service booking-service payment-service search-service notification-service gateway-service; do
  PORT=8080
  case "$svc" in
    user-service) PORT=8081 ;;
    search-service) PORT=8082 ;;
    booking-service) PORT=8083 ;;
    payment-service) PORT=8084 ;;
    notification-service) PORT=8085 ;;
    gateway-service) PORT=8080 ;;
  esac

  cat > $svc/Dockerfile << EOF
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q dependency:go-offline
COPY src ./src
RUN mvn -q clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE $PORT
ENTRYPOINT ["java","-jar","/app/app.jar"]
EOF
done

cat > frontend-service/Dockerfile << 'EOF'
FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY index.html ./index.html
EXPOSE 80
EOF

############################################
# docker-compose.yml
############################################
echo "=== Creating docker-compose.yml ==="

cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  mysql-service:
    image: mysql:8
    container_name: mysql-service
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: root
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./mysql-service/init:/docker-entrypoint-initdb.d

  user-service:
    build: ./user-service
    container_name: user-service
    depends_on:
      - mysql-service
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql-service:3306/travel?allowPublicKeyRetrieval=true&useSSL=false
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: root
    ports:
      - "8081:8081"

  search-service:
    build: ./search-service
    container_name: search-service
    depends_on:
      - mysql-service
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql-service:3306/travel?allowPublicKeyRetrieval=true&useSSL=false
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: root
    ports:
      - "8082:8082"

  booking-service:
    build: ./booking-service
    container_name: booking-service
    depends_on:
      - mysql-service
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql-service:3306/travel?allowPublicKeyRetrieval=true&useSSL=false
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: root
    ports:
      - "8083:8083"

  payment-service:
    build: ./payment-service
    container_name: payment-service
    depends_on:
      - mysql-service
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql-service:3306/travel?allowPublicKeyRetrieval=true&useSSL=false
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: root
    ports:
      - "8084:8084"

  notification-service:
    build: ./notification-service
    container_name: notification-service
    depends_on:
      - mysql-service
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql-service:3306/travel?allowPublicKeyRetrieval=true&useSSL=false
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: root
    ports:
      - "8085:8085"

  gateway-service:
    build: ./gateway-service
    container_name: gateway-service
    depends_on:
      - user-service
      - booking-service
      - search-service
    ports:
      - "8080:8080"
    environment:
      USER_URL: http://user-service:8081
      BOOKING_URL: http://booking-service:8083
      SEARCH_URL: http://search-service:8082

  frontend-service:
    build: ./frontend-service
    container_name: frontend-service
    depends_on:
      - gateway-service
    ports:
      - "3000:80"
    environment:
      API_URL: http://gateway-service:8080/api

volumes:
  mysql_data:
EOF

echo "=== FULL RESTORE COMPLETE. Next: docker-compose build && docker-compose up -d ==="

