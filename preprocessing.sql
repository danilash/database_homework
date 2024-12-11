-- Предобработка таблицы
-- 1) Создание таблицы с добавлением уникального идентификатора
CREATE TABLE auto_service (
    id SERIAL PRIMARY KEY,
    date DATE,
    service TEXT,
    service_addr TEXT,
    w_name TEXT,
    w_exp INT,
    w_phone TEXT,
    wages INT,
    card TEXT,
    payment TEXT,
    pin TEXT,
    name TEXT,
    phone TEXT,
    email TEXT,
    password TEXT,
    car TEXT,
    mileage INT,
    vin TEXT,
    car_number TEXT,
    color TEXT
);

-- 2) Вставка данных из старой таблицы с удалением дубликатов
-- Используем ROW_NUMBER для генерации уникального ID и DISTINCT для удаления дубликатов
INSERT INTO auto_service (id, date, service, service_addr, w_name, w_exp, w_phone, wages, card, payment, pin, name, phone, email, password, car, mileage, vin, car_number, color)
SELECT 
    ROW_NUMBER() OVER (ORDER BY date) AS id,  -- Генерация уникального ID
    date, service, service_addr, w_name, w_exp, w_phone, wages, card, payment, pin, name, phone, email, password, car,
    mileage, vin, car_number, color
FROM (
    SELECT DISTINCT 
        date, service, service_addr, w_name, w_exp, w_phone, wages, card, payment, pin, name, phone, email,
        password, car, mileage, vin, car_number, color  -- Удаление дубликатов
    FROM repair_service
	) 
ORDER BY date;

-- 3) Проверка пустых значений
-- Подсчет количества NULL в каждом столбце
SELECT 
    COUNT(CASE WHEN date IS NULL THEN 1 END) AS null_date_count,
    COUNT(CASE WHEN service IS NULL THEN 1 END) AS null_service_count,
    COUNT(CASE WHEN service_addr IS NULL THEN 1 END) AS null_service_addr_count,
    COUNT(CASE WHEN w_name IS NULL THEN 1 END) AS null_w_name_count,
    COUNT(CASE WHEN w_exp IS NULL THEN 1 END) AS null_w_exp_count,
    COUNT(CASE WHEN w_phone IS NULL THEN 1 END) AS null_w_phone_count,
    COUNT(CASE WHEN wages IS NULL THEN 1 END) AS null_wages_count,
    COUNT(CASE WHEN card IS NULL THEN 1 END) AS null_card_count,
    COUNT(CASE WHEN payment IS NULL THEN 1 END) AS null_payment_count,
    COUNT(CASE WHEN pin IS NULL THEN 1 END) AS null_pin_count,
    COUNT(CASE WHEN name IS NULL THEN 1 END) AS null_name_count,
    COUNT(CASE WHEN phone IS NULL THEN 1 END) AS null_phone_count,
    COUNT(CASE WHEN email IS NULL THEN 1 END) AS null_email_count,
    COUNT(CASE WHEN password IS NULL THEN 1 END) AS null_password_count,
    COUNT(CASE WHEN car IS NULL THEN 1 END) AS null_car_count,
    COUNT(CASE WHEN mileage IS NULL THEN 1 END) AS null_mileage_count,
    COUNT(CASE WHEN vin IS NULL THEN 1 END) AS null_vin_count,
    COUNT(CASE WHEN car_number IS NULL THEN 1 END) AS null_car_number_count,
    COUNT(CASE WHEN color IS NULL THEN 1 END) AS null_color_count
FROM auto_service;

-------------------------------------------------------------------------------------------------

-- Заполнение данных
-- 1) Заполнение service на основе w_name
UPDATE auto_service as1
SET service = rs.service
FROM repair_service rs
WHERE as1.w_name = rs.w_name AND as1.service IS NULL AND rs.service IS NOT NULL;

-- 2) Заполнение service_addr на основе w_name
UPDATE auto_service as1
SET service_addr = rs.service_addr
FROM repair_service rs
WHERE as1.w_name = rs.w_name AND as1.service_addr IS NULL AND rs.service_addr IS NOT NULL;

-- 3) Заполнение w_name на основе w_phone
UPDATE auto_service as1
SET w_name = rs.w_name
FROM repair_service rs
WHERE as1.w_phone = rs.w_phone AND as1.w_name IS NULL AND rs.w_name IS NOT NULL;
-- Проверка
SELECT
	COUNT(CASE WHEN w_name IS NULL THEN 1 END) AS null_w_name_count
FROM auto_service;

-- 4) Заполнение service_addr на основе w_name еще раз
UPDATE auto_service as1
SET service_addr = rs.service_addr
FROM repair_service rs
WHERE as1.w_name = rs.w_name AND as1.service_addr IS NULL AND rs.service_addr IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN service_addr IS NULL THEN 1 END) AS null_service_addr_count
FROM auto_service;

