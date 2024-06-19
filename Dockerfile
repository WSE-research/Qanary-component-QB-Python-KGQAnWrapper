FROM python:3.10

COPY requirements.txt ./

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip install gunicorn

ADD KGQAn/word_embedding ./KGQAn/word_embedding
ADD KGQAn/src ./KGQAn/src
ADD KGQAn/docker-compose-qanary.yml ./docker-compose.yml

ADD KGQAn/requirements.txt ./KGQAn/requirements.txt
RUN pip install -r KGQAn/requirements.txt

COPY component component
COPY run.py boot.sh start_kgqan_services.sh ./

RUN chmod +x boot.sh
RUN chmod +x start_kgqan_services.sh

ENTRYPOINT ["./start_kgqan_services.sh"]
CMD ["./boot.sh"]
