FROM python:3.10

COPY requirements.txt ./

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip install gunicorn

ADD KGQAn/word_embedding ./KGQAn/word_embedding
ADD KGQAn/src ./KGQAn/src

ADD KGQAn/requirements.txt ./KGQAn/requirements.txt
RUN pip install -r KGQAn/requirements.txt

COPY component component
COPY run.py boot.sh start_kgqan_services.sh ./

RUN chmod +x boot.sh
RUN chmod +x start_kgqan_services.sh

# to allow preconfigured images
ARG KGQAN_KNOWLEDGEGRAPH
ARG KNOWLEDGE_GRAPH_NAMES
ARG DBPEDIA_URI
ARG WIKIDATA_URI

ENV KGQAN_KNOWLEDGEGRAPH=$KGQAN_KNOWLEDGEGRAPH
ENV KNOWLEDGE_GRAPH_NAMES=$KNOWLEDGE_GRAPH_NAMES
ENV DBPEDIA_URI=$DBPEDIA_URI
ENV WIKIDATA_URI=$WIKIDATA_URI

ENTRYPOINT ["./start_kgqan_services.sh"]
CMD ["./boot.sh"]
