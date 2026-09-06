from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str
    jwt_secret_key: str
    jwt_expiration_minutes: int = 60
    ideam_api_key: str = ""
    entorno: str = "desarrollo"


settings = Settings()
