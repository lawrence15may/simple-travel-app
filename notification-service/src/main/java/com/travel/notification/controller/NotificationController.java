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
