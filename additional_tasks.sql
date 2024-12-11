-- Дополнительные задания
-- 1)Создать таблицу скидок и дать скидку самым частым клиентам

-- Создание таблицы discounts
CREATE TABLE discounts (
    discount_id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(id),  -- Внешний ключ для связи с клиентами
    discount_percent INT NOT NULL         -- Процент скидки
);

-- Определение самых частых клиентов
WITH TopClients AS (
    SELECT 
        client_id,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY client_id
    ORDER BY order_count DESC
    LIMIT 10  -- Выбираем топ-10 клиентов
)
-- Добавление скидок в таблицу discounts
INSERT INTO discounts (client_id, discount_percent)
SELECT 
    client_id,
    10  -- Скидка 10%
FROM TopClients;

-- Проверка таблицы discounts
SELECT 
    d.discount_id,
    c.name AS client_name,
    d.discount_percent
FROM discounts d
JOIN clients c ON d.client_id = c.id;

-- 2)Поднять зарплату трём самым результативным механикам на 10%
-- Определение трёх самых результативных механиков
WITH TopWorkers AS (
    SELECT 
        worker_id,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY worker_id
    ORDER BY order_count DESC
    LIMIT 3
)
-- Обновление зарплаты
UPDATE workers
SET wages = wages * 1.1  -- Увеличение зарплаты на 10%
WHERE id IN (SELECT worker_id FROM TopWorkers);

-- Проверка обновления зарплаты
SELECT 
    w.id,
    w.w_name,
    w.wages AS new_wages
FROM workers w
JOIN (
    SELECT worker_id
    FROM orders
    GROUP BY worker_id
    ORDER BY COUNT(*) DESC
    LIMIT 3
) AS top_workers ON w.id = top_workers.worker_id;

-- 3)Сделать представление для директора: филиал, количество заказов за последний месяц, заработанная сумма, заработанная сумма за вычетом зарплаты
-- Создание представления director_report
CREATE VIEW director_report AS
SELECT 
    s.service_name AS branch,
    COUNT(o.order_id) AS order_count,
    SUM(o.payment::NUMERIC) AS total_income,  -- Общая сумма заказов
    SUM(w.wages) AS total_wages,             -- Общая зарплата работников
    SUM(o.payment::NUMERIC) - SUM(w.wages) AS profit  -- Прибыль
FROM orders o
JOIN services s ON o.service_id = s.id
JOIN workers w ON o.worker_id = w.id
WHERE o.date >= CURRENT_DATE - INTERVAL '4 month'  -- За последний месяц, но выводим за последние 4 месяца, так как за последний заказ был в сентябре
GROUP BY s.service_name;

-- Проверка представления director_report
SELECT * FROM director_report;

-- 4)Сделать рейтинг самых надежных и ненадежных авто
-- Рейтинг надежных автомобилей
WITH CarRanking AS (
    SELECT 
        c.car,
        COUNT(o.order_id) AS order_count
    FROM orders o
    JOIN cars c ON o.car_id = c.id
    GROUP BY c.car
)
-- Сортировка по надежности
SELECT 
    car,
    order_count,
    CASE 
        WHEN order_count >= (SELECT PERCENTILE_CONT(0.51) WITHIN GROUP (ORDER BY order_count) FROM CarRanking) THEN 'Ненадежный'
        WHEN order_count <= (SELECT PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY order_count) FROM CarRanking) THEN 'Надежный'
    END AS reliability
FROM CarRanking
ORDER BY order_count ASC;

-- 5) Самый "удачный" цвет для каждой модели авто
-- Выбор цвета с минимальным количеством обращений для каждой марки автомобиля
WITH ColorRanking AS (
    SELECT 
        c.car,
        c.color,
        COUNT(*) AS order_count
    FROM orders o
    JOIN cars c ON o.car_id = c.id
    GROUP BY c.car, c.color
),
MinOrderCount AS (
    SELECT 
        car,
        MIN(order_count) AS min_order_count
    FROM ColorRanking
    GROUP BY car
)
-- Выбор цвета с минимальным количеством обращений
SELECT 
    cr.car,
    cr.color,
    cr.order_count
FROM ColorRanking cr
JOIN MinOrderCount moc ON cr.car = moc.car AND cr.order_count = moc.min_order_count
ORDER BY cr.car;