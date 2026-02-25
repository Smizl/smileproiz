package com.smileproiz.model;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "products") // имя таблицы совпадает с твоей БД
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private int price;

    @Column(name = "image_url") // совпадает с колонкой в БД
    private String imageUrl;

    private String category;

    private String description;
    private String material;
    private String tag;

    @Column(name = "in_stock")
    private boolean inStock;

    // Дополнительные поля, которые есть в БД, но не были в Entity
    private String size; // например: "S, M, L"
    private String heights; // например: "170-180, 180-190"
    private String color; // например: hex-код цвета
    private String colors; // например: "Черный, Белый"

    public Product() {
    }

    public Product(String name, int price, String imageUrl, String category,
            String description, String material, String tag, boolean inStock,
            String size, String heights, String color, String colors) {
        this.name = name;
        this.price = price;
        this.imageUrl = imageUrl;
        this.category = category;
        this.description = description;
        this.material = material;
        this.tag = tag;
        this.inStock = inStock;
        this.size = size;
        this.heights = heights;
        this.color = color;
        this.colors = colors;
    }

    // Геттеры и сеттеры
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getPrice() {
        return price;
    }

    public void setPrice(int price) {
        this.price = price;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getMaterial() {
        return material;
    }

    public void setMaterial(String material) {
        this.material = material;
    }

    public String getTag() {
        return tag;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }

    public boolean isInStock() {
        return inStock;
    }

    public void setInStock(boolean inStock) {
        this.inStock = inStock;
    }

    public Boolean getInStock() {
        return inStock;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public String getHeights() {
        return heights;
    }

    public void setHeights(String heights) {
        this.heights = heights;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getColors() {
        return colors;
    }

    public void setColors(String colors) {
        this.colors = colors;
    }
}
