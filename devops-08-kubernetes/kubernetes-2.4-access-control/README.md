# Домашнее задание к занятию «Управление доступом»

### Цель задания

В тестовой среде Kubernetes нужно предоставить ограниченный доступ пользователю.

------

### Чеклист готовности к домашнему заданию

1. Установлено k8s-решение, например MicroK8S.
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым github-репозиторием.

------

### Инструменты / дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) RBAC.
2. [Пользователи и авторизация RBAC в Kubernetes](https://habr.com/ru/company/flant/blog/470503/).
3. [RBAC with Kubernetes in Minikube](https://medium.com/@HoussemDellai/rbac-with-kubernetes-in-minikube-4deed658ea7b).

------

### Задание 1. Создайте конфигурацию для подключения пользователя

1. Создайте и подпишите SSL-сертификат для подключения к кластеру.
2. Настройте конфигурационный файл kubectl для подключения.
3. Создайте роли и все необходимые настройки для пользователя.
4. Предусмотрите права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`).
5. Предоставьте манифесты и скриншоты и/или вывод необходимых команд.

------

### Решение задания 1. Создайте конфигурацию для подключения пользователя

1. Используя OpenSSL создаю файл ключа на сервере с MicroK8S:

```bash
╰─➤openssl genrsa -out staff.key 2048
```

Создаю запрос на подписание сертификата (CSR):

```bash
╰─➤openssl req -new -key staff.key -out staff.csr -subj "/CN=staff/O=manager"
```

Генерирую файл сертификата (CRT). Поскольку я использую Microk8s, я буду использовать ключи кластера по пути `/var/snap/microk8s/current/certs/`:

```bash
╰─➤openssl x509 -req -in staff.csr -CA /var/snap/microk8s/current/certs/ca.crt -CAkey /var/snap/microk8s/current/certs/ca.key -CAcreateserial -out staff.crt -days 365
Certificate request self-signature ok
subject=CN = staff, O = manager
```

![img01.png](/devops-08-kubernetes/kubernetes-2.4-access-control/img/img01.png)

[staff.crt](/devops-08-kubernetes/kubernetes-2.4-access-control/src/certs/staff.crt)

[staff.csr](/devops-08-kubernetes/kubernetes-2.4-access-control/src/certs/staff.csr)

[staff.key](/devops-08-kubernetes/kubernetes-2.4-access-control/src/certs/staff.key)

[ca.crt](/devops-08-kubernetes/kubernetes-2.4-access-control/src/certs/ca.crt)

[ca.key](/devops-08-kubernetes/kubernetes-2.4-access-control/src/certs/ca.key)

[ca.srl](/devops-08-kubernetes/kubernetes-2.4-access-control/src/certs/ca.srl)

2. Настраиваю конфигурационный файл kubectl для подключения.

Для настройки скопировал сертификаты с сервера со свой ПК

```bash
╰─➤scp staff* serg@192.168.0.22:/home/serg/DevOps-Netology/DevOps-35-Netology/devops-08-kubernetes/kubernetes-2.4-access-control/src/certs/
```

Создаю пользователя `staff` и настраиваю его на использование созданного выше ключа:

```bash
╰─➤kubectl config set-credentials staff --client-certificate=certs/staff.crt --client-key=certs/staff.key
User "staff" set.
```

Создаю новый контекст с именем `staff-context` и подключаю его к пользователю `staff`, созданному ранее:

```bash
╰─➤kubectl config set-context staff-context --cluster=microk8s-cluster --user=staff
Context "staff-context" created.
```

Проверю, создался ли контекст:

```bash
╰─➤kubectl config get-contexts
CURRENT   NAME            CLUSTER            AUTHINFO   NAMESPACE
*         microk8s        microk8s-cluster   admin      
          staff-context   microk8s-cluster   staff
```

Контекст создался.

3. Для выполнения задания создам отдельный Namespace:

```bash
╰─➤kubectl create namespace access-control
namespace/access-control created

╰─➤kubectl get namespaces
NAME                     STATUS   AGE
access-control           Active   9s
default                  Active   31d
kube-node-lease          Active   31d
kube-public              Active   31d
kube-system              Active   31d
nfs-server-provisioner   Active   5d10h
```

Также потребуется включение встроенного в Microk8s RBAC контроллера:

```bash
╰─➤microk8s enable rbac
Infer repository core for addon rbac
Enabling RBAC
Reconfiguring apiserver
Restarting apiserver
RBAC is enabled
```

Применю манифест создания роли (Role) и манифест привязки роли к Namespace (RoleBinding):

```bash
╰─➤kubectl apply -f role.yaml
role.rbac.authorization.k8s.io/podinfo-viewer created

╰─➤kubectl apply -f rolebinding.yaml
rolebinding.rbac.authorization.k8s.io/read-pods created

╰─➤kubectl -n access-control get role
NAME             CREATED AT
podinfo-viewer   2024-06-07T18:58:54Z

╰─➤kubectl -n access-control get rolebindings
NAME        ROLE                  AGE
read-pods   Role/podinfo-viewer   38s
```

4. Для проверки прав пользователя переключусь в его контекст:

```bash
╰─➤kubectl config use-context staff-context
Switched to context "staff-context".
```

Разверну Deployment в разрешенном для пользователя Namespace:

```bash
╰─➤kubectl apply -f deployment.yaml
deployment.apps/nginx-only created

╰─➤kubectl -n access-control get deployment
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
nginx-only   1/1     1            1           28s
```

Проверю какие развернуты поды в Namespace с именем `default`:

```bash
╰─➤kubectl get pods
Error from server (Forbidden): pods is forbidden: User "staff" cannot list resource "pods" in API group "" in the namespace "default"
```

Видно, что в Namespace с именем `default` нет доступа, так как он не был указан в манифесте Role.

Но если я проверю поды в Namespace с именем `access-control`, то список подов отобразится, т.к. на него есть разрешения в Role:

```bash
╰─➤kubectl -n access-control get pods
NAME                          READY   STATUS    RESTARTS   AGE
nginx-only-5c5b9c965b-wpd8w   1/1     Running   0          2m16s
```

Также проверю логи пода:

```bash
╰─➤kubectl -n access-control logs nginx-only-5c5b9c965b-wpd8w 
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2024/06/07 19:01:08 [notice] 1#1: using the "epoll" event method
2024/06/07 19:01:08 [notice] 1#1: nginx/1.25.4
2024/06/07 19:01:08 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14) 
2024/06/07 19:01:08 [notice] 1#1: OS: Linux 5.14.0-427.18.1.el9_4.x86_64
2024/06/07 19:01:08 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 65536:65536
2024/06/07 19:01:08 [notice] 1#1: start worker processes
2024/06/07 19:01:08 [notice] 1#1: start worker process 29
2024/06/07 19:01:08 [notice] 1#1: start worker process 30
2024/06/07 19:01:08 [notice] 1#1: start worker process 31
2024/06/07 19:01:08 [notice] 1#1: start worker process 32
```

Проверю вывод описания пода:

```bash
╰─➤kubectl -n access-control describe pod nginx-only-5c5b9c965b-wpd8w 
Name:             nginx-only-5c5b9c965b-wpd8w
Namespace:        access-control
Priority:         0
Service Account:  default
Node:             rockylinux9/192.168.0.150
Start Time:       Fri, 07 Jun 2024 22:01:08 +0300
Labels:           app=nginx-frontend
                  pod-template-hash=5c5b9c965b
Annotations:      cni.projectcalico.org/containerID: b62b0f1fcda66684404ebaa98ad9589cb2e5e909cf078d1d5fa82676d68b5b76
                  cni.projectcalico.org/podIP: 10.1.191.248/32
                  cni.projectcalico.org/podIPs: 10.1.191.248/32
Status:           Running
IP:               10.1.191.248
IPs:
  IP:           10.1.191.248
Controlled By:  ReplicaSet/nginx-only-5c5b9c965b
Containers:
  nginx-app:
    Container ID:   containerd://1eb8d7059655d36c031d0e8bd58e6c772cb0e0e04a7d41bed07b03425718b401
    Image:          nginx:1.25.4
    Image ID:       docker.io/library/nginx@sha256:9ff236ed47fe39cf1f0acf349d0e5137f8b8a6fd0b46e5117a401010e56222e1
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 07 Jun 2024 22:01:08 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-bwppk (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  kube-api-access-bwppk:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
```

Согласно манифесту роли и ее привязке к Namespace, у пользователя `staff` есть доступ подам, их логам и описанию.

5. Ссылка на манифесты:

[deployment.yaml](/devops-08-kubernetes/kubernetes-2.4-access-control/src/deployment.yaml)

[role.yaml](/devops-08-kubernetes/kubernetes-2.4-access-control/src/role.yaml)

[rolebinding.yaml](/devops-08-kubernetes/kubernetes-2.4-access-control/src/rolebinding.yaml)
