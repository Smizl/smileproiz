package com.smileproiz.service;

import com.smileproiz.model.CartItem;
import com.smileproiz.model.Product;
import com.smileproiz.model.User;
import com.smileproiz.repository.CartRepository;
import com.smileproiz.repository.ProductRepository;
import com.smileproiz.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;

@Service
public class CartService {

    private static final Logger logger = LoggerFactory.getLogger(CartService.class);

    private final CartRepository cartRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    public CartService(CartRepository cartRepository,
                       ProductRepository productRepository,
                       UserRepository userRepository) {
        this.cartRepository = cartRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
    }

private User currentUser() {
    var auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth == null || auth.getPrincipal() == null) {
        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized");
    }
    String email = auth.getPrincipal().toString().trim().toLowerCase();
    return userRepository.findByEmail(email)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User not found"));
}

    // Получить корзину только текущего пользователя
    public List<CartItem> getAllItems() {
        User user = currentUser();
        return cartRepository.findByUser(user);
    }

    public CartItem addItem(Long productId, String selectedSize, String selectedColor) {
        User user = currentUser();

        String size = selectedSize != null ? selectedSize.trim() : "Один размер";
        String color = selectedColor != null ? selectedColor.trim() : "Нет цвета";

        logger.info("Add to cart: user={}, productId={}, size={}, color={}",
                user.getEmail(), productId, size, color);

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Товар с id " + productId + " не найден"));

        if (!product.isInStock()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Товар " + product.getName() + " отсутствует на складе");
        }

        Optional<CartItem> existingItem = cartRepository
                .findByUserAndProductAndSelectedSizeAndSelectedColor(user, product, size, color);

        if (existingItem.isPresent()) {
            CartItem item = existingItem.get();
            item.setQuantity(item.getQuantity() + 1);
            return cartRepository.save(item);
        }

        CartItem item = new CartItem();
        item.setUser(user);
        item.setProduct(product);
        item.setQuantity(1);
        item.setSelectedSize(size);
        item.setSelectedColor(color);
        item.setPrice(product.getPrice());

        return cartRepository.save(item);
    }

    public void removeItem(Long id) {
        User user = currentUser();

        CartItem item = cartRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Товар в корзине с id " + id + " не найден"));

        // запрет удалить чужой item
        if (!item.getUser().getId().equals(user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Нет доступа к чужой корзине");
        }

        cartRepository.delete(item);
    }

    public void clearCart() {
        User user = currentUser();
        cartRepository.deleteByUser(user);
    }

    public CartItem updateItemQuantity(Long cartItemId, int newQuantity) {
        User user = currentUser();

        CartItem item = cartRepository.findById(cartItemId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Товар в корзине с id " + cartItemId + " не найден"));

        if (!item.getUser().getId().equals(user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Нет доступа к чужой корзине");
        }

        if (newQuantity <= 0) {
            cartRepository.delete(item);
            return null;
        }

        item.setQuantity(newQuantity);
        return cartRepository.save(item);
    }
}