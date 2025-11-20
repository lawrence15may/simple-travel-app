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
