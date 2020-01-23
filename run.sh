#!/bin/bash

echo ""
echo ""
echo ""

 URL="https://github.com/icqparty/"

function run-server {
    name=github-actions-$(echo $1 | sed 's/\//-/g')
}

repo_url_complete=""

FILE=./.env_runner

ARG_ENV_FILE=$(echo $1 | xargs)


if  [  -n "$ARG_ENV_FILE" ];
then
    FILE=$ARG_ENV_FILE
fi

docker build -t github-runner:latest -f Dockerfile.ubuntu .

index=0

if test -f "$FILE";
then

    echo "File: ${FILE}"
    echo ""
    while read p; do


        repo_url_complete=$(echo $URL$p | cut -d'=' -f1 | xargs)
        repo_token_complete=$(echo $p | cut -d'=' -f2 | xargs)

        repo_name="$(echo $p | cut -d'=' -f1 | xargs)$index"

        echo "repo_name=$repo_name"
        echo "repo_url_complete=$repo_url_complete"
        echo "repo_token_complete=$repo_token_complete"
        echo ""
        echo "docker run -rm -d --restart=always -e REPO_URL="$repo_url_complete" -e RUNNER_TOKEN="$repo_token_complete" -v /var/run/docker.sock:/var/run/docker.sock --name $repo_name -t github-runner:latest"
        echo ""


        docker exec -i $repo_name /bin/bash -c "sudo /actions-runner/config.sh remove --token AANUQQZYVP24COJAYIS23RC6FIAI4"
        docker stop $repo_name && docker rm $repo_name


        docker run -d --rm  -e REPO_URL="$repo_url_complete" -e RUNNER_TOKEN="$repo_token_complete" -v /var/run/docker.sock:/var/run/docker.sock --name $repo_name -t github-runner:latest


        #REPO_NAME=${repo_name}  REPO_URL=${repo_url_complete}  REPO_TOKEN=${repo_token_complete}  docker-compose up -d --force-recreate --remove-orphans
        echo "-------------------------"
        echo ""


        index=$((i+1))
    done <"$FILE"

    docker ps
else
  echo "File ENV not found : $FILE"
  echo ""
  exit 1
fi

