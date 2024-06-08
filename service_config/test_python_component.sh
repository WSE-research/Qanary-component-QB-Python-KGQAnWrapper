#!/bin/bash


dir=${PWD##*/}

name=$(echo ${dir} | tr "[:upper:]" "[:lower:]")
printf "Testing ${name}"
if [ ! -d "test-env/" ]; then
  echo "created new test environment"
  python -m venv test-env
else
  echo "using existing test environment"
fi 

if source test-env/bin/activate; then
  pip install -r requirements.txt 
else
  echo "Something went wrong trying to install requirements! Exiting ..."
  exit 4
fi

if ! pip show pytest; then
  echo "Installing pytest manually..."
  pip install pytest
fi 
if ! pip show pytest-env; then 
  echo "Installing pytest-env manually..."
  pip install pytest-env
fi

if ! pytest; then
  echo "Pytest failed"
  exit 4
fi
deactivate

echo "Done"
