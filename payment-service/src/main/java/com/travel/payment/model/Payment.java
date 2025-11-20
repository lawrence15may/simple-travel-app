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
