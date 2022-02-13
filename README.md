Testing DBT and Postgres
================================================

[dbt](https://docs.getdbt.com/) is a tool that is used by our data group and one
that looks very interesting, in this project I will spend just a bit of time to
try the tool out in a local environment against a postgres database.

At the time of this project `dbt` could be installed using `pip` which it what
I did, although it was through environment creation using conda. I would like to
try with docker using the official images at a future point. **NOTE:** I am using
docker to run the postgres instance.

*This repo was created while going through the dbt-cli tutorial @
https://docs.getdbt.com/tutorial/create-a-project-dbt-cli*

## 1 - Initialize

First thing is to install `dbt` using `pip`:
```pip install dbt-postgres```

Next is to initialize the project as `dbt` with `init`:
```dbt init my-data```

We then need to add a profile to `.dbt/profiles.yml` that has the information that
we need to connect to our postgres instance.

Because of the way `dbt` runs it tries to find the profile in `~/.dbt` so in our case
we will need to target the specific directory by running `dbt` this way.
```dbt --profiles-dir .dbt ...```

## 2 - Models

To work with `dbt` we need to define our models including the location that the
data is being pulled from.  In this example we are going to replicate the notion
of the postgres tables exactly as they are found. This is accomplished by creating
`.sql` files in the `models` directory. For example, here is the contents of the
`product` model.

```
with product as (
  select
    product_id, name
  from
    my_data.mydata.product
),

select * from product
```

The other part to working with a model is to define tests that can be used to verify
that the data is correct.  This is accomplished in one way by creating a `schema.yml`
file in the `models` directory and filling it with the models and tests to run for those
given models. Here is an example of the entry for product that would test some basic
details.

```
version: 2

models:
  - name: product
    description: "The product in mydata"
    columns:
      - name: product_id
        description: "The primary key for table"
        tests:
          - unique
          - not_null
```

## 3 - Running tests

When these files created, we can now run tests and verify. For our solution you will first
want to make sure the database is up and running:
```docker-compose up```

The next step is to tell `dbt` to use our local profile and connect to the database
```dbt --profiles-dir .dbt test```

With that complete we are ready to commit our code change.

