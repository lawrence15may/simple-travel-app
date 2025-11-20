package com.travel.search.repo;

import com.travel.search.model.SearchItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SearchRepository extends JpaRepository<SearchItem, Long> {
  List<SearchItem> findByLocationContainingIgnoreCase(String location);
}