-- 5) Заполнение service на основе w_name
UPDATE auto_service as1
SET service = rs.service
FROM repair_service rs
WHERE as1.w_name = rs.w_name AND as1.service IS NULL AND rs.service IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN service IS NULL THEN 1 END) AS null_service_count
FROM auto_service;

-- 6) Заполнение w_exp на основе w_name
UPDATE auto_service as1
SET w_exp = rs.w_exp
FROM repair_service rs
WHERE as1.w_name = rs.w_name AND as1.w_exp IS NULL AND rs.w_exp IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN w_exp IS NULL THEN 1 END) AS null_w_exp_count
FROM auto_service;

-- 7) Заполнение w_phone на основе w_name
UPDATE auto_service as1
SET w_phone = rs.w_phone
FROM repair_service rs
WHERE as1.w_name = rs.w_name AND as1.w_phone IS NULL AND rs.w_phone IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN w_phone IS NULL THEN 1 END) AS null_w_phone_count
FROM auto_service;

-- 8) Заполнение wages на основе w_name
UPDATE auto_service as1
SET wages = rs.wages
FROM repair_service rs
WHERE as1.w_name = rs.w_name AND as1.wages IS NULL AND rs.wages IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN wages IS NULL THEN 1 END) AS null_wages_count
FROM auto_service;

-- 9) Заполнение email на основе name
UPDATE auto_service as1
SET email = rs.email
FROM repair_service rs
WHERE as1.name = rs.name AND as1.email IS NULL AND rs.email IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN email IS NULL THEN 1 END) AS null_email_count
FROM auto_service;

-- 10) Заполнение phone на основе name
UPDATE auto_service as1
SET phone = rs.phone
FROM repair_service rs
WHERE as1.name = rs.name AND as1.phone IS NULL AND rs.phone IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN phone IS NULL THEN 1 END) AS null_phone_count
FROM auto_service;

-- 11) Заполнение name на основе email и phone
UPDATE auto_service as1
SET name = rs.name
FROM repair_service rs
WHERE as1.email = rs.email AND as1.phone = rs.phone AND as1.name IS NULL AND rs.name IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN name IS NULL THEN 1 END) AS null_name_count
FROM auto_service;

-- 12) Заполнение password на основе name
UPDATE auto_service as1
SET password = rs.password
FROM repair_service rs
WHERE as1.name = rs.name AND as1.password IS NULL AND rs.password IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN password IS NULL THEN 1 END) AS null_password_count
FROM auto_service;

-- 13) Заполнение car на основе name
UPDATE auto_service as1
SET car = rs.car
FROM repair_service rs
WHERE as1.name = rs.name AND as1.car IS NULL AND rs.car IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN car IS NULL THEN 1 END) AS null_car_count
FROM auto_service;

-- 14) Заполнение vin на основе car_number
UPDATE auto_service as1
SET vin = rs.vin
FROM repair_service rs
WHERE as1.car_number = rs.car_number AND as1.vin IS NULL AND rs.vin IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN vin IS NULL THEN 1 END) AS null_vin_count
FROM auto_service;

-- 15) Заполнение car_number на основе vin
UPDATE auto_service as1
SET car_number = rs.car_number
FROM repair_service rs
WHERE as1.vin = rs.vin AND as1.car_number IS NULL AND rs.car_number IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN car_number IS NULL THEN 1 END) AS null_car_number_count
FROM auto_service;

-- 16) Заполнение color на основе car_number
UPDATE auto_service as1
SET color = rs.color
FROM repair_service rs
WHERE as1.car_number = rs.car_number AND as1.color IS NULL AND rs.color IS NOT NULL;
-- Проверка
SELECT
    COUNT(CASE WHEN color IS NULL THEN 1 END) AS null_color_count
FROM auto_service;

-- 17) Восстановление mileage на основе vin и даты
WITH MileageScore AS (
    SELECT 
        id, vin, date, mileage,
        LAG(mileage, 1, NULL) OVER (PARTITION BY vin ORDER BY date) AS prev_mileage,
        LEAD(mileage, 1, NULL) OVER (PARTITION BY vin ORDER BY date) AS next_mileage
    FROM auto_service
),
UpdateMileage AS (
    SELECT 
        id,
        CASE 
            WHEN mileage IS NULL AND prev_mileage IS NOT NULL THEN prev_mileage
            WHEN mileage IS NULL AND next_mileage IS NOT NULL THEN next_mileage
            ELSE mileage
        END AS new_mileage
    FROM MileageScore
)
UPDATE auto_service
SET mileage = UpdateMileage.new_mileage
FROM UpdateMileage
WHERE auto_service.id = UpdateMileage.id;
-- Проверка
SELECT
    COUNT(CASE WHEN mileage IS NULL THEN 1 END) AS null_mileage_count
FROM auto_service;

-- Финансовые данные полностью восставноить не удастся, потому что они не имеют зависимостей. Номера карт одного человека(card) всегда изменяются, также как и pin, а payment восстановить невозможно, так как номера чеков всегда различны и идут неупорядоченно.