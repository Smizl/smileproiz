# Документация API — Проект SmileProiz

Все эндпоинты сервера разделены по контроллерам: **UserController**, **CartController**, **ProductController**.  
Примеры данных соответствуют текущему коду проекта.

---

## 1️⃣ UserController

| Метод | URL                            | Описание                               | Параметры                                      | Пример ответа                                                                                              |
| ----- | ------------------------------ | -------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| GET   | `/api/users/test`              | Тестовый эндпоинт                      | —                                              | `"✅ Backend работает!"`                                                                                   |
| GET   | `/api/users/{id}`              | Получение профиля пользователя         | path: `id`                                     | `{ "id":1, "username":"User", "email":"user@mork.store", "phone":"", "pushToken":"", "pushEnabled":true }` |
| GET   | — (кэш)                        | Получение данных пользователя локально | SharedPreferences                              | `{ "id":1, "username":"User", "email":"user@mork.store" }`                                                 |
| POST  | `/api/users/register`          | Регистрация нового пользователя        | JSON: `username`, `email`, `password`          | `{ "id":1, "username":"User", "email":"user@mork.store" }`                                                 |
| POST  | `/api/users/login`             | Логин пользователя                     | JSON: `email`, `password`                      | `{ "id":1, "username":"User", "email":"user@mork.store" }`                                                 |
| PUT   | `/api/users/{id}`              | Обновление данных пользователя         | JSON: `username`, `email`, `phone`, `password` | `{ "id":1, "username":"NewUser", "email":"user@mork.store", "phone":"12345678" }`                          |
| PUT   | `/api/users/{id}/push-token`   | Обновление push-токена                 | JSON: `pushToken`                              | `200 OK`                                                                                                   |
| PUT   | `/api/users/{id}/push-setting` | Включение/отключение push-уведомлений  | JSON: `enabled`                                | `200 OK`                                                                                                   |
| POST  | `/api/users/logout`            | Выход пользователя                     | —                                              | `200 OK`                                                                                                   |

---

## 2️⃣ CartController

| Метод  | URL                     | Описание                    | Параметры                                                      | Пример ответа                                                                        |
| ------ | ----------------------- | --------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| GET    | `/api/cart/all`         | Получить все товары корзины | —                                                              | `[{"id":1,"productId":5,"quantity":2,"selectedSize":"M","selectedColor":"Red"}]`     |
| POST   | `/api/cart/add`         | Добавить товар в корзину    | JSON: `productId`, `quantity`, `selectedSize`, `selectedColor` | `{ "id":1, "productId":5, "quantity":2, "selectedSize":"M", "selectedColor":"Red" }` |
| DELETE | `/api/cart/delete/{id}` | Удалить товар по ID         | path: `id`                                                     | `200 OK`                                                                             |
| DELETE | `/api/cart/clear`       | Очистить корзину            | —                                                              | `200 OK`                                                                             |

---

## 3️⃣ ProductController

| Метод  | URL                  | Описание               | Параметры                                        | Пример ответа                                                             |
| ------ | -------------------- | ---------------------- | ------------------------------------------------ | ------------------------------------------------------------------------- |
| GET    | `/api/products`      | Получить все продукты  | —                                                | `[{"id":1,"name":"Product1","price":1000,"description":"Nice product"}]`  |
| POST   | `/api/products`      | Добавить новый продукт | JSON: `name`, `price`, `description`             | `{ "id":1, "name":"Product1","price":1000,"description":"Nice product" }` |
| PUT    | `/api/products/{id}` | Обновление продукта    | path: `id`, JSON: `name`, `price`, `description` | `{ "id":1, "name":"Product1New","price":1200,"description":"Updated"} `   |
| DELETE | `/api/products/{id}` | Удаление продукта      | path: `id`                                       | `200 OK`                                                                  |

---

### ⚡ Примечания

- Все эндпоинты поддерживают CORS (`@CrossOrigin(origins = "*")`), поэтому можно вызывать из Flutter.
- Ошибки возвращаются в формате JSON с полем `message`.
- Для push и локального кэширования используется SharedPreferences на клиенте.
- Все запросы поддерживают retry/fallback (см. ApiService.dart).
