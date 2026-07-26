from pathlib import Path

from fastapi import FastAPI

VERSION = (Path(__file__).resolve().parent.parent / "VERSION").read_text().strip()

app = FastAPI(title="Nucleus API", version=VERSION)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "version": VERSION}
