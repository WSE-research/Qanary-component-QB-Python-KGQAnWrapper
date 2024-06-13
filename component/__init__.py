from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from component import qb_kgqan

version = "0.1.0"

configfile = "app.conf"

healthendpoint = "/health"

aboutendpoint = "/about"
app = FastAPI()
app.include_router(qb_kgqan.router)


@app.get("/")
async def main():
    return RedirectResponse("/about")


@app.get(healthendpoint, description="Shows the status of the component")
async def health():
    """required health endpoint for callback of Spring Boot Admin server"""
    return "alive"


@app.get(aboutendpoint, description="Shows a description of the component")
async def about():
    """required about endpoint for callback of Srping Boot Admin server"""
    return "Answers questions using KGQAn"# TODO: replace this with a service description from configuration
    #return os.environ['SERVICE_DESCRIPTION_COMPONENT'] 
