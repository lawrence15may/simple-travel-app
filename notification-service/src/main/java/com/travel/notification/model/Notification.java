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
