with city as (
  select
    city_id, city_name, country_id
  from
    my_data.mydata.city
),

select * from city
