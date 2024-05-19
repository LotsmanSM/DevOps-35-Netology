# Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 1»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к приложению, установленному в предыдущем ДЗ и состоящему из двух контейнеров, по разным портам в разные контейнеры как внутри кластера, так и снаружи.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Описание Service.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.
2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.
3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.
4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.


### Решение задания 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

1. Для начала удалю созданный в прошлом задании namespace, чтобы поды из разных работ не мешали друг другу и создам новый namespace:

```bash
╰─➤kubectl delete namespace netology
namespace "netology" deleted

╰─➤kubectl create namespace networking-part1
namespace/networking-part1 created

╰─➤kubectl get namespaces
NAME               STATUS   AGE
default            Active   12d
kube-node-lease    Active   12d
kube-public        Active   12d
kube-system        Active   12d
networking-part1   Active   62s
```

![img01.png](/devops-08-kubernetes/kubernetes-1.4-networking-part1/img/img01.png)

Пишу манифест Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.

Применяю манифест и проверяю результат:

```bash
╰─➤kubectl apply -f deployment.yaml 
deployment.apps/network-tools created

╰─➤kubectl -n networking-part1 get deployments
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
network-tools   3/3     3            3           36s
```

![img02.png](/devops-08-kubernetes/kubernetes-1.4-networking-part1/img/img02.png)

Deployment создан, количество реплик равно трём.

2. Пишу манифест Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.

Применяю манифест и проверяю результат:

```bash
╰─➤kubectl apply -f service.yaml 
service/network-service created

╰─➤ubectl -n networking-part1 get svc
NAME              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
network-service   ClusterIP   10.152.183.113   <none>        9001/TCP,9002/TCP   32s
```

![img03.png](/devops-08-kubernetes/kubernetes-1.4-networking-part1/img/img03.png)

Сервис создан и слушает порты 9001 и 9002.

3. Пишу манифест отдельного Pod, с приложением multitool и запускаю его:

```bash
╰─➤kubectl apply -f multitool.yaml
pod/multitool created

╰─➤kubectl -n networking-part1 get pods
NAME                             READY   STATUS    RESTARTS   AGE
multitool                        1/1     Running   0          17s
network-tools-85755465bb-cjq4l   2/2     Running   0          11m
network-tools-85755465bb-q4nwt   2/2     Running   0          11m
network-tools-85755465bb-v26wt   2/2     Running   0          11m
```

![img04.png](/devops-08-kubernetes/kubernetes-1.4-networking-part1/img/img04.png)

Проверяю адреса запущенных подов:

```bash
╰─➤kubectl -n networking-part1 get pods -o wide
NAME                             READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
multitool                        1/1     Running   0          89s     10.1.191.252   rockylinux9   <none>           <none>
network-tools-85755465bb-cjq4l   2/2     Running   0          12m     10.1.191.250   rockylinux9   <none>           <none>
network-tools-85755465bb-q4nwt   2/2     Running   0          12m     10.1.191.251   rockylinux9   <none>           <none>
network-tools-85755465bb-v26wt   2/2     Running   0          12m     10.1.191.249   rockylinux9   <none>           <none>
```

![img05.png](/devops-08-kubernetes/kubernetes-1.4-networking-part1/img/img05.png)

Из пода `multitool` проверяю доступность приложений в подах:

```bash
╰─➤kubectl exec -n networking-part1 -it multitool -- /bin/bash
multitool:/# curl network-service:9001
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
multitool:/#
```

![img06.png](/devops-08-kubernetes/kubernetes-1.4-networking-part1/img/img06.png)


4. С помощью `curl` проверю доступность подов по доменному имени сервиса:

```bash
╰─➤kubectl exec -n networking-part1 multitool -- curl network-service:9001
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   661k      0 --:--:-- --:--:-- --:--<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
:--  600k

╰─➤kubectl exec -n networking-part1 multitool -- curl network-service:9002
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0WBITT Network MultiTool (with NGINX) - network-tools-85755465bb-cjq4l - 10.1.191.250 - HTTP: 1180 , HTTPS: 443 . (Formerly praqma/network-multitool)
100   149  100   149    0     0   173k      0 --:--:-- --:--:-- --:--:--  145k
```

![img07.png](/devops-08-kubernetes/kubernetes-1.4-networking-part1/img/img07.png)

Nginx отвечает через сервис по порту 9001, multitool отвечает по порту 9002.

[Ссылка на манифест Deployment](/devops-08-kubernetes/kubernetes-1.4-networking-part1/src/deployment.yaml)

[Ссылка на манифест Service](/devops-08-kubernetes/kubernetes-1.4-networking-part1/src/service.yaml)

[Ссылка на манифест Pod](/devops-08-kubernetes/kubernetes-1.4-networking-part1/src/multitool.yaml)

------

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.
2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

### Решение задания 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

1. Создаю отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort:

```bash
╰─➤kubectl apply -f service-nodeport.yaml 
service/nodeport-service created

╰─➤kubectl -n networking-part1 get svc
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                       AGE
network-service    ClusterIP   10.152.183.113   <none>        9001/TCP,9002/TCP             57m
nodeport-service   NodePort    10.152.183.97    <none>        80:30007/TCP,8080:30008/TCP   23s
```

![img08.png](/devops-08-kubernetes/kubernetes-1.4-networking-part1/img/img08.png)

Сервис с именем nodeport-service и внешними портами 30007 и 30008 создан.

2. С помощью `curl` проверю, доступны ли приложения из подов по внешним портам:

```bash
╰─➤curl 192.168.0.150:30007
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

╰─➤curl 192.168.0.150:30008
WBITT Network MultiTool (with NGINX) - network-tools-85755465bb-v26wt - 10.1.191.249 - HTTP: 1180 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

![img09.png](/devops-08-kubernetes/kubernetes-1.4-networking-part1/img/img09.png)

Приложения доступны по локальному IP ноды, на порту 30007 отвечает nginx, на порту 30008 отвечает multitool.

[Ссылка на манифест Service](/devops-08-kubernetes/kubernetes-1.4-networking-part1/src/service-nodeport.yaml)

------