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
