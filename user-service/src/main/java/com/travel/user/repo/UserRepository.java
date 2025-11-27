package com.travel.user.repo;

import com.travel.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface UserRepository extends JpaRepository<User, Long> {

    List<User> findTop5ByOrderByIdAsc();
}

