# Домашнее задание к занятию «Как работает сеть в K8s»

### Цель задания

Настроить сетевую политику доступа к подам.

### Чеклист готовности к домашнему заданию

1. Кластер K8s с установленным сетевым плагином Calico.

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Calico](https://www.tigera.io/project-calico/).
2. [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
3. [About Network Policy](https://docs.projectcalico.org/about/about-network-policy).

-----

### Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа

1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
2. В качестве образа использовать network-multitool.
3. Разместить поды в namespace App.
4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
5. Продемонстрировать, что трафик разрешён и запрещён.

### Решение задания 1. Создать сетевую политику или несколько политик для обеспечения доступа

Т.к. в MicroK8S установлен плагин Calico из коробки, то буду успользовать его для выполнения задания

```bash
╰─➤kubectl get pods -A
NAMESPACE                NAME                                         READY   STATUS    RESTARTS         AGE
kube-system              calico-kube-controllers-77bd7c5b-pj9kg       1/1     Running   18 (3h16m ago)   41d
kube-system              calico-node-6d9gr                            1/1     Running   18 (3h16m ago)   41d
kube-system              coredns-864597b5fd-dsqj5                     1/1     Running   18 (3h16m ago)   41d
kube-system              dashboard-metrics-scraper-5657497c4c-dpvzj   1/1     Running   18 (3h16m ago)   41d
kube-system              kubernetes-dashboard-54b48fbf9-mhk6x         1/1     Running   18 (3h16m ago)   41d
kube-system              metrics-server-848968bdcd-nmr2f              1/1     Running   18 (3h16m ago)   41d
nfs-server-provisioner   nfs-server-provisioner-0                     1/1     Running   3 (3h16m ago)    15d
```

1. Пишу манифесты deployment'ов приложений [frontend](/devops-08-kubernetes/kubernetes-3.3-network-works-K8s/src/frontend.yaml), [backend](/devops-08-kubernetes/kubernetes-3.3-network-works-K8s/src/backend.yaml) и [cache](/devops-08-kubernetes/kubernetes-3.3-network-works-K8s/src/cache.yaml) и соответсвующие им сервисы.

2. В манифестах deployment'ов в качестве образа используется network-multitool.

3. Для размещения подов в namespace app создам этот namespace:

```bash
╰─➤kubectl create namespace app
namespace/app created
```

Также в метаданных манифестов deployment'ов и сетевых политик сразу укажу использование namespace app.

4. Пишу манифесты сетевых политик, которые будут разрешать обращаться к приложению пода backend из frontend а также будут разрешать обращаться к приложению пода cache из пода backend. Все остальное будет запрещено. Сначала запрещается весь сетевой трафик, потом разрешается то, что должно быть разрешено.

[Ссылка на запрещающий манифест](/devops-08-kubernetes/kubernetes-3.3-network-works-K8s/src/deny-all.yaml)

[Ссылка на манифест разрешающий обращаться к backend из frontend](/devops-08-kubernetes/kubernetes-3.3-network-works-K8s/src/front-to-back.yaml)

[Ссылка на манифест разрешающий обращаться к cache из backend](/devops-08-kubernetes/kubernetes-3.3-network-works-K8s/src/back-to-cache.yaml)

5. Применю манифесты deployment'ов и сетевых политик:

```bash
╰─➤kubectl apply -f frontend.yaml
deployment.apps/frontend-application created
service/front-svc created

╰─➤kubectl apply -f backend.yaml
deployment.apps/backend-application created
service/back-svc created

╰─➤kubectl apply -f cache.yaml
deployment.apps/cache-application created
service/network-service created

╰─➤kubectl apply -f deny-all.yaml
networkpolicy.networking.k8s.io/deny-all created

╰─➤kubectl apply -f front-to-back.yaml
networkpolicy.networking.k8s.io/front-to-back created

╰─➤kubectl apply -f back-to-cache.yaml
networkpolicy.networking.k8s.io/back-to-cache created
```

Проверяю результат:

```bash
╰─➤kubectl -n app get deployments -o wide
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                    SELECTOR
backend-application    1/1     1            1           2m25s   multitool    wbitt/network-multitool   app=back
cache-application      1/1     1            1           2m12s   multitool    wbitt/network-multitool   app=cache
frontend-application   1/1     1            1           2m34s   multitool    wbitt/network-multitool   app=front

╰─➤kubectl -n app get pods -o wide --show-labels
NAME                                    READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES   LABELS
backend-application-7b65596897-6njps    1/1     Running   0          2m35s   10.1.191.200   rockylinux9   <none>           <none>            app=back,pod-template-hash=7b65596897
cache-application-9547f5798-v8gnw       1/1     Running   0          2m22s   10.1.191.199   rockylinux9   <none>           <none>            app=cache,pod-template-hash=9547f5798
frontend-application-677fbd7ccc-wnxdl   1/1     Running   0          2m44s   10.1.191.197   rockylinux9   <none>           <none>            app=front,pod-template-hash=677fbd7ccc

╰─➤kubectl -n app get networkpolicies
NAME            POD-SELECTOR   AGE
back-to-cache   app=cache      2m5s
deny-all        <none>         2m26s
front-to-back   app=back       2m15s
```

![img01.png](/devops-08-kubernetes/kubernetes-3.3-network-works-K8s/img/img01.png)

Создались deployment'ы, поды и сетевые политики в соответствии с заданием.

Проверю, что трафик из frontend в backend и из backend в cache разрешен, остальное запрещено.

В соответствии с моими deployment'ами приложения в подах слушают порт 1180, соответственно к нему я и буду подключаться.

Захожу на под с приложением frontend и проверю, можно ли из него обратиться к приложению backend:

```bash
╰─➤kubectl -n app exec -it pods/frontend-application-677fbd7ccc-wnxdl -- bash
frontend-application-677fbd7ccc-wnxdl:/# curl --connect-timeout 5 10.1.191.200:1180 -I
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Mon, 17 Jun 2024 20:04:05 GMT
Content-Type: text/html
Content-Length: 155
Last-Modified: Mon, 17 Jun 2024 19:55:24 GMT
Connection: keep-alive
ETag: "667094ac-9b"
Accept-Ranges: bytes

frontend-application-677fbd7ccc-wnxdl:/# curl --connect-timeout 5 10.1.191.197:1180 -I
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Mon, 17 Jun 2024 20:06:21 GMT
Content-Type: text/html
Content-Length: 156
Last-Modified: Mon, 17 Jun 2024 19:55:16 GMT
Connection: keep-alive
ETag: "667094a4-9c"
Accept-Ranges: bytes

frontend-application-677fbd7ccc-wnxdl:/# curl --connect-timeout 5 10.1.191.199:1180 -I
curl: (28) Failed to connect to 10.1.191.199 port 1180 after 5001 ms: Timeout was reached

frontend-application-677fbd7ccc-wnxdl:/# 
```

![img02.png](/devops-08-kubernetes/kubernetes-3.3-network-works-K8s/img/img02.png)

Видно, что frontend имеет доступ к самому себе и имеет доступ к приложению backend, но не имеет доступ к приложению cache.

Захожу на под с приложением backend и проверю, можно ли из него обратиться к приложению cache:

```bash
╰─➤kubectl -n app exec -it pods/backend-application-7b65596897-6njps -- bash
backend-application-7b65596897-6njps:/# curl --connect-timeout 5 10.1.191.200:1180 -I
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Mon, 17 Jun 2024 20:12:17 GMT
Content-Type: text/html
Content-Length: 155
Last-Modified: Mon, 17 Jun 2024 19:55:24 GMT
Connection: keep-alive
ETag: "667094ac-9b"
Accept-Ranges: bytes

backend-application-7b65596897-6njps:/# curl --connect-timeout 5 10.1.191.199:1180 -I
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Mon, 17 Jun 2024 20:12:35 GMT
Content-Type: text/html
Content-Length: 152
Last-Modified: Mon, 17 Jun 2024 19:55:37 GMT
Connection: keep-alive
ETag: "667094b9-98"
Accept-Ranges: bytes

backend-application-7b65596897-6njps:/# curl --connect-timeout 5 10.1.191.197:1180 -I
curl: (28) Failed to connect to 10.1.191.197 port 1180 after 5001 ms: Timeout was reached

backend-application-7b65596897-6njps:/# 
```

![img03.png](/devops-08-kubernetes/kubernetes-3.3-network-works-K8s/img/img03.png)

Видно, что backend имеет доступ к самому себе и имеет доступ к приложению cache, но не имеет доступ к приложению frontend.

Захожу на под с приложением cache и проверю, можно ли из него обратиться к приложениям frontend и backend:

```bash
╰─➤kubectl -n app exec -it pods/cache-application-9547f5798-v8gnw -- bash
cache-application-9547f5798-v8gnw:/# curl --connect-timeout 5 10.1.191.199:1180 -I
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Mon, 17 Jun 2024 20:17:47 GMT
Content-Type: text/html
Content-Length: 152
Last-Modified: Mon, 17 Jun 2024 19:55:37 GMT
Connection: keep-alive
ETag: "667094b9-98"
Accept-Ranges: bytes

cache-application-9547f5798-v8gnw:/# curl --connect-timeout 5 10.1.191.197:1180 -I
curl: (28) Failed to connect to 10.1.191.197 port 1180 after 5001 ms: Timeout was reached

cache-application-9547f5798-v8gnw:/# curl --connect-timeout 5 10.1.191.200:1180 -I
curl: (28) Failed to connect to 10.1.191.200 port 1180 after 5001 ms: Timeout was reached

cache-application-9547f5798-v8gnw:/#
```

![img04.png](/devops-08-kubernetes/kubernetes-3.3-network-works-K8s/img/img04.png)

Видно, что cache имеет доступ к самому себе, но не имеет доступ к приложениям frontend и backend.
