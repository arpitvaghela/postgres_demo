```sh
          $ psql # will fail as the user is not created

# create new database
          $ sudo su postgres; # change user to postgres
(postgres)$ psql # connect to sql
postgres=#  \du # list users
postgres=#  SELECT * FROM pg_catalog.pg_users;
postgres=#  \l # list databases
postgres=#  CREATE DATABASE test;
postgres=#  \l # list databases
postgres=#  exit
(postgres)$ exit

# create new user with createdb and superuser role privileges 
          $ sudo -u postgres createuser --createdb --superuser -P arpit

# grant privileges to new user
          $ sudo su postgres;
(postgres)$ psql
postgres=#  \du
postgres=#  \l
postgres=#  GRANT ALL PRIVILEGES ON DATABASE test TO arpit;
postgres=#  \l # check updated privileges on database
postgres=#  exit
(postgres)$ exit

# connect to test database
          $ psql -d test -U arpit -W 
test=#      \d
test=#      exit

# create database tables and triggers 
          $ psql -d test -U arpit -W -f createdb.sql

# connect to test database
          $ psql -d test -U arpit -W
test=#      \d
test=#      SELECT * FROM mystatement;

# test triggers
test=#      INSERT INTO mystatement (transaction_type, amount, balance, transaction_time) VALUES ('deposit', 100, 500, NOW());
test=#      SELECT * FROM mystatement;
test=#      INSERT INTO purchase (purchase, cost, purchase_time) VALUES ('apple_bill',1.10, NOW());
            INSERT INTO purchase (purchase, cost, purchase_time) VALUES ('coffee',3.50, NOW());
            INSERT INTO purchase (purchase, cost, purchase_time) VALUES ('coffee',3.50, NOW());
            INSERT INTO purchase (purchase, cost, purchase_time) VALUES ('redbull',3.50, NOW());
            INSERT INTO purchase (purchase, cost, purchase_time) VALUES ('coffee',3.50, NOW());
            INSERT INTO purchase (purchase, cost, purchase_time) VALUES ('pizza',12.12, NOW());
            INSERT INTO purchase (purchase, cost, purchase_time) VALUES ('lunch',10.12, NOW());
            INSERT INTO purchase (purchase, cost, purchase_time) VALUES ('fare',2.00, NOW());

test=#      INSERT INTO purchase (purchase, cost, purchase_time) VALUES ('chips', 2, NOW());
test=#      SELECT * FROM purchase;
test=#      SELECT * FROM mystatement;
test=#      INSERT INTO purchase (purchase, cost, purchase_time) VALUES ('iphone', 999.9, NOW());
test=#      SELECT * FROM purchase;
test=#      SELECT * FROM mystatement;

# export data to csv files
test=#      \copy purchase TO ./purchase.csv DELIMITER ',' CSV HEADER;
test=#      \copy mystatement TO ./mystatemet.csv DELIMITER ',' CSV HEADER;

```

[psycopg](https://www.psycopg.org/)

```sh
pip install --upgrade pip
pip install "psycopg[binary,pool]" fastapi python-decouple

uvicorn main:app --reload
```

Open (http://127.0.0.1:8000/docs)[http://127.0.0.1:8000/docs]

