from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.orm import RegistroIngestion
from app.schemas import RegistroIngestionOut
from app.security import require_role

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/ingestion", response_model=list[RegistroIngestionOut], dependencies=[Depends(require_role("admin"))])
def estado_ingestion(limite: int = 50, db: Session = Depends(get_db)):
    return (
        db.query(RegistroIngestion)
        .order_by(RegistroIngestion.ejecutado_en.desc())
        .limit(limite)
        .all()
    )
