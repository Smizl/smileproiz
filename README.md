# SmileProiz — API Documentation

Backend: Spring Boot + PostgreSQL + JWT + WebSocket  
Client: Flutter (REST + WebSocket, SharedPreferences, retry/fallback)

Все эндпоинты разделены по контроллерам: **UserController**, **CartController**, **ProductController**.

---

## 🔐 Авторизация (JWT)

### Public (без токена)

- `POST /api/users/register`
- `POST /api/users/login`
- `GET  /api/users/test`
- `GET  /api/products`

### Protected (нужен токен)

- `GET  /api/users/{id}`
- `PUT  /api/users/{id}`
- `PUT  /api/users/{id}/push-setting`
- Все `/api/cart/*`
- `POST/PUT/DELETE /api/products` (если ограничены ролью ADMIN)

**Header:**

```
Authorization: Bearer <JWT_TOKEN>
```

---

## 📦 Формат ответа (ApiResponse)

```json
{
  "success": true,
  "message": "string",
  "data": {}
}
```

---

# 1️⃣ UserController — `/api/users`

## ✅ GET `/api/users/test`

Ответ:

```
✅ Backend работает!
```

---

## ✅ POST `/api/users/register`

### Body:

```json
{
  "email": "user@mail.com",
  "username": "User",
  "password": "123456"
}
```

### Response:

```json
{
  "success": true,
  "message": "Регистрация успешна ✅",
  "data": {
    "id": 1,
    "email": "user@mail.com",
    "username": "User",
    "role": "user",
    "pushEnabled": true,
    "phone": ""
  }
}
```

---

## ✅ POST `/api/users/login`

### Body:

```json
{
  "email": "user@mail.com",
  "password": "123456"
}
```

### Response:

```json
{
  "success": true,
  "message": "Успешный вход",
  "data": {
    "token": "JWT_TOKEN_HERE",
    "user": {
      "id": 1,
      "email": "user@mail.com",
      "username": "User",
      "role": "user",
      "pushEnabled": true,
      "phone": ""
    }
  }
}
```

---

## ✅ GET `/api/users/{id}`

JWT required.

### Response:

```json
{
  "success": true,
  "message": "Пользователь найден",
  "data": {
    "id": 1,
    "email": "user@mail.com",
    "username": "User",
    "role": "user",
    "pushEnabled": true,
    "phone": ""
  }
}
```

---

## ✅ PUT `/api/users/{id}`

JWT required.

### Body:

```json
{
  "username": "NewUser",
  "phone": "87001234567"
}
```

### Response:

```json
{
  "success": true,
  "message": "Пользователь обновлён",
  "data": {
    "id": 1,
    "email": "user@mail.com",
    "username": "NewUser",
    "role": "user",
    "pushEnabled": true,
    "phone": "87001234567"
  }
}
```

---

## 🔔 PUT `/api/users/{id}/push-setting`

JWT required.

### Body (включение/выключение push):

```json
{
  "pushEnabled": true
}
```

### Body (обновление FCM токена):

```json
{
  "fcmToken": "FCM_TOKEN_HERE"
}
```

### Response:

```json
{
  "success": true,
  "message": "Push settings updated",
  "data": null
}
```

---

# 2️⃣ CartController — `/api/cart`

JWT required.  
Роль: USER или ADMIN.

---

## ✅ GET `/api/cart/all`

### Response:

```json
[
  {
    "id": 1,
    "product": {
      "id": 5,
      "name": "Product",
      "price": 1000,
      "imageUrl": "..."
    },
    "quantity": 2,
    "selectedSize": "M",
    "selectedColor": "Red"
  }
]
```

---

## ✅ POST `/api/cart/add`

### Body:

```json
{
  "productId": 5,
  "quantity": 1,
  "selectedSize": "M",
  "selectedColor": "Red"
}
```

### Response (201 Created):

```json
{
  "id": 1,
  "product": {
    "id": 5,
    "name": "Product",
    "price": 1000,
    "imageUrl": "..."
  },
  "quantity": 1,
  "selectedSize": "M",
  "selectedColor": "Red"
}
```

---

## ✅ PUT `/api/cart/update/{id}?quantity=2`

### Response:

```json
{
  "id": 1,
  "product": {
    "id": 5,
    "name": "Product",
    "price": 1000
  },
  "quantity": 2,
  "selectedSize": "M",
  "selectedColor": "Red"
}
```

---

## ✅ DELETE `/api/cart/delete/{id}`

Response:  
`204 No Content`

---

## ✅ DELETE `/api/cart/clear`

Response:  
`204 No Content`

---

# 3️⃣ ProductController — `/api/products`

---

## ✅ GET `/api/products`

### Response:

```json
[
  {
    "id": 1,
    "name": "Product1",
    "price": 1000,
    "description": "Nice product"
  }
]
```

---

## ➕ POST `/api/products` (ADMIN recommended)

### Body:

```json
{
  "name": "Product1",
  "price": 1000,
  "description": "Nice product"
}
```

---

## ✏️ PUT `/api/products/{id}` (ADMIN recommended)

---

## ❌ DELETE `/api/products/{id}` (ADMIN recommended)

---

# ⚙️ Дополнительно

- CORS включён (`@CrossOrigin(origins = "*")`)
- JWT авторизация через `Authorization: Bearer <token>`
- Глобальный обработчик ошибок (`GlobalExceptionHandler`)
- WebSocket: `/ws/cart`
- Docker Compose (PostgreSQL + Backend)
- CI/CD: GitHub Actions + JaCoCo отчёт покрытия
- Flutter поддерживает retry/fallback и локальный кэш (SharedPreferences)

---

# 🛠️ Технологии

- Spring Boot 3
- PostgreSQL
- Spring Security + JWT
- WebSocket
- Flutter + Provider
- Docker
- GitHub Actions
