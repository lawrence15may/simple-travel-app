package com.travel.booking.repo;

import com.travel.booking.model.Booking;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Long> {
  List<Booking> findByUserId(Long userId);
}
