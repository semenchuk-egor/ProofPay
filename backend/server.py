from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.api import attestation, users, payments, staking, governance, analytics, health

app = FastAPI(title="ProofPay API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(attestation.router)
app.include_router(users.router)
app.include_router(payments.router)
app.include_router(staking.router)
app.include_router(governance.router)
app.include_router(analytics.router)

@app.get("/")
async def root():
    return {"message": "ProofPay API", "version": "1.0.0"}
