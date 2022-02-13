with country as (
  select
    country_id, country_name
  from
    my_data.mydata.country
),

select * from country
