#!/bin/bash
NAME1=fedora
NAME2=ubuntu
NAME3=centos7
IMAGE1=pycontribs/fedora:latest
IMAGE2=pycontribs/ubuntu:latest
IMAGE3=pycontribs/centos:7

docker run -dit --name $NAME1 $IMAGE1
docker run -dit --name $NAME2 $IMAGE2
docker run -dit --name $NAME3 $IMAGE3

docker start $NAME1
docker start $NAME2
docker start $NAME3

ansible-playbook -i inventory/prod.yml site.yml --vault-password-file ~/password.txt

docker stop $NAME1
docker stop $NAME2
docker stop $NAME3