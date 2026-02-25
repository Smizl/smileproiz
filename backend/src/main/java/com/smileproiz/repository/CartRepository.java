package com.smileproiz.repository;

import com.smileproiz.model.CartItem;
import com.smileproiz.model.Product;
import com.smileproiz.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CartRepository extends JpaRepository<CartItem, Long> {

    List<CartItem> findByUser(User user);

    Optional<CartItem> findByUserAndProductAndSelectedSizeAndSelectedColor(
            User user, Product product, String selectedSize, String selectedColor
    );

    void deleteByUser(User user);
}