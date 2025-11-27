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

  @GetMapping("/health")
  public String health() {
      return "OK";
  }

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

  // NEW ENDPOINT — return top 5 users
  @GetMapping("/first5")
  public List<User> firstFive() {
    return repo.findTop5ByOrderByIdAsc();
  }
}

