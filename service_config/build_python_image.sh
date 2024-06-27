#!/bin/bash

dir=${PWD##*/}
image=$(echo ${dir} | tr "[:upper:]" "[:lower:]")

image_dp="${image}-dbpedia"
image_wd="${image}-wikidata"

# build dbpedia version
echo "Building ${image_dp}"
version=$(grep -oP '(?<=version = ")[^"]*' component/__init__.py)
latest_image_dp_name="qanary/${image_dp}:latest"
versioned_image_dp_name="qanary/${image_dp}:${version}"
docker build -t "${versioned_image_dp_name}" \
  --build-arg KGQAN_KNOWLEDGEGRAPH=dbpedia \
  --build-arg KNOWLEDGE_GRAPH_NAMES='["dbpedia"]' \
  --build-arg DBPEDIA_URI=https://dbpedia.org/sparql .
docker tag "${versioned_image_dp_name}" "${latest_image_dp_name}"

# build wikidata version
echo "Building ${image_wd}"
version=$(grep -oP '(?<=version = ")[^"]*' component/__init__.py)
latest_image_wd_name="qanary/${image_wd}:latest"
versioned_image_wd_name="qanary/${image_wd}:${version}"
docker build -t "${versioned_image_wd_name}" --build-arg KGQAN_KNOWLEDGEGRAPH=wikidata \
  --build-arg KNOWLEDGE_GRAPH_NAMES='["wikidata"]' \
  --build-arg WIKIDATA_URI=https://wikidata.demo.openlinksw.com/sparql .
docker tag "${versioned_image_wd_name}" "${latest_image_wd_name}"

# push all images
echo "Pushing ${versioned_image_dp_name} and ${latest_image_dp_name}"

docker push "${versioned_image_dp_name}"
docker push "${latest_image_dp_name}"

echo "Pushing ${versioned_image_wd_name} and ${latest_image_wd_name}"
docker push "${versioned_image_wd_name}"
docker push "${latest_image_wd_name}"

echo "Removing images"
docker rmi -f "${versioned_image_dp_name}"
docker rmi -f "${latest_image_dp_name}"
docker rmi -f "${versioned_image_wd_name}"
docker rmi -f "${latest_image_wd_name}"
echo "Done"
