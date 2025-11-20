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
