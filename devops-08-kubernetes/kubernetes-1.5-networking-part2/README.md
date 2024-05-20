# Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 2»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к двум приложениям снаружи кластера по разным путям.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Service.
3. [Описание](https://kubernetes.io/docs/concepts/services-networking/ingress/) Ingress.
4. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment приложений backend и frontend

1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.
2. Создать Deployment приложения _backend_ из образа multitool. 
3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 
4. Продемонстрировать, что приложения видят друг друга с помощью Service.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

### Решение задания 1. Создать Deployment приложений backend и frontend

1. Для выполнения задания создам отдельный Namespace. Пишу манифест Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт:

Конфиг: [deploy_front.yaml](/devops-08-kubernetes/kubernetes-1.5-networking-part2/src/deploy_front.yaml)

```bash
╰─➤kubectl delete namespace networking-part1
namespace "networking-part1" deleted

╰─➤kubectl create namespace networking-part2
namespace/networking-part2 created

╰─➤kubectl get namespaces
NAME               STATUS   AGE
default            Active   13d
kube-node-lease    Active   13d
kube-public        Active   13d
kube-system        Active   13d
networking-part2   Active   14s

╰─➤kubectl apply -f deploy_front.yaml 
deployment.apps/frontend created
```

2. Пишу манифест Deployment приложения _backend_ из образа multitool:

Конфиг: [deploy_back.yaml](/devops-08-kubernetes/kubernetes-1.5-networking-part2/src/deploy_back.yaml)

```bash
╰─➤kubectl apply -f deploy_back.yaml 
deployment.apps/backend created
```

Проверю созданные поды:

```bash
╰─➤kubectl -n networking-part2 get pods
NAME                       READY   STATUS    RESTARTS   AGE
backend-86db7cc54b-k5hk8   1/1     Running   0          110s
frontend-7f4d9d89b-brmkj   1/1     Running   0          4m38s
frontend-7f4d9d89b-l8475   1/1     Running   0          4m38s
frontend-7f4d9d89b-rnq4h   1/1     Running   0          4m38s
```
Поды созданы, количество реплик соответствуют заданию.

![img01.png](/devops-08-kubernetes/kubernetes-1.5-networking-part2/img/img01.png)

3. Пишу манифест Service, который обеспечит доступ к обоим приложениям внутри кластера:

Конфиг: [service.yaml](/devops-08-kubernetes/kubernetes-1.5-networking-part2/src/service.yaml)

Так как имена приложений в Deployments разные, для связи сервиса с деплойментами буду использовать selector типа component.

Применю сервис и проверю его состояние:

```bash
╰─➤kubectl apply -f service.yaml
service/frontback-service created

╰─➤kubectl -n networking-part2 get svc -o wide
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE   SELECTOR
frontback-service   ClusterIP   10.152.183.108   <none>        9001/TCP,9002/TCP   44s   component=network2
```

![img02.png](/devops-08-kubernetes/kubernetes-1.5-networking-part2/img/img02.png)

4. Используя curl, проверю, видят ли приложения друг друга через созданный сервис из пода backend:

```bash
╰─➤kubectl exec -n networking-part2 backend-86db7cc54b-k5hk8 -- curl frontback-service:9002
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   143  100   143    0     0   159k      0 --:--:-- --:--:-- --:--:--  139k
WBITT Network MultiTool (with NGINX) - backend-86db7cc54b-k5hk8 - 10.1.191.198 - HTTP: 1180 , HTTPS: 443 . (Formerly praqma/network-multitool)

╰─➤kubectl exec -n networking-part2 backend-86db7cc54b-k5hk8 -- curl frontback-service:9001
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
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
100   615  100   615    0     0   774k      0 --:--:-- --:--:-- --:--:--  600k
```

![img03.png](/devops-08-kubernetes/kubernetes-1.5-networking-part2/img/img03.png)

```bash
╰─➤kubectl exec -n networking-part2 frontend-7f4d9d89b-brmkj -- curl frontback-service:9002
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   143  100   143    0     0  WBITT Network MultiTool (with NGINX) - backend-86db7cc54b-k5hk8 - 10.1.191.198 - HTTP: 1180 , HTTPS: 443 . (Formerly praqma/network-multitool)
 154k      0 --:--:-- --:--:-- --:--:--  139k

╰─➤kubectl exec -n networking-part2 frontend-7f4d9d89b-brmkj -- curl frontback-service:9001
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   609k      0 --:--:-- --:--:-- --:-<!DOCTYPE html>
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
-:--  600k
```

![img04.png](/devops-08-kubernetes/kubernetes-1.5-networking-part2/img/img04.png)

Приложения видят друг друга.

5. Ссылка на манифесты:

[deploy_front.yaml](/devops-08-kubernetes/kubernetes-1.5-networking-part2/src/deploy_front.yaml)

[deploy_back.yaml](/devops-08-kubernetes/kubernetes-1.5-networking-part2/src/deploy_back.yaml)

[service.yaml](/devops-08-kubernetes/kubernetes-1.5-networking-part2/src/service.yaml)

------

### Задание 2. Создать Ingress и обеспечить доступ к приложениям снаружи кластера

1. Включить Ingress-controller в MicroK8S.
2. Создать Ingress, обеспечивающий доступ снаружи по IP-адресу кластера MicroK8S так, чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_.
3. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
4. Предоставить манифесты и скриншоты или вывод команды п.2.

### Решение задания 2. Создать Ingress и обеспечить доступ к приложениям снаружи кластера


Подключаюсь к VM c MicroK8S и Включаю Ingress-controller.

```bash
╰─➤microk8s enable ingress
Infer repository core for addon ingress
Enabling Ingress
ingressclass.networking.k8s.io/public created
ingressclass.networking.k8s.io/nginx created
namespace/ingress created
serviceaccount/nginx-ingress-microk8s-serviceaccount created
clusterrole.rbac.authorization.k8s.io/nginx-ingress-microk8s-clusterrole created
role.rbac.authorization.k8s.io/nginx-ingress-microk8s-role created
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress-microk8s created
rolebinding.rbac.authorization.k8s.io/nginx-ingress-microk8s created
configmap/nginx-load-balancer-microk8s-conf created
configmap/nginx-ingress-tcp-microk8s-conf created
configmap/nginx-ingress-udp-microk8s-conf created
daemonset.apps/nginx-ingress-microk8s-controller created
Ingress is enabled
```

Проверю его состояние:

```bash
╰─➤kubectl get pods -A | grep ingress
ingress            nginx-ingress-microk8s-controller-fsv5x      1/1     Running   0              5m47s
```

![img05.png](/devops-08-kubernetes/kubernetes-1.5-networking-part2/img/img05.png)

Ingress-controller запущен.

2. Пишу манифест Ingress, обеспечивающий доступ снаружи по IP-адресу кластера MicroK8S так, чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_.

Применю манифест и проверю результат:

Конфиг: [ingress.yaml](/devops-08-kubernetes/kubernetes-1.5-networking-part2/src/ingress.yaml)

```bash
╰─➤kubectl apply -f ingress.yaml 
ingress.networking.k8s.io/web-ingress created

╰─➤kubectl get ingress -n networking-part2 
NAME          CLASS    HOSTS           ADDRESS     PORTS   AGE
web-ingress   public   myingress.com   127.0.0.1   80      115s

╰─➤kubectl -n networking-part2 describe ingress
Name:             web-ingress
Labels:           <none>
Namespace:        networking-part2
Address:          127.0.0.1
Ingress Class:    public
Default backend:  <default>
Rules:
  Host           Path  Backends
  ----           ----  --------
  myingress.com  
                 /      frontback-service:9001 (10.1.191.198:80,10.1.191.199:80,10.1.191.200:80 + 1 more...)
                 /api   frontback-service:9002 (10.1.191.198:1180,10.1.191.199:1180,10.1.191.200:1180 + 1 more...)
Annotations:     nginx.ingress.kubernetes.io/rewrite-target: /
Events:          <none>
```

![img06.png](/devops-08-kubernetes/kubernetes-1.5-networking-part2/img/img06.png)

Ingress создан.

3. Для проверки доступа с помощью браузера или `curl` с локального компьютера, добавлю в DNS соответствующую запись так, чтобы примененный в Ingress адрес myingress.com ссылался на IP адрес кластера MicroK8S.

Проверяю доступ к приложениям через Ingress:

```bash
╰─➤curl myingress.com
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

╰─➤curl myingress.com/api
WBITT Network MultiTool (with NGINX) - backend-86db7cc54b-k5hk8 - 10.1.191.198 - HTTP: 1180 , HTTPS: 443 . (Formerly praqma/network-multitool)
```
При обращении к `myingress.com` получаю ответ от Nginx, при обращении к `myingress.com/api` получаю ответ от Multitool.

4. Ссылка на манифест [ingress.yaml](/devops-08-kubernetes/kubernetes-1.5-networking-part2/src/ingress.yaml)

------
