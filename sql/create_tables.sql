--
-- The contents of this file were copied from another repo
--   https://github.com/jdaarevalo/docker_postgres_with_data
--
CREATE SCHEMA mydata;

CREATE TABLE IF NOT EXISTS mydata.product (
  product_id INT NOT NULL,
  name varchar(250) NOT NULL,
  PRIMARY KEY (product_id)
);

CREATE TABLE IF NOT EXISTS mydata.country (
  country_id INT NOT NULL,
  country_name varchar(450) NOT NULL,
  PRIMARY KEY (country_id)
);

CREATE TABLE IF NOT EXISTS mydata.city (
  city_id INT NOT NULL,
  city_name varchar(450) NOT NULL,
  country_id INT NOT NULL,
  PRIMARY KEY (city_id),
  CONSTRAINT fk_country
      FOREIGN KEY(country_id)
	  REFERENCES mydata.country(country_id)
);

CREATE TABLE IF NOT EXISTS mydata.store (
  store_id INT NOT NULL,
  name varchar(250) NOT NULL,
  city_id INT NOT NULL,
  PRIMARY KEY (store_id),
  CONSTRAINT fk_city
      FOREIGN KEY(city_id)
	  REFERENCES mydata.city(city_id)
);

CREATE TABLE IF NOT EXISTS mydata.users (
  user_id INT NOT NULL,
  name varchar(250) NOT NULL,
  PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS mydata.status_name (
  status_name_id INT NOT NULL,
  status_name varchar(450) NOT NULL,
  PRIMARY KEY (status_name_id)
);

CREATE TABLE IF NOT EXISTS mydata.sale (
  sale_id varchar(200) NOT NULL,
  amount DECIMAL(20,3) NOT NULL,
  date_sale TIMESTAMP,
  product_id INT NOT NULL,
  user_id INT NOT NULL,
  store_id INT NOT NULL,
  PRIMARY KEY (sale_id),
  CONSTRAINT fk_product
      FOREIGN KEY(product_id)
	  REFERENCES mydata.product(product_id),
  CONSTRAINT fk_user
      FOREIGN KEY(user_id)
	  REFERENCES mydata.users(user_id),
  CONSTRAINT fk_store
      FOREIGN KEY(store_id)
	  REFERENCES mydata.store(store_id)
);

CREATE TABLE IF NOT EXISTS mydata.order_status (
  order_status_id varchar(200) NOT NULL,
  update_at TIMESTAMP,
  sale_id varchar(200) NOT NULL,
  status_name_id INT NOT NULL,
  PRIMARY KEY (order_status_id),
  CONSTRAINT fk_sale
      FOREIGN KEY(sale_id)
	  REFERENCES mydata.sale(sale_id),
  CONSTRAINT fk_status_name
      FOREIGN KEY(status_name_id)
	  REFERENCES mydata.status_name(status_name_id)
);


-----

set session my.number_of_sales = '100';
set session my.number_of_users = '100';
set session my.number_of_products = '100';
set session my.number_of_stores = '100';
set session my.number_of_coutries = '100';
set session my.number_of_cities = '30';
set session my.status_names = '5';
set session my.start_date = '2019-01-01 00:00:00';
set session my.end_date = '2020-02-01 00:00:00';

-- load the pgcrypto extension to gen_random_uuid ()

CREATE EXTENSION pgcrypto;

-- Filling of products
INSERT INTO mydata.product
select id, concat('Product ', id)
FROM GENERATE_SERIES(1, current_setting('my.number_of_products')::int) as id;

-- Filling of countries
INSERT INTO mydata.country
select id, concat('Country ', id)
FROM GENERATE_SERIES(1, current_setting('my.number_of_coutries')::int) as id;

INSERT INTO mydata.city
select id
	, concat('City ', id)
	, floor(random() * (current_setting('my.number_of_coutries')::int) + 1)::int
FROM GENERATE_SERIES(1, current_setting('my.number_of_cities')::int) as id;

INSERT INTO mydata.store
select id
	, concat('Store ', id)
	, floor(random() * (current_setting('my.number_of_cities')::int) + 1)::int
FROM GENERATE_SERIES(1, current_setting('my.number_of_stores')::int) as id;

INSERT INTO mydata.users
select id
	, concat('User ', id)
FROM GENERATE_SERIES(1, current_setting('my.number_of_users')::int) as id;

INSERT INTO mydata.status_name
select status_name_id
	, concat('Status Name ', status_name_id)
FROM GENERATE_SERIES(1, current_setting('my.status_names')::int) as status_name_id;

INSERT INTO mydata.sale
select gen_random_uuid ()
	, round(CAST(float8 (random() * 10000) as numeric), 3)
	, TO_TIMESTAMP(start_date, 'YYYY-MM-DD HH24:MI:SS') +
		random()* (TO_TIMESTAMP(end_date, 'YYYY-MM-DD HH24:MI:SS')
							- TO_TIMESTAMP(start_date, 'YYYY-MM-DD HH24:MI:SS'))
	, floor(random() * (current_setting('my.number_of_products')::int) + 1)::int
	, floor(random() * (current_setting('my.number_of_users')::int) + 1)::int
	, floor(random() * (current_setting('my.number_of_stores')::int) + 1)::int
FROM GENERATE_SERIES(1, current_setting('my.number_of_sales')::int) as id
	, current_setting('my.start_date') as start_date
	, current_setting('my.end_date') as end_date;

INSERT INTO mydata.order_status
select gen_random_uuid ()
	, date_sale + random()* (date_sale + '5 days' - date_sale)
	, sale_id
	, floor(random() * (current_setting('my.status_names')::int) + 1)::int
from mydata.sale;


