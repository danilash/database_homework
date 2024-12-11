-- Импорт данных
-- Заменил все символы "\""  на "t" в csv файле
-- Создал таблицу "repair_service" для импорта
CREATE TABLE repair_service (
    date date,
    service text,
    service_addr text,
    w_name text,
    w_exp INT,
    w_phone text,
    wages INT,
    card text,
    payment text,
    pin text,
    name text,
    phone text,
    email text,
    password text,
    car text,
    mileage INT,
    vin text,
    car_number text,
    color text
);

-- Импорт на основе кода
COPY 
  repair_service 
FROM 
'/Users/danila/MISIS/DB/422d9dcc-1a0d-4f4e-a716-6d402e327595.csv' 
DELIMITER ',' 
CSV HEADER;

-- Проверка данных:
-- Минимальная дата и максимальная дата: 2013-01-01 и 2024-09-04
select min(date),max(date)
from repair_service  ot 
-- Количество клиентов и их обращения: 10 466 пустых, 524 клиента
select name,count(*)
from repair_service  ot 
group by "name"
order by count(*)desc 
-- Проверка на разбиение по строкам
select date, vin, mileage
from repair_service  ot 
where vin is not null and vin <> ''
order by vin, date
-- Все проверки выполнены успешно, после посещения сервиса километраж увеличивается