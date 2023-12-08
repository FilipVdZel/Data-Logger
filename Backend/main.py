from fastapi import FastAPI

backend_app = FastAPI()

fake_items_db = [{"item_name": "Foo"}, {"item_name": "Bar"}, {"item_name": "Baz"}]

@backend_app.get("/")
async def root():
    return {"message": "Hello World"}

@backend_app.get("/items/{item_id}")
def read_item(item_id: int):
    return {"item_id": item_id}

@backend_app.get("/items/")
async def items_from_db(skip: int = 0, limit: int = 20):
    return fake_items_db[skip:limit]

