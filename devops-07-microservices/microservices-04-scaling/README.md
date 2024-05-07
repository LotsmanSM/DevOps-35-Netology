
# Домашнее задание к занятию «Микросервисы: масштабирование»

Вы работаете в крупной компании, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps-специалисту необходимо выдвинуть предложение по организации инфраструктуры для разработки и эксплуатации.

## Задача 1: Кластеризация

Предложите решение для обеспечения развёртывания, запуска и управления приложениями.
Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

Решение должно соответствовать следующим требованиям:
- поддержка контейнеров;
- обеспечивать обнаружение сервисов и маршрутизацию запросов;
- обеспечивать возможность горизонтального масштабирования;
- обеспечивать возможность автоматического масштабирования;
- обеспечивать явное разделение ресурсов, доступных извне и внутри системы;
- обеспечивать возможность конфигурировать приложения с помощью переменных среды, в том числе с возможностью безопасного хранения чувствительных данных таких как пароли, ключи доступа, ключи шифрования и т. п.

Обоснуйте свой выбор.

## Решение задачи 1: Кластеризация

Самым очевидным выбором в данном случае будет являться оркестратор `Kubernetes (K8S)`. Kubernetes основан на запуске контейнеров. Умеет выполнять горизонтальное масштабирование путём указания количества реплик контейнеров, которые должны быть запущены. Так же в рамках горизонтального масштабирование поддерживается различные методы балансировки запросов для обеспечения эффективного распределения трафика между экземплярами приложений.

Автоматическое масштабирование можно настроить путём подключения метрик prometheus и настройки предельных значений. Также можно настроить Horizontal Pod Autoscaler, (HPA), который позволяет автоматически масштабировать количество реплик подов в зависимости от загрузки, что обеспечивает более эффективное использование ресурсов.

Также Kubernetes может обеспечивать явное разделение ресурсов, доступных извне и внутри системы. Например, распределение ресурсов по сервисам - сервис с типом ClusterIP будет доступен только изнутри кластера, тогда как сервис с типом NodePort или LoadBalancer будет доступен извне кластера.
Либо распределение ресурсов через Ingress Controllers - позволяет управлять входящим сетевым трафиком в кластер, определяя правила маршрутизации и доступности веб-сервисов извне.
Либо реализация Role-Based Access Control (RBAC) - позволяет управлять доступом пользователей и сервисов к ресурсам в Kubernetes, определяя различные уровни доступа и разрешений в зависимости от ролей.

Kubernetes предоставляет возможности для конфигурирования приложений с использованием переменных окружения, а также обеспечивает механизмы для безопасного хранения чувствительных данных, что помогает обеспечить безопасность и конфиденциальность приложений в кластере. Для этого можно использовать Secrets - это объекты Kubernetes, предназначенные для хранения конфиденциальной информации; Volume Mounts -  один из способов безопасной передачи конфиденциальных данных в приложение является использование Volume Mounts для монтирования Secrets как файлов в контейнеры приложений; а также возможно подключение внешних инструментов управления секретами, таких как HashiCorp Vault.

Таким образом, Kubernetes полностью подходит для выполнения описанных требований, а также является бесплатным продуктом с обширной аудиторией, большим количеством документации и обучающих материалов. Основным минусом Kubernetes может являть сложность его обслуживания, соответственно у работников компании должны быть соответствующие компетенции.

## Задача 2: Распределённый кеш * (необязательная)

Разработчикам вашей компании понадобился распределённый кеш для организации хранения временной информации по сессиям пользователей.
Вам необходимо построить Redis Cluster, состоящий из трёх шард с тремя репликами.

### Схема:

![11-04-01](https://user-images.githubusercontent.com/1122523/114282923-9b16f900-9a4f-11eb-80aa-61ed09725760.png)

## Решение задачи 2: Распределённый кеш * (необязательная)

# Необязательную часть не делал.