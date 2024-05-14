# Домашнее задание к занятию «Запуск приложений в K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров, и масштабировать его.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) Init-контейнеров.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.
2. После запуска увеличить количество реплик работающего приложения до 2.
3. Продемонстрировать количество подов до и после масштабирования.
4. Создать Service, который обеспечит доступ до реплик приложений из п.1.
5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

### Решение задания 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создам отдельный Namespace для того, чтобы созданные в этом задании поды, деплойменты, сервисы работали отдельно от остальных, ранее созданных:

```bash
╰─➤kubectl create namespace netology
namespace/netology created
```
Пишу манифест Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Поскольку у меня запущен Ingress с nginx в поде `nginx-ingress-microk8s-controller-tdkdf`, то порты 80, 443 будут заняты. В случае, если эти порты заняты, то запуск multitool потребует указания альтернативного порта. Для этого в манифест Deployment добавляю переменную с указанием порта 1180.

[Ссылка на манифест Deployment](/devops-08-kubernetes/kubernetes-1.3-launching-applications/src/deployment.yaml)

Запускаю Deployment:

```bash
╰─➤kubectl apply -n netology -f deployment.yaml 
deployment.apps/nginx-multitool created
```

Проверяю результат:

```bash
╰─➤kubectl get deployments -n netology 
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
nginx-multitool   1/1     1            1           98s

╰─➤kubectl get pods -n netology 
NAME                              READY   STATUS    RESTARTS   AGE
nginx-multitool-84f948f95-rkmzl   2/2     Running   0          2m3s
```

![img01.png](/devops-08-kubernetes/kubernetes-1.3-launching-applications/img/img01.png)

2. Сейчас у меня запущена одна реплика приложения nginx-multitool. Увеличу количество реплик до двух и проверю результат:

```bash
╰─➤kubectl scale deployment --replicas=2 -n netology nginx-multitool
deployment.apps/nginx-multitool scaled

╰─➤kubectl kubectl get deployments -n netology 
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
nginx-multitool   2/2     2            2           14m
```

![img02.png](/devops-08-kubernetes/kubernetes-1.3-launching-applications/img/img02.png)

Видно, что количество реплик в AVAILABLE увеличилось до двух и обе запущены.

3. До масштабирования у меня был один под:

![img01.png](/devops-08-kubernetes/kubernetes-1.3-launching-applications/img/img01.png)

После масштабирования стало два пода:

![img03.png](/devops-08-kubernetes/kubernetes-1.3-launching-applications/img/img03.png)

4. Пишу манифест Service с именем nginx-multitool-svc в namespace netology. Применяю манифест:

```bash
╰─➤kubectl apply -f service.yaml 
service/nginx-multitool-svc created
```

[Ссылка на манифест Service](/devops-08-kubernetes/kubernetes-1.3-launching-applications/src/service.yaml)

Проверяю сервисы в namespace netology:

```bash
╰─➤kubectl -n netology get svc
NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)           AGE
nginx-multitool-svc   ClusterIP   10.152.183.173   <none>        80/TCP,8080/TCP   104s
```
Сервис создан.

5. Пишу манифест отдельного пода multitool в namespace netology. Применяю манифест:

```bash
╰─➤kubectl apply -f multitool.yaml 
pod/multitool created
```

[Ссылка на манифест с подом multitool](/devops-08-kubernetes/kubernetes-1.3-launching-applications/src/multitool.yaml)

Проверяю поды в namespace netology:

```bash
╰─➤kubectl get pods -n netology 
NAME                              READY   STATUS    RESTARTS   AGE
multitool                         1/1     Running   0          55s
nginx-multitool-84f948f95-rhfhd   2/2     Running   0          21m
nginx-multitool-84f948f95-rkmzl   2/2     Running   0          35m
```

![img04.png](/devops-08-kubernetes/kubernetes-1.3-launching-applications/img/img04.png)

Видно, что под с именем multitool был создан и запущен.

С помощью `curl`, проверяю, есть ли из пода multitool доступ до приложений из п.1.:

```bash
╰─➤kubectl exec -n netology multitool -- curl nginx-multitool-svc:80
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   802k      0 --:--:-- --:--:-- --:--:--  600k
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
```

При обращении на порт 80 сервиса ответил запущенный nginx.

```bash
╰─➤kubectl exec -n netology multitool -- curl nginx-multitool-svc:8080
WBITT Network MultiTool (with NGINX) - nginx-multitool-84f948f95-rkmzl - 10.1.191.233 - HTTP: 1180 , HTTPS: 443 . (Formerly praqma/network-multitool)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   150  100   150    0     0   162k      0 --:--:-- --:--:-- --:--:--  146k
```

При обращении на порт 8080 сервиса ответил запущенный multitool.

------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.
3. Создать и запустить Service. Убедиться, что Init запустился.
4. Продемонстрировать состояние пода до и после запуска сервиса.

### Решение задания 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1 - 2. Создаю манифест Deployment приложения nginx, который запустится только после запуска сервиса. В качестве Init-контейнера использую busybox:

```bash
╰─➤kubectl apply -f nginx-init-deploy.yaml 
deployment.apps/nginx-init-deploy created
```
Deployment создан, проверю запущен ли под:

```bash
╰─➤kubectl get pods -n netology 
NAME                                 READY   STATUS     RESTARTS   AGE
multitool                            1/1     Running    0          19m
nginx-init-deploy-786df4c9fc-2nlv5   0/1     Init:0/1   0          70s
nginx-multitool-84f948f95-rhfhd      2/2     Running    0          40m
nginx-multitool-84f948f95-rkmzl      2/2     Running    0          54m
```
Вижу, что под не запущен и находится в состоянии `Init:0/1`.

![img05.png](/devops-08-kubernetes/kubernetes-1.3-launching-applications/img/img05.png)

[Ссылка на манифест Deployment](/devops-08-kubernetes/kubernetes-1.3-launching-applications/src/nginx-init-deploy.yaml)

3 - 4. Создаю манифест Service, применяю его и проверю запустился ли под nginx:

```bash
╰─➤kubectl apply -f nginx-init-svc.yaml 
service/nginx-init-svc created

╰─➤kubectl get pods -n netology 
NAME                                 READY   STATUS    RESTARTS   AGE
multitool                            1/1     Running   0          25m
nginx-init-deploy-786df4c9fc-2nlv5   1/1     Running   0          6m33s
nginx-multitool-84f948f95-rhfhd      2/2     Running   0          45m
nginx-multitool-84f948f95-rkmzl      2/2     Running   0          59m
```
После запуска сервиса, запустился под с nginx.

![img06.png](/devops-08-kubernetes/kubernetes-1.3-launching-applications/img/img06.png)

[Ссылка на манифест Service](/devops-08-kubernetes/kubernetes-1.3-launching-applications/src/nginx-init-svc.yaml)

------