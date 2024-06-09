FROM python:3.12

COPY requirements.txt ./

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip install gunicorn

COPY component component
COPY run.py boot.sh  ./

RUN chmod +x boot.sh

ENTRYPOINT ["./boot.sh"]
