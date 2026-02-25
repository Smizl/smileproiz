package com.smileproiz.service;

import com.smileproiz.model.CartItem;
import com.smileproiz.model.Product;
import com.smileproiz.repository.CartRepository;
import com.smileproiz.repository.ProductRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;

@Service
public class CartService {

    private static final Logger logger = LoggerFactory.getLogger(CartService.class);

    private final CartRepository cartRepository;
    private final ProductRepository productRepository;

    public CartService(CartRepository cartRepository, ProductRepository productRepository) {
        this.cartRepository = cartRepository;
        this.productRepository = productRepository;
    }

    // Получить все товары в корзине
    public List<CartItem> getAllItems() {
        return cartRepository.findAll();
    }

    // Добавить товар в корзину (quantity всегда = 1)
    public CartItem addItem(Long productId, String selectedSize, String selectedColor) {

        // Приведение к trim() и стандартному регистру
        String size = selectedSize != null ? selectedSize.trim() : "Один размер";
        String color = selectedColor != null ? selectedColor.trim() : "Нет цвета";

        logger.info("Добавляем товар в корзину: productId={}, size={}, color={}",
                productId, size, color);

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Товар с id " + productId + " не найден"));

        // Проверка наличия на складе
        if (!product.isInStock()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Товар " + product.getName() + " отсутствует на складе");
        }

        // Проверяем, есть ли уже такой товар в корзине
        Optional<CartItem> existingItem = cartRepository
                .findByProductAndSelectedSizeAndSelectedColor(product, size, color);
        if (existingItem.isPresent()) {
            CartItem item = existingItem.get();
            item.setQuantity(item.getQuantity() + 1);
            return cartRepository.save(item);
        }
        // Создаём новый элемент корзины с quantity = 1
        CartItem item = new CartItem();
        item.setProduct(product);
        item.setQuantity(1);
        item.setSelectedSize(size);
        item.setSelectedColor(color);
        item.setPrice(product.getPrice());

        return cartRepository.save(item);
    }

    // Удалить товар из корзины
    public void removeItem(Long id) {
        if (!cartRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Товар в корзине с id " + id + " не найден");
        }
        cartRepository.deleteById(id);
    }

    // Очистить корзину
    public void clearCart() {
        cartRepository.deleteAll();
    }

    // Обновить количество товара
    public CartItem updateItemQuantity(Long cartItemId, int newQuantity) {
        CartItem item = cartRepository.findById(cartItemId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Товар в корзине с id " + cartItemId + " не найден"));

        if (newQuantity <= 0) {
            cartRepository.delete(item);
            return null;
        }

        item.setQuantity(newQuantity);
        return cartRepository.save(item);
    }
}