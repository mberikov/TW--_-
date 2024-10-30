--1) Вывести уникальные номера договоров из таблицы ТД
--2) Вывести таблицу ТД, только с оборудованием
--3) Вывести все ТД, которые входят в пакет Формат: Номер договора, Код ТД Пакета, Код ТД, Услуга
--4) Вывести всю таблицу с ТД с E-mail абонента
--5) Вывести только тех абонентов, у которых нет E-mail
--6) Вывести таблицу ТД с действующими услугами в следующем формате:Номер договора, массив из Код ТД, массив из услуг
--7) Как создаётся временная таблица
--8) Самопроизвольный код с использованием CTE на данных таблица
-- Создаём таблицы
CREATE TABLE td (
  номер_договора INT,
  код_тд INT,
  услуга VARCHAR(255),
  deleted VARCHAR(255),
  ссылка_на_пакет VARCHAR(255)
);

INSERT INTO td (номер_договора, код_тд, услуга, deleted, ссылка_на_пакет) VALUES
  (111111, 1, 'ВЛ', 'FALSE', NULL),
  (222222, 2, 'ВЛ', 'FALSE', NULL),
  (222222, 3, 'ДМФ', 'FALSE', NULL),
  (222222, 4, 'IPTV', 'FALSE', NULL),
  (222222, 5, 'IPTV', 'TRUE', NULL),
  (222222, 6, 'Видеосервис', 'TRUE', NULL),
  (222222, 7, 'Видеосервис', 'TRUE', NULL),
  (222222, 8, 'Оборудование', 'TRUE', NULL),
  (222222, 9, 'КТВ', 'FALSE', NULL),
  (222222, 10, 'Оборудование', 'TRUE', NULL),
  (222222, 11, 'Оборудование', 'TRUE', NULL),
  (333333, 12, 'ВЛ', 'FALSE', '888'),
  (333333, 888, 'Пакет', 'FALSE', NULL),
  (333333, 13, 'IPTV', 'FALSE', '888'),
  (333333, 14, 'IPTV', 'FALSE', '888'),
  (333333, 15, 'IPTV', 'FALSE', '888'),
  (333333, 16, 'IPTV', 'FALSE', '888'),
  (333333, 17, 'Оборудование', 'TRUE', NULL),
  (333333, 18, ' Оборудование', 'TRUE', NULL)

CREATE TABLE email (
 номер_договора INT, 
 E_mail VARCHAR(255)
);
INSERT INTO email (номер_договора, E_mail) VALUES
 (111111, '111111@mail.ru'),
 (33333,'33333@mail.ru');


--1)
SELECT 
  DISTINCT номер_договора 
FROM
 td;

--2) 
SELECT 
 номер_договора,
 код_тд,
 услуга,
 deleted,
 ссылка_на_пакет
FROM 
  td 
WHERE
  услуга = 'Оборудование';
--3) --  Вывести все ТД, которые входят в пакет
-- Формат: Номер договора, Код ТД Пакета, Код ТД, Услуга
SELECT 
 номер_договора,
 ссылка_на_пакет AS код_тд_пакета, 
 код_тд,
 услуга
FROM 
  td 
WHERE
  ссылка_на_пакет IS NOT NULL;
--4) 
SELECT
 td.*,
 email.E_mail
FROM 
 td
LEFT JOIN
 email ON td.номер_договора = email.номер_договора;
 --5) 
SELECT
 *
FROM 
 td
LEFT JOIN email ON td.номер_договора = email.номер_договора
WHERE
 email.E_mail IS NULL;
--6)  
SELECT 
  td.номер_договора, 
  array_agg(td.код_тд) AS код_тд, 
  array_agg(td.услуга) AS услуги
FROM 
  td 
WHERE 
  td.deleted = 'FALSE'
GROUP BY 
  td.номер_договора;
--7) Временная таблица в SQL создается с помощью ключевого слова CREATE TEMP TABLE или CREATE TEMPORARY TABLE
-- Синтаксис: CREATE TEMP TABLE имя_таблицы (
--  столбец1 тип_данных,
--  столбец2 тип_данных,
--  ...
);
-- Временные таблицы доступны только в данной сессии(после завершения сессии временные таблицы автоматически удаляются)
-- Временные таблицы могут быть созданы с помощью SELECT INTO  
-- Временные таблицы эффективны при работе с большими объёмами данных
--8) 


-- Пример CTE для выбора всех активных услуг, можно применить в 6-ом задании
WITH ActiveServices AS (
    SELECT 
        номер_договора,
        код_тд,
        услуга
    FROM 
        td
    WHERE 
        deleted = 'FALSE'
)
SELECT * 
FROM ActiveServices;


--  Пример CTE для подсчёта количества услуг по каждому номеру договора 
WITH ServiceCount AS (
    SELECT 
        номер_договора,
        COUNT(*) AS количество_услуг
    FROM 
        td
    WHERE 
        deleted = 'FALSE'
    GROUP BY 
        номер_договора
)
SELECT * 
FROM ServiceCount;


-- Пример CTE для объединения таблиц td и email, 4-ое задание
WITH ActiveContracts AS (
    SELECT 
        td.номер_договора,
        td.код_тд,
        td.услуга,
        email.E_mail
    FROM 
        td
    LEFT JOIN 
        email ON td.номер_договора = email.номер_договора
    WHERE 
        td.deleted = 'FALSE'
)
SELECT * 
FROM ActiveContracts;


-- Пример CTE 3-ое задание (вести все ТД, которые входят в пакет)
WITH PackageServices AS (
    SELECT 
        t1.номер_договора,
        t1.ссылка_на_пакет AS код_пакета,
        t1.код_тд,
        t1.услуга
    FROM 
        td t1
    JOIN 
        td t2 ON t1.ссылка_на_пакет::INT = t2.код_тд
    WHERE 
        t1.deleted = 'FALSE' AND t2.deleted = 'FALSE'
)
SELECT * 
FROM PackageServices;