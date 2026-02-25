package com.smileproiz.repository;

import com.smileproiz.model.CartItem;
import com.smileproiz.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CartRepository extends JpaRepository<CartItem, Long> {

    Optional<CartItem> findByProductAndSelectedSizeAndSelectedColor(
            Product product, String selectedSize, String selectedColor);
}
