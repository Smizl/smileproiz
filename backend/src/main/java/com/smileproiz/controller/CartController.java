package com.smileproiz.controller;

import com.smileproiz.dto.AddToCartDto;
import com.smileproiz.model.CartItem;
import com.smileproiz.service.CartService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@PreAuthorize("hasAnyRole('USER','ADMIN')")
@RestController
@RequestMapping("/api/cart")
@CrossOrigin(origins = "*")
public class CartController {

    private static final Logger logger = LoggerFactory.getLogger(CartController.class);
    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping("/all")
    public List<CartItem> getCartItems() {
        return cartService.getAllItems(); // теперь вернёт только корзину текущего пользователя
    }

    @PostMapping("/add")
    public ResponseEntity<?> addToCart(@RequestBody AddToCartDto dto) {
        try {
            CartItem item = cartService.addItem(
                    dto.getProductId(),
                    dto.getSelectedSize(),
                    dto.getSelectedColor()
            );
            logger.info("Товар добавлен в корзину: {}", item.getId());
            return ResponseEntity.status(HttpStatus.CREATED).body(item);

        } catch (ResponseStatusException e) {
            logger.warn("Ошибка добавления в корзину: {}", e.getReason());
            return ResponseEntity.status(e.getStatusCode()).body(Map.of("error", e.getReason()));

        } catch (Exception e) {
            logger.error("Неожиданная ошибка при добавлении товара", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Внутренняя ошибка сервера"));
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteItem(@PathVariable Long id) {
        try {
            cartService.removeItem(id); // теперь нельзя удалить чужой item
            return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
        } catch (ResponseStatusException e) {
            return ResponseEntity.status(e.getStatusCode()).body(Map.of("error", e.getReason()));
        }
    }

    @DeleteMapping("/clear")
    public ResponseEntity<?> clearCart() {
        try {
            cartService.clearCart(); // теперь чистит только корзину текущего пользователя
            return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
        } catch (ResponseStatusException e) {
            return ResponseEntity.status(e.getStatusCode()).body(Map.of("error", e.getReason()));
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<?> updateItemQuantity(@PathVariable Long id, @RequestParam int quantity) {
        try {
            CartItem updated = cartService.updateItemQuantity(id, quantity); // тоже проверяет владельца
            return ResponseEntity.ok(updated);
        } catch (ResponseStatusException e) {
            return ResponseEntity.status(e.getStatusCode()).body(Map.of("error", e.getReason()));
        }
    }
}