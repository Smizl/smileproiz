package com.smileproiz.service;

import com.smileproiz.model.Product;
import com.smileproiz.repository.ProductRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductService {

    private static final Logger log = LoggerFactory.getLogger(ProductService.class);
    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public Product addProduct(Product product) {
        log.info("Add product: name={}, price={}", product.getName(), product.getPrice());
        return productRepository.save(product);
    }

    public Product updateProduct(Long id, Product product) {
        Product existing = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        existing.setName(product.getName());
        existing.setPrice(product.getPrice());
        existing.setImageUrl(product.getImageUrl());
        existing.setCategory(product.getCategory());
        existing.setDescription(product.getDescription());
        existing.setMaterial(product.getMaterial());
        existing.setTag(product.getTag());
        existing.setInStock(product.isInStock());

        // ✅ дополнительные поля тоже обновляем
        existing.setSize(product.getSize());
        existing.setHeights(product.getHeights());
        existing.setColor(product.getColor());
        existing.setColors(product.getColors());

        log.info("Update product id={}", id);
        return productRepository.save(existing);
    }

    public void deleteProduct(Long id) {
        if (!productRepository.existsById(id)) {
            throw new RuntimeException("Product not found");
        }
        log.warn("Delete product id={}", id);
        productRepository.deleteById(id);
    }
}