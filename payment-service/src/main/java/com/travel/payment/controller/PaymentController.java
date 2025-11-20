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
