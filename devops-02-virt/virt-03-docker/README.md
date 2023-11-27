
# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

---
## Задача 1

Сценарий выполнения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберите любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```

Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

## Решение 1

https://hub.docker.com/r/lotsmansm/web-app

---
## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
«Подходит ли в этом сценарии использование Docker-контейнеров или лучше подойдёт виртуальная машина, физическая машина? Может быть, возможны разные варианты?»

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- высоконагруженное монолитное Java веб-приложение;
- Nodejs веб-приложение;
- мобильное приложение c версиями для Android и iOS;
- шина данных на базе Apache Kafka;
- Elasticsearch-кластер для реализации логирования продуктивного веб-приложения — три ноды elasticsearch, два logstash и две ноды kibana;
- мониторинг-стек на базе Prometheus и Grafana;
- MongoDB как основное хранилище данных для Java-приложения;
- Gitlab-сервер для реализации CI/CD-процессов и приватный (закрытый) Docker Registry.

## Решение 2

- **Высоконагруженное монолитное java веб-приложение** - лучше на виртуальной машине. Максимум ресурсов вытягивать из железа здесь не обязательно, поэтому виртуализация даст такие плюсы, как легкое масштабирование выделенных ресурсов, переносимость и восстановление на другом хосте, когда это понадобится.
- **Nodejs веб-приложение** - Для развёртывания web-приложения удобно использовать Docker-контейнер. Перед релизом контейнер можно запускать на dev- и test- средах для тестирования. Можно воспользоваться [готовым образом](https://hub.docker.com/_/node).
- **Мобильное приложение c версиями для Android и iOS** - я бы лучше выделил виртуальную машину. Приложение одно, по сути монолит. Изменяется нагрузка по клиентским подключениям - значит, нужно менять выделенные ресурсы.
- **Шина данных на базе Apache Kafka** - Kafka строится из множества узлов, поэтому быстрое их развертывание из контейнеров является наиболее приемлемым вариантом.
- **Elasticsearch кластер для реализации логирования продуктивного веб-приложения**  - три ноды elasticsearch, два logstash и две ноды kibana** Так как предлагается разворачивать несколько нод приложения, а так же все приведённые проекта имеют официальные образы в Docker Hub ([Elasticsearch](https://hub.docker.com/_/elasticsearch), [Logstash](https://hub.docker.com/_/logstash), [Kibana](https://hub.docker.com/_/kibana)) предлагаю использовать Docker-контейнер. При этом Elasticsearch должен быть stateful-приложением, так как это база данных.
- **Мониторинг-стек на базе Prometheus и Grafana** Prometheus и Grafana являются приложениями с web-интерфейсом. По сути те же web-приложения. В таких случаях удобно использовать Docker-контейнер.
- **Mongodb, как основное хранилище данных для java-приложения** Для MongoDB так же можно использовать Docker-контейнер, например, с официального [образа](https://hub.docker.com/_/mongo). Как и в случае с Elasticsearch — это будет stateful-приложение, для сохранения данных после остановки контейнера.
- **Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry** Сервер Gitlab будет проще развернуть на виртуальной машине так как нет никаких предпосылок использования докера все что нужно для данного сервера это стабильный бекап и соединение. Если в компании повсеместно используются контейнеры - тогда, может, будет удобней Docker, т.к. инженерам это будет привычней.

---
## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

## Решение 3

- Создаю контейнер с debian \
[root@LotsmanSM data]# docker run -t -d -v /data:/data --network host --name my_debian debian \
109d84931b768d0c298f30c275fa3a0705f584c3ab95a8e9448e0d293f2c853b

- Создаю контейнер с centos \
[root@LotsmanSM data]# docker run -t -d -v /data:/data --network host --name my_centos centos \
76c8dd727e51a0c53c3aa9e39df32a01b2bcf97968184601f64547592694879e

- Проверим `docker ps`: \
[root@LotsmanSM data]# docker ps\
CONTAINER ID   IMAGE     COMMAND       CREATED              STATUS              PORTS     NAMES \
76c8dd727e51   centos    "/bin/bash"   32 seconds ago       Up 32 seconds                 my_centos \
109d84931b76   debian    "bash"        About a minute ago   Up About a minute             my_debian

- Создаю документ test1 на my_debian \
[root@LotsmanSM data]# docker exec my_debian cat>/data/test1 \
[root@LotsmanSM data]# docker exec -it my_debian ls /data \
test1

- Создаю test2 на локальной машине \
[root@LotsmanSM data]# >/data/test2 \
[root@LotsmanSM data]# ls \
test1  test2

- Проверяю наличие этих файлов в my_centos \ 
[root@LotsmanSM data]# docker exec -it my_centos ls /data \
test1  test2

---
## Задача 4 (*)

Воспроизведите практическую часть лекции самостоятельно.

Соберите Docker-образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

## Решение 4 (*)

https://hub.docker.com/r/lotsmansm/ansible

[root@LotsmanSM docker-ansible]# docker build -t lotsmansm/ansible:v2.9.24 . \
[+] Building 97.5s (10/10) FINISHED                                                                                                                                                                                 docker:default \
 => [internal] load .dockerignore                                                                                                                                                                                             0.0s \
 => => transferring context: 2B                                                                                                                                                                                               0.0s \
 => [internal] load build definition from Dockerfile                                                                                                                                                                          0.0s \
 => => transferring dockerfile: 987B                                                                                                                                                                                          0.0s \
 => [internal] load metadata for docker.io/library/alpine:3.14                                                                                                                                                                0.5s \
 => CACHED [1/5] FROM docker.io/library/alpine:3.14@sha256:0f2d5c38dd7a4f4f733e688e3a6733cb5ab1ac6e3cb4603a5dd564e5bfb80eed                                                                                                   0.0s \
 => [internal] load build context                                                                                                                                                                                             0.0s \
 => => transferring context: 92B                                                                                                                                                                                              0.0s \
 => [2/5] RUN  CARGO_NET_GIT_FETCH_WITH_CLI=1 &&      apk --no-cache add sudo python3 py3-pip openssl ca-certificates sshpass openssh-client rsync git &&      apk --no-cache add      --virtual build-dependencies python3  94.4s \
 => [3/5] RUN  mkdir /ansible &&      mkdir -p /etc/ansible &&      echo 'localhost' > /etc/ansible/hosts                                                                                                                     0.3s \
 => [4/5] WORKDIR /ansible                                                                                                                                                                                                    0.0s \
 => [5/5] COPY ansible.cfg /ansible/                                                                                                                                                                                          0.0s \
 => exporting to image                                                                                                                                                                                                        2.2s \
 => => exporting layers                                                                                                                                                                                                       2.2s \
 => => writing image sha256:ffdf639a44d65570dbeb40f992af30f0dbd6b39ce8554885d821a9bd8fff8bec                                                                                                                                  0.0s \
 => => naming to docker.io/lotsmansm/ansible:v2.9.24                                                                                                                                                                          0.0s \
[root@LotsmanSM docker-ansible]# docker images \
REPOSITORY          TAG       IMAGE ID       CREATED          SIZE  \
lotsmansm/ansible   v2.9.24   ffdf639a44d6   22 seconds ago   256MB  \
lotsmansm/web-app   v1        c9dda452cf05   3 hours ago      42.6MB \
debian              latest    676aedd4776f   13 days ago      117MB  \
centos              latest    5d0da3dc9764   2 years ago      231MB  \
[root@LotsmanSM docker-ansible]#
