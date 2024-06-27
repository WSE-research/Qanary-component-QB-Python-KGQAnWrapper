#!/bin/bash
#
# start word_embedding_server and kgqan_server

echo "CHECKING DATA"
# mounted volume
data_dir="/KGQAn/data"

if [ -d $data_dir ];then
    echo "$data_dir exists"
else
    echo "$data_dir does not yet exist"
    mkdir -p $data_dir
fi 

kgqan_server_data="output_pred21_8_30"
download_kgqan_server_data=true
if [ -d "$data_dir/$kgqan_server_data" ]; then
    if [ -z "$(ls -A $data_dir/$kgqan_server_data)" ]; then
        echo "$data_dir/$kgqan_server_data exists but is empty!"
        rm -r $data_dir/$kgqan_server_data 
    else
        echo "$data_dir/$kgqan_server_data is not empty!"
        echo "skipping download"
        download_kgqan_server_data=false
    fi
else
    echo "$data_dir/$kgqan_server_data does not exist!"
fi

word_embedding_data="wiki-news-300d-1M"
download_word_embedding_data=true
if [ -f "$data_dir/$word_embedding_data.txt" ]; then
    echo "$data_dir/$word_embedding_data.txt already exists!"
    echo "skipping download"
    download_word_embedding_data=false
else
    echo "$data_dir exists but does not contain $word_embedding_data.txt!"
fi

if $download_kgqan_server_data; then
    echo "downloading $kgqan_server_data - this can take a few minutes ..."
    wget -q --load-cookies /tmp/cookies.txt "https://drive.usercontent.google.com/download?id=1QbT5FDOJtdVd7AqZ-ekwUh2_pn6nNpb3&export=download&confirm=t" -O "$data_dir/$kgqan_server_data.zip"
    unzip "$data_dir/$kgqan_server_data.zip" -d $data_dir
    rm "$data_dir/$kgqan_server_data.zip" # remove zip file
    echo "download finished"
fi

if $download_word_embedding_data; then
    echo "downloading $word_embedding_data - this can take a few minutes ..."
    wget -q --load-cookies /tmp/cookies.txt "https://drive.usercontent.google.com/download?id=1UTPGv8QUgqSVQ2JeX9QVW0YhbGRxONLL&export=download&confirm=t" -O "$data_dir/$word_embedding_data.zip"
    unzip "$data_dir/$word_embedding_data.zip" -d $data_dir
    rm "$data_dir/$word_embedding_data.zip" # remove zip file
    echo "download finished"
fi 

echo "Running Copy commands to run locally"
# copy the files to the respective target paths

word_embedding_path="/KGQAn/word_embedding/data"
mkdir -p "$word_embedding_path"
cp "/KGQAn/data/wiki-news-300d-1M.txt" "$word_embedding_path"

kgqan_model_path="/KGQAn/src/kgqan/model/"
mkdir -p "$kgqan_model_path"
cp -r /KGQAn/data/output_pred21_8_30/* "$kgqan_model_path"
echo "Copy commands finished"

# start word_embedding_server
cd KGQAn/
python word_embedding/server.py &

# start kgqan_server
#cd src
#./run.sh server &

#cd ../../

cd ../

# continue with CMD from Dockerfile
$@
