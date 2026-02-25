-- ✅ Добавляем товары только если такого name ещё нет
INSERT INTO products (name, price, image_url, category, description, material, tag, in_stock, size, heights, color, colors)
SELECT
  'ОВЕРСАЙЗ ХУДИ ЧЕРНЫЙ', 15000, NULL, 'clothes', NULL, NULL, NULL, true, NULL, NULL, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ОВЕРСАЙЗ ХУДИ ЧЕРНЫЙ');

INSERT INTO products (name, price, image_url, category, description, material, tag, in_stock, size, heights, color, colors)
SELECT
  'КАРГО БРЮКИ СЕРЫЕ', 18000, NULL, 'clothes', NULL, NULL, NULL, true, NULL, NULL, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'КАРГО БРЮКИ СЕРЫЕ');

INSERT INTO products (name, price, image_url, category, description, material, tag, in_stock, size, heights, color, colors)
SELECT
  'КЕПКА STREETWEAR', 5000, NULL, 'accessories', NULL, NULL, NULL, true, NULL, NULL, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'КЕПКА STREETWEAR');

-- ✅ Дополнительные демо-товары (новые)
INSERT INTO products (name, price, image_url, category, description, material, tag, in_stock, size, heights, color, colors)
SELECT
  'ФУТБОЛКА BASIC', 7000, NULL, 'clothes', 'Демо товар', 'cotton', 'demo', true, 'S,M,L', NULL, NULL, 'Black,White'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ФУТБОЛКА BASIC');

INSERT INTO products (name, price, image_url, category, description, material, tag, in_stock, size, heights, color, colors)
SELECT
  'ХУДИ DEMO', 19000, NULL, 'clothes', 'Демо товар', 'cotton', 'demo', true, 'M,L,XL', NULL, NULL, 'Black'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ХУДИ DEMO');

INSERT INTO products (name, price, image_url, category, description, material, tag, in_stock, size, heights, color, colors)
SELECT
  'СУМКА CROSSBODY', 11000, NULL, 'accessories', 'Демо товар', NULL, 'demo', true, NULL, NULL, NULL, 'Black'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'СУМКА CROSSBODY');