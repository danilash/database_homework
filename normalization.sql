-- Приведение к 3НФ
-- 1)Создание таблицы сервисов
CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    service_name TEXT NOT NULL,
    service_addr TEXT NOT NULL
);

-- 2)Создание таблицы работников
CREATE TABLE workers (
    id SERIAL PRIMARY KEY,
    w_name TEXT NOT NULL,
    w_exp INT,
    w_phone TEXT,
    wages INT
);

-- 3)Создание таблицы клиентов
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    password TEXT
);

-- 4)Создание таблицы автомобилей
CREATE TABLE cars (
    id SERIAL PRIMARY KEY,
    car TEXT NOT NULL,
    vin TEXT,
    car_number TEXT,
    color TEXT
);

-- 5)Создание таблицы orders
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(id),          -- Внешний ключ для связи с клиентами
    worker_id INT REFERENCES workers(id),         -- Внешний ключ для связи с работниками
    service_id INT REFERENCES services(id),       -- Внешний ключ для связи с сервисами
    car_id INT REFERENCES cars(id),               -- Внешний ключ для связи с автомобилями
    date DATE NOT NULL,
    mileage INT,                                   
    payment TEXT,
    card TEXT,
    pin TEXT
);

-- 6)Добавление индексов для ускорения поиска
CREATE INDEX idx_services_name ON services(service_name);
CREATE INDEX idx_workers_name ON workers(w_name);
CREATE INDEX idx_clients_email ON clients(email);
CREATE INDEX idx_cars_vin ON cars(vin);
CREATE INDEX idx_orders_date ON orders(date);

---------------------------------------------------------------------------------------------------------------------------------

-- Заполнение таблиц данными из таблицы auto_service
-- 1) Заполнение таблицы сервисов
INSERT INTO services (service_name, service_addr)
SELECT DISTINCT service, service_addr
FROM auto_service;

-- 2) Заполнение таблицы работников
INSERT INTO workers (w_name, w_exp, w_phone, wages)
SELECT DISTINCT w_name, w_exp, w_phone, wages
FROM auto_service;

-- 3) Заполнение таблицы клиентов
INSERT INTO clients (name, phone, email, password)
SELECT DISTINCT name, phone, email, password
FROM auto_service;

-- 4) Заполнение таблицы автомобилей
INSERT INTO cars (car, vin, car_number, color)
SELECT DISTINCT car, vin, car_number, color
FROM auto_service;

-- 5) Заполнение таблицы заказов
INSERT INTO orders (client_id, worker_id, service_id, car_id, date, mileage, payment, card, pin)
SELECT DISTINCT
    cl.id AS client_id,
    w.id AS worker_id,
    s.id AS service_id,
    c.id AS car_id,
    as1.date,
    as1.mileage,
    as1.payment,
    as1.card,
    as1.pin
FROM auto_service as1
JOIN clients cl ON cl.name = as1.name AND cl.email = as1.email  -- Связь по имени и email
JOIN workers w ON w.w_name = as1.w_name AND w.w_phone = as1.w_phone  -- Связь по имени и телефону
JOIN services s ON s.service_name = as1.service AND s.service_addr = as1.service_addr  -- Связь по сервису и адресу
JOIN cars c ON c.vin = as1.vin;  -- Связь по VIN автомобиля

-------------------------------------------------------------------------------------------------

-- Проверка корректности данных
-- 1) Проверка количества строк в исходной таблице и таблице заказов
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM auto_service) = (SELECT COUNT(*) FROM orders) THEN
        RAISE NOTICE 'Количество строк совпадает: %', (SELECT COUNT(*) FROM orders);
    ELSE
        RAISE EXCEPTION 'Количество строк не совпадает!';
    END IF;
END $$;

-- 2) Проверка уникальности данных в таблицах
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM services) AS unique_services) = (SELECT COUNT(*) FROM services) THEN
        RAISE NOTICE 'Таблица services уникальна';
    ELSE
        RAISE EXCEPTION 'Таблица services содержит дубликаты!';
    END IF;

    IF (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM workers) AS unique_workers) = (SELECT COUNT(*) FROM workers) THEN
        RAISE NOTICE 'Таблица workers уникальна';
    ELSE
        RAISE EXCEPTION 'Таблица workers содержит дубликаты!';
    END IF;

    IF (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM clients) AS unique_clients) = (SELECT COUNT(*) FROM clients) THEN
        RAISE NOTICE 'Таблица clients уникальна';
    ELSE
        RAISE EXCEPTION 'Таблица clients содержит дубликаты!';
    END IF;

    IF (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM cars) AS unique_cars) = (SELECT COUNT(*) FROM cars) THEN
        RAISE NOTICE 'Таблица cars уникальна';
    ELSE
        RAISE EXCEPTION 'Таблица cars содержит дубликаты!';
    END IF;

    IF (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM orders) AS unique_orders) = (SELECT COUNT(*) FROM orders) THEN
        RAISE NOTICE 'Таблица orders уникальна';
    ELSE
        RAISE EXCEPTION 'Таблица orders содержит дубликаты!';
    END IF;
END $$;

-- 3) Проверка внешних ключей в таблице orders
SELECT
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    confrelid::regclass AS referenced_table,
    a.attname AS column_name,
    af.attname AS referenced_column
FROM pg_constraint
JOIN pg_attribute a ON a.attnum = ANY (conkey) AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = ANY (confkey) AND af.attrelid = confrelid
WHERE conrelid = 'orders'::regclass AND contype = 'f';

-- 4) Проверка связи между orders и clients
SELECT o.order_id, o.client_id, c.name
FROM orders o
JOIN clients c ON o.client_id = c.id
LIMIT 10;

-- 5) Проверка связи между orders и workers
SELECT o.order_id, o.worker_id, w.w_name
FROM orders o
JOIN workers w ON o.worker_id = w.id
LIMIT 10;

-- 6) Проверка связи между orders и services
SELECT o.order_id, o.service_id, s.service_name
FROM orders o
JOIN services s ON o.service_id = s.id
LIMIT 10;

-- 7) Проверка связи между orders и cars
SELECT o.order_id, o.car_id, c.car
FROM orders o
JOIN cars c ON o.car_id = c.id
LIMIT 10;

-- 8) Попытка удалить запись из таблицы clients
DELETE FROM clients WHERE id = 1;