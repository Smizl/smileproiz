package com.smileproiz.model;

import jakarta.persistence.*;

@Entity
@Table(name = "cart_items")
public class CartItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ✅ Владелец корзины
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // ✅ Товар
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    private int quantity;
    private String selectedSize;
    private String selectedColor;

    @Column(nullable = false)
    private Integer price;

    public CartItem() {}

    public CartItem(User user, Product product, int quantity, String selectedSize, String selectedColor) {
        this.user = user;
        this.product = product;
        this.quantity = quantity;
        this.selectedSize = selectedSize != null ? selectedSize : "";
        this.selectedColor = selectedColor != null ? selectedColor : "";
        this.price = product.getPrice();
    }

    public Long getId() { return id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getSelectedSize() { return selectedSize; }
    public void setSelectedSize(String selectedSize) {
        this.selectedSize = selectedSize != null ? selectedSize : "";
    }

    public String getSelectedColor() { return selectedColor; }
    public void setSelectedColor(String selectedColor) {
        this.selectedColor = selectedColor != null ? selectedColor : "";
    }

    public Integer getPrice() { return price; }
    public void setPrice(Integer price) { this.price = price; }
}