from fastapi import FastAPI
from psycopg_pool import ConnectionPool
import psycopg

from pydantic import BaseModel
from decouple import config

class Purchase(BaseModel):
    name: str
    cost: float

def get_conn_str():
    return f"""
    dbname={config('POSTGRES_DB')}
    user={config('POSTGRES_USER')}
    password={config('POSTGRES_PASSWORD')}
    """
    # host={os.getenv('POSTGRES_HOST', default="localhost")}
    # port={os.getenv('POSTGRES_PORT', default=5432)}

app = FastAPI()

pool = ConnectionPool(conninfo=get_conn_str(), open=False)

@app.on_event("startup")
def open_pool():
    pool.open()

@app.on_event("shutdown")
def close_pool():
    pool.close()

@app.get("/")
def read_root():
    return "Hello World"

@app.get("/balance/")
def get_balance():
    with pool.connection() as conn:
        balance = conn.execute("SELECT balance FROM mystatement ORDER BY transaction_time DESC LIMIT 1;").fetchone()[0]
    return f"Your current balance is {balance}"


@app.post("/purchase/")
def create_purchase(purchase: Purchase):
    with pool.connection() as conn:
        try:
            conn.execute("INSERT INTO purchase (purchase, cost, purchase_time) VALUES (%s, %s, NOW());", (purchase.name,purchase.cost) )
            (idx, t_type, amount, balance, timestamp) = conn.execute("SELECT * FROM mystatement ORDER BY transaction_time DESC LIMIT 1;").fetchone()
            return {"Success": f"{t_type} {amount} at {timestamp.strftime('%m/%d/%Y %H:%M:%S')} => New balance {balance}"}

        except psycopg.errors.RaiseException as e:
            conn.rollback()
            (idx, t_type, amount, balance, timestamp) = conn.execute("SELECT * FROM mystatement ORDER BY transaction_time DESC LIMIT 1;").fetchone()
            return {"Error", f"Insufficent Balance for purchase of {purchase.cost} Current Balance => {balance}"}
