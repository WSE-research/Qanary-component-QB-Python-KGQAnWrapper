import logging
import os
from datetime import datetime
from qanary_helpers.registration import Registration
from qanary_helpers.registrator import Registrator

from component import app, healthendpoint, aboutendpoint

logging.basicConfig(level=logging.ERROR)
# TODO: get logger from module
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

SPRING_BOOT_ADMIN_URL = os.getenv('SPRING_BOOT_ADMIN_URL')
SPRING_BOOT_ADMIN_USERNAME = os.getenv('SPRING_BOOT_ADMIN_USERNAME')
SPRING_BOOT_ADMIN_PASSWORD = os.getenv('SPRING_BOOT_ADMIN_PASSWORD')
SERVICE_HOST = os.getenv('SERVER_HOST')
SERVICE_PORT = os.getenv('SERVER_PORT')
SERVICE_NAME_COMPONENT = os.getenv('SERVICE_NAME_COMPONENT')
SERVICE_DESCRIPTION_COMPONENT = os.getenv('SERVICE_DESCRIPTION_COMPONENT')
URL_COMPONENT = f"{SERVICE_HOST}:{SERVICE_PORT}"

# define metadata that will be shown in the Spring Boot Admin server UI
metadata = {
    "start": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    "description": SERVICE_DESCRIPTION_COMPONENT,
    "about": f"{SERVICE_HOST}:{SERVICE_PORT}{aboutendpoint}",
    "written in": "Python"
}

# initialize the registration object, to be send to the Spring Boot Admin server
registration = Registration(
    name=SERVICE_NAME_COMPONENT,
    serviceUrl=f"{SERVICE_HOST}:{SERVICE_PORT}",
    healthUrl=f"{SERVICE_HOST}:{SERVICE_PORT}{healthendpoint}",
    metadata=metadata
)

logger.info(f"Start registration on: {SPRING_BOOT_ADMIN_URL} with the credentials: {SPRING_BOOT_ADMIN_USERNAME}/{SPRING_BOOT_ADMIN_PASSWORD}")

# start a thread that will contact iteratively the Spring Boot Admin server
registrator_thread = Registrator(
    SPRING_BOOT_ADMIN_URL,
    SPRING_BOOT_ADMIN_USERNAME,
    SPRING_BOOT_ADMIN_PASSWORD,
    registration
)
registrator_thread.setDaemon(True)
registrator_thread.start()

if __name__ == "__main__":
    # start the web service
    if SERVICE_PORT == None:
        raise RuntimeError("SERVICE_PORT must not be empty!")
