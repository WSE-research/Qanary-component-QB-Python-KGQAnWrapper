import requests
import re
import logging
import os
from qanary_helpers.qanary_queries import get_text_question_in_graph, insert_into_triplestore
from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse

# TODO: get logger from module
c_handler = logging.StreamHandler()
c_handler.setLevel(logging.INFO)
c_formatter = logging.Formatter('%(asctime)s - %(name)s - [%(levelname)s] %(message)s')
c_handler.setFormatter(c_formatter)

logger = logging.getLogger(__name__)
logger.addHandler(c_handler)

router = APIRouter()

SERVICE_NAME_COMPONENT = os.environ["SERVICE_NAME_COMPONENT"]
KGQAN_ENDPOINT = os.environ["KGQAN_ENDPOINT"]
KGQAN_KNOWLEDGEGRAPH = os.environ["KGQAN_KNOWLEDGEGRAPH"]
KGQAN_MAX_ANSWERS = int(os.environ["KGQAN_MAX_ANSWERS"])


@router.get("/answer_raw", description="Get unprocessed answer json from KGQAn", tags=["KGQAn"])
async def answer_raw(question_text: str, knowledge_graph: str, max_answers: int):
    result_json = call_kgqan_endpoint(
        question_text=question_text,
        knowledge_graph=knowledge_graph,
        max_answers=max_answers
    )
    return JSONResponse(content=result_json)


@router.get("/answer", description="Get processed answer json from KGQAn", tags=["KGQAn"])
async def answer(question_text: str, knowledge_graph: str, max_answers: int):
    result_json = call_kgqan_endpoint(
        question_text=question_text,
        knowledge_graph=knowledge_graph,
        max_answers=max_answers
    )
    parsed_response = parse_kgqan_response(result_json)
    return JSONResponse(content=parsed_response)


@router.post("/annotatequestion", description="Standard process method for Qanary components", tags=["Qanary"])
async def qanary_service(request: Request):
    """the POST endpoint required for a Qanary service"""

    request_json = await request.json()

    triplestore_endpoint = request_json["values"]["urn:qanary#endpoint"]
    triplestore_ingraph = request_json["values"]["urn:qanary#inGraph"]
    triplestore_outgraph = request_json["values"]["urn:qanary#outGraph"]
    logger.info("endpoint: %s, inGraph: %s, outGraph: %s" % \
                 (triplestore_endpoint, triplestore_ingraph, triplestore_outgraph))

    question_text = get_text_question_in_graph(triplestore_endpoint=triplestore_endpoint,
                                      graph=triplestore_ingraph)[0]["text"]
    question_uri = get_text_question_in_graph(triplestore_endpoint=triplestore_endpoint,
                                              graph=triplestore_ingraph)[0]["uri"]
    logger.info(f"Question text: {question_text}")
    ## MAIN FUNCTIONALITY
    # call with default values
    response_json = call_kgqan_endpoint(question_text=question_text)
    candidate_list = parse_kgqan_response(response_json)
    # create sparql insert queries 
    for candidate in candidate_list:
        # query candidate
        sparql_AnnotationOfAnswerSPARQL = """
            PREFIX dbr: <http://dbpedia.org/resource/>
            PREFIX oa: <http://www.w3.org/ns/openannotation/core/>
            PREFIX qa: <http://www.wdaqua.eu/qa#>
            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

            INSERT {{
                GRAPH <{graph}>  {{
                    ?newAnnotation rdf:type qa:AnnotationOfAnswerSPARQL .
                    ?newAnnotation oa:hasTarget <{target_question}> .
                    ?newAnnotation oa:hasBody "{answer_sparql}" .
                    ?newAnnotation qa:score "{confidence}"^^xsd:float .
                    ?newAnnotation qa:index "{index}"^^xsd:integer .
                    ?newAnnotation oa:annotatedAt ?time .
                    ?newAnnotation oa:annotatedBy <urn:qanary:{component_name}> .
                }}
            }}
            WHERE {{
                BIND (IRI(CONCAT("urn:qanary:annotation:answer:sparql:", STR(RAND()))) AS ?newAnnotation) .
                BIND (now() as ?time) .
            }}
        """.format(
            graph = triplestore_ingraph,
            target_question = question_uri,
            answer_sparql = candidate.get("sparql"),
            confidence = candidate.get("confidence"),
            index = candidate.get("index"),
            component_name = SERVICE_NAME_COMPONENT
        )
        logger.debug(f"SPARQL for query candidates:\n{sparql_AnnotationOfAnswerSPARQL}")
        insert_into_triplestore(triplestore_endpoint, sparql_AnnotationOfAnswerSPARQL)

        # TODO: answer json

        # TODO: answer data type
#        sparql_AnnotationOfAnswerDataType = """
#            PREFIX dbr: <http://dbpedia.org/resource/>
#            PREFIX oa: <http://www.w3.org/ns/openannotation/core/>
#            PREFIX qa: <http://www.wdaqua.eu/qa#>
#            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
#            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
#
#            INSERT {
#                GRAPH <{graph}>  {
#                    ?newAnnotation rdf:type qa:AnnotationOfAnswerDataType .
#                    ?newAnnotation oa:hasTarget <{target_question}> .
#                    ?newAnnotation qa:answerDataType <{answer_datatype}> .
#                    ?newAnnotation oa:annotatedAt ?time .
#                    ?newAnnotation oa:annotatedBy <urn:qanary:{component_name}> .
#                }
#            }
#            WHERE {
#                BIND (IRI(CONCAT("urn:qanary:annotation:answer:sparql:", STR(RAND()))) AS ?newAnnotation) .
#                BIND (now() as ?time) .
#            }
#        """.format(
#            graph = triplestore_ingraph,
#            target_question = question_uri,
#            answer_datatype = ?
#            component_name = SERVICE_NAME_COMPONENT
#        )

    return JSONResponse(request_json)


def parse_kgqan_response(response_json: dict):
    """Extract required information for Annotations to the triplestore"""

    candidate_list = []
    for index, result in enumerate(response_json):
        logger.debug(f"candidate #{index}: {result}")
        candidate = {
            'sparql': clean_sparql_for_insert_query(result.get("sparql")),
            'values': result.get("values"),
            'confidence': result.get("score"),
            'index': index
        }
        candidate_list.append(candidate)
    return candidate_list


def call_kgqan_endpoint(question_text: str, knowledge_graph: str = KGQAN_KNOWLEDGEGRAPH, max_answers: int = KGQAN_MAX_ANSWERS):
    """Post the text question to the KGQAn service"""

    json = {
        'question': question_text,
        'knowledge_graph': knowledge_graph,
        'max_answers': max_answers
    }
    headers = {
        'Content-Type': 'application/json'
    }
    response = requests.request("POST", KGQAN_ENDPOINT, json=json, headers=headers)
    if response.status_code != 200:
        raise RuntimeError(f"Could not fetch answer from KGQAn server: {response.status_code}:\n{response.text}")

    response_json = response.json()
    logger.debug(f"got response json: {response_json}")
    return response_json


def clean_sparql_for_insert_query(sparql: str):
    """Remove unneeded elements of the generated SPARQL query"""

    cleaned_sparql = re.sub(r"OPTIONAL\W*\{(.*?)\}", "", sparql.replace("?type", ""))
    return cleaned_sparql
