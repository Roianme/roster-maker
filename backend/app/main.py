from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api.roster import router as roster_router

app = FastAPI(
    title="Roster Maker API",
    description="Restaurant roster generation API using OR-Tools CP-SAT solver",
    version="0.1.0",
)

# CORS configuration for Flutter web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict to specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(roster_router)


@app.get("/")
async def root():
    return {
        "message": "Roster Maker API",
        "version": "0.1.0",
        "docs": "/docs",
    }


@app.get("/health")
async def health():
    return {"status": "healthy"}
