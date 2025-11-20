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
