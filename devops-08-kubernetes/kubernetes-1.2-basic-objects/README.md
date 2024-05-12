# Домашнее задание к занятию «Базовые объекты K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Pod с приложением и подключиться к нему со своего локального компьютера. 

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. Описание [Pod](https://kubernetes.io/docs/concepts/workloads/pods/) и примеры манифестов.
2. Описание [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

------

### Задание 1. Создать Pod с именем hello-world

1. Создать манифест (yaml-конфигурацию) Pod.
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

### Решение задания 1. Создать Pod с именем hello-world

1. Написал манифест для пода.
2. Указал имя пода hello-world, указал образ gcr.io/kubernetes-e2e-test-images/echoserver:2.2:


```
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  containers:
  - name: echoserver
    image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
    ports:
    - containerPort: 8080
```

Создал под и запустил его:

```bash
╰─➤kubectl apply -f pod.yaml
pod/hello-world created

╰─➤kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
hello-world   1/1     Running   0          10m

```

![img01_kubectl_pod.png](/devops-08-kubernetes/kubernetes-1.2-basic-objects/img/img01_kubectl_pod.png)

3. С помощью port-forward пробрасываю порт пода в локальную сеть, после чего могу подключиться к поду:

```bash
╰─➤kubectl port-forward pod/hello-world 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

```bash
╰─➤curl localhost:8080/


Hostname: hello-world

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=127.0.0.1
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://localhost:8080/

Request Headers:
	accept=*/*  
	host=localhost:8080  
	user-agent=curl/7.81.0  

Request Body:
	-no body in request-
```

![img02_localhost_8080.png](/devops-08-kubernetes/kubernetes-1.2-basic-objects/img/img02_localhost_8080.png)

------

### Задания 2. Создать Service и подключить его к Pod

1. Создать Pod с именем netology-web.
2. Использовать image — gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Создать Service с именем netology-svc и подключить к netology-web.
4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

### Решение задания 2. Создать Service и подключить его к Pod

1-3. Пишу манифест для создания пода и сервиса, связываю их с помощью label и selector, использую образ gcr.io/kubernetes-e2e-test-images/echoserver:2.2:

```
apiVersion: v1
kind: Pod
metadata:
  name: netology-web
  labels:
    app: netology-web
spec:
  containers:
  - name: echoserver
    image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
    ports:
    - containerPort: 8080

---

apiVersion: v1
kind: Service
metadata:
  name: netolgy-svc
spec:
  selector:
    app: netology-web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

Запускаю под и сервис:

```bash
╰─➤kubectl apply -f service.yaml
pod/netology-web created
service/netolgy-svc created

╰─➤kubectl get pods
NAME           READY   STATUS    RESTARTS      AGE
hello-world    1/1     Running   1 (29m ago)   43m
netology-web   1/1     Running   0             4m46s
```

![img03_kubectl_service.png](/devops-08-kubernetes/kubernetes-1.2-basic-objects/img/img03_kubectl_service.png)

4. Подключаюсь локально к Service с помощью `kubectl port-forward`:

```bash
╰─➤kubectl port-forward service/netolgy-svc 8085:80
Forwarding from 127.0.0.1:8085 -> 8080
Forwarding from [::1]:8085 -> 8080
```

С помощью curl смотрю ответ от пода на GET запрос:

```bash
╰─➤curl localhost:8085


Hostname: netology-web

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=127.0.0.1
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://localhost:8080/

Request Headers:
	accept=*/*  
	host=localhost:8085  
	user-agent=curl/7.81.0  

Request Body:
	-no body in request-
```

![img04_localhost_8085.png](/devops-08-kubernetes/kubernetes-1.2-basic-objects/img/img04_localhost_8085.png)

------

Ссылки на манифесты:

[Pod](/devops-08-kubernetes/kubernetes-1.2-basic-objects/src/pod.yaml)

[Service](/devops-08-kubernetes/kubernetes-1.2-basic-objects/src/service.yaml)