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
