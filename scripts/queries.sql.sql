USE CUR


ALTER TABLE objects ADD CONSTRAINT PK_objects PRIMARY KEY (id);
ALTER TABLE funding_rounds ADD CONSTRAINT PK_funding_rounds PRIMARY KEY (id);
ALTER TABLE investments ADD CONSTRAINT PK_investments PRIMARY KEY (id);
ALTER TABLE acquisitions ADD CONSTRAINT PK_acquisitions PRIMARY KEY (id);
ALTER TABLE ipos ADD CONSTRAINT PK_ipos PRIMARY KEY (id);

ALTER TABLE funding_rounds
ADD CONSTRAINT FK_funding_object
FOREIGN KEY (object_id) REFERENCES objects(id);

ALTER TABLE investments
ADD CONSTRAINT FK_inv_funding_round
FOREIGN KEY (funding_round_id) REFERENCES funding_rounds(id);

ALTER TABLE investments
ADD CONSTRAINT FK_inv_funded_object
FOREIGN KEY (funded_object_id) REFERENCES objects(id);

ALTER TABLE investments
ADD CONSTRAINT FK_inv_investor_object
FOREIGN KEY (investor_object_id) REFERENCES objects(id);

ALTER TABLE acquisitions
ADD CONSTRAINT FK_acq_acquired
FOREIGN KEY (acquired_object_id) REFERENCES objects(id);

ALTER TABLE ipos
ADD CONSTRAINT FK_ipo_object
FOREIGN KEY (object_id) REFERENCES objects(id);



-- 1. Kategoriye göre toplam yatýrým
SELECT category_code, COUNT(*) AS num_companies, SUM(funding_total_usd) AS total_funding
FROM objects
WHERE entity_type = 'Company'
GROUP BY category_code
ORDER BY total_funding DESC;

-- 2. Yýllara göre yatýrým hacmi (log-IQR aykýrý deðerleri hariç)
SELECT YEAR(funded_at) AS year,
       COUNT(*) AS num_rounds,
       SUM(raised_amount_usd) AS total_volume
FROM funding_rounds
WHERE is_outlier_log = 0 AND is_invalid_amount = 0
GROUP BY YEAR(funded_at)
ORDER BY year;

-- 3. En aktif yatýrýmcýlar
SELECT investor_object_id, COUNT(DISTINCT funded_object_id) AS num_companies_invested
FROM investments
GROUP BY investor_object_id
ORDER BY num_companies_invested DESC;

-- 4. Exit'e giden þirketler ve satýn alma tutarlarý
SELECT o.name, o.funding_total_usd, a.price_amount, a.acquired_at
FROM acquisitions a
JOIN objects o ON a.acquired_object_id = o.id
ORDER BY a.price_amount DESC;

-- 5. Ýki yöntemin farklý yakaladýðý satýrlar (metodoloji karþýlaþtýrmasý)
SELECT object_id, raised_amount_usd, funding_round_type, funded_at
FROM funding_rounds
WHERE is_outlier = 0 AND is_outlier_log = 1
ORDER BY raised_amount_usd ASC;