# KGQAn needs allennlp 2.10 (torch < 1.13: no wheels after Python 3.10) and tensorflow 2.16
# (Python <= 3.12); the image stays on 3.10, see the ignore rule in .github/dependabot.yml
FROM python:3.10

COPY requirements.txt ./

ADD KGQAn/word_embedding ./KGQAn/word_embedding
ADD KGQAn/src ./KGQAn/src

ADD KGQAn/requirements.txt ./KGQAn/requirements.txt
RUN pip install -r KGQAn/requirements.txt

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

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
