package com.smileproiz.model;

import jakarta.persistence.*;

@Entity
@Table(name = "cart_items")
public class CartItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER) // убедимся, что Product подтягивается
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    private int quantity;
    private String selectedSize;
    private String selectedColor;

    @Column(nullable = false)
    private Integer price;

    public CartItem() {
    }

    public CartItem(Product product, int quantity, String selectedSize, String selectedColor) {
        this.product = product;
        this.quantity = quantity;
        this.selectedSize = selectedSize != null ? selectedSize : "";
        this.selectedColor = selectedColor != null ? selectedColor : "";
        this.price = Integer.valueOf(product.getPrice()); // безопасно
    }

    // Геттеры и сеттеры
    public Long getId() {
        return id;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getSelectedSize() {
        return selectedSize;
    }

    public void setSelectedSize(String selectedSize) {
        this.selectedSize = selectedSize != null ? selectedSize : "";
    }

    public String getSelectedColor() {
        return selectedColor;
    }

    public void setSelectedColor(String selectedColor) {
        this.selectedColor = selectedColor != null ? selectedColor : "";
    }

    public Integer getPrice() {
        return price;
    }

    public void setPrice(Integer price) {
        this.price = price;
    }
}
