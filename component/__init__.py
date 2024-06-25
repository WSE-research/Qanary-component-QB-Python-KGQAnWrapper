from fastapi import FastAPI
from fastapi.responses import RedirectResponse, Response
from component import qb_kgqan

version = "0.1.1"

configfile = "app.conf"

healthendpoint = "/health"

aboutendpoint = "/about"
app = FastAPI(docs_url="/swagger-ui.html")
app.include_router(qb_kgqan.router)

@app.get("/")
async def main():
    return RedirectResponse("/about")


@app.get(healthendpoint, description="Shows the status of the component")
async def health():
    """required health endpoint for callback of Spring Boot Admin server"""
    return Response("alive", media_type="text/plain")


@app.get(aboutendpoint, description="Shows a description of the component")
async def about():
    """required about endpoint for callback of Srping Boot Admin server"""
    return Response("Answers questions using KGQAn", media_type="text/plain") # TODO: replace this with a service description from configuration
    #return os.environ['SERVICE_DESCRIPTION_COMPONENT'] 

