# Домашнее задание к занятию «Kubernetes. Причины появления. Команда kubectl»

### Цель задания

Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине или на отдельной виртуальной машине MicroK8S.

------

### Чеклист готовности к домашнему заданию

1. Личный компьютер с ОС Linux или MacOS 

или

2. ВМ c ОС Linux в облаке либо ВМ на локальной машине для установки MicroK8S  

------

### Инструкция к заданию

1. Установка MicroK8S:
    - sudo apt update,
    - sudo apt install snapd,
    - sudo snap install microk8s --classic,
    - добавить локального пользователя в группу `sudo usermod -a -G microk8s $USER`,
    - изменить права на папку с конфигурацией `sudo chown -f -R $USER ~/.kube`.

2. Полезные команды:
    - проверить статус `microk8s status --wait-ready`;
    - подключиться к microK8s и получить информацию можно через команду `microk8s command`, например, `microk8s kubectl get nodes`;
    - включить addon можно через команду `microk8s enable`; 
    - список addon `microk8s status`;
    - вывод конфигурации `microk8s config`;
    - проброс порта для подключения локально `microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443`.

3. Настройка внешнего подключения:
    - отредактировать файл /var/snap/microk8s/current/certs/csr.conf.template
    ```shell
    # [ alt_names ]
    # Add
    # IP.4 = 123.45.67.89
    ```
    - обновить сертификаты `sudo microk8s refresh-certs --cert front-proxy-client.crt`.

4. Установка kubectl:
    - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl;
    - chmod +x ./kubectl;
    - sudo mv ./kubectl /usr/local/bin/kubectl;
    - настройка автодополнения в текущую сессию `bash source <(kubectl completion bash)`;
    - добавление автодополнения в командную оболочку bash `echo "source <(kubectl completion bash)" >> ~/.bashrc`.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S.
2. [Инструкция](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/#bash) по установке автодополнения **kubectl**.
3. [Шпаргалка](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/) по **kubectl**.

------

### Задание 1. Установка MicroK8S

1. Установить MicroK8S на локальную машину или на удалённую виртуальную машину.
2. Установить dashboard.
3. Сгенерировать сертификат для подключения к внешнему ip-адресу.


### Решение задания 1. Установка MicroK8S

1. Устанавливаю MicroK8S на виртуальную машину с RockyLinux 9:

Установка Snapd

```bash
╰─➤dnf install epel-release -y

╰─➤dnf install snapd -y
Последняя проверка окончания срока действия метаданных: 0:02:14 назад, Вт 07 мая 2024 20:18:46.
Зависимости разрешены.
================================================================================
 Пакет                 Архитектура    Версия                 Репозиторий  Размер
================================================================================
Установка:
 snapd                 x86_64         2.62-0.el9             epel          16 M
Установка зависимостей:
 snap-confine          x86_64         2.62-0.el9             epel         2.7 M
 snapd-selinux         noarch         2.62-0.el9             epel         101 k
 xdelta                x86_64         3.1.0-16.el9           epel          88 k

Результат транзакции
================================================================================
Установка  4 Пакета

Объем загрузки: 19 M
Объем изменений: 65 M
Загрузка пакетов:
(1/4): snapd-selinux-2.62-0.el9.noarch.rpm      1.0 MB/s | 101 kB     00:00    
(2/4): xdelta-3.1.0-16.el9.x86_64.rpm           398 kB/s |  88 kB     00:00    
(3/4): snap-confine-2.62-0.el9.x86_64.rpm       6.6 MB/s | 2.7 MB     00:00    
(4/4): snapd-2.62-0.el9.x86_64.rpm              8.6 MB/s |  16 MB     00:01    
--------------------------------------------------------------------------------
Общий размер                                    8.9 MB/s |  19 MB     00:02     
Проверка транзакции
Проверка транзакции успешно завершена.
Идет проверка транзакции
Тест транзакции проведен успешно.
Выполнение транзакции
  Подготовка       :                                                        1/1 
  Установка        : xdelta-3.1.0-16.el9.x86_64                             1/4 
  Запуск скриптлета: snapd-selinux-2.62-0.el9.noarch                        2/4 
  Установка        : snapd-selinux-2.62-0.el9.noarch                        2/4 
  Запуск скриптлета: snapd-selinux-2.62-0.el9.noarch                        2/4 
  Установка        : snap-confine-2.62-0.el9.x86_64                         3/4 
  Установка        : snapd-2.62-0.el9.x86_64                                4/4 
  Запуск скриптлета: snapd-2.62-0.el9.x86_64                                4/4 
  Запуск скриптлета: snapd-selinux-2.62-0.el9.noarch                        4/4 
  Запуск скриптлета: snapd-2.62-0.el9.x86_64                                4/4 
  Проверка         : snap-confine-2.62-0.el9.x86_64                         1/4 
  Проверка         : snapd-2.62-0.el9.x86_64                                2/4 
  Проверка         : snapd-selinux-2.62-0.el9.noarch                        3/4 
  Проверка         : xdelta-3.1.0-16.el9.x86_64                             4/4 

Установлен:
  snap-confine-2.62-0.el9.x86_64            snapd-2.62-0.el9.x86_64             
  snapd-selinux-2.62-0.el9.noarch           xdelta-3.1.0-16.el9.x86_64          

Выполнено!
```
![img01_snap_install.png](/devops-08-kubernetes/kubernetes-1.1-kubectl/img/img01_snap_install.png)

После установки создаю символьную ссылку для поддержки Snap.

```bash
╰─➤ln -s /var/lib/snapd/snap /snap
```
Экспорт snaps в $PATH.

```bash
echo 'export PATH=$PATH:/var/lib/snapd/snap/bin' | sudo tee -a /etc/profile.d/snap.sh
source /etc/profile.d/snap.sh
```

Автозапуск службы

```bash
╰─➤systemctl enable --now snapd.socket
Created symlink /etc/systemd/system/sockets.target.wants/snapd.socket → /usr/lib/systemd/system/snapd.socket.
```

Проверка статуса службы snapd

```bash
╰─➤systemctl status snapd.socket
● snapd.socket - Socket activation for snappy daemon
     Loaded: loaded (/usr/lib/systemd/system/snapd.socket; enabled; preset: disabled)
     Active: active (listening) since Tue 2024-05-07 20:33:19 MSK; 2min 45s ago
      Until: Tue 2024-05-07 20:33:19 MSK; 2min 45s ago
   Triggers: ● snapd.service
     Listen: /run/snapd.socket (Stream)
             /run/snapd-snap.socket (Stream)
      Tasks: 0 (limit: 48917)
     Memory: 0B
        CPU: 573us
     CGroup: /system.slice/snapd.socket

мая 07 20:33:19 RockyLinux9 systemd[1]: Starting Socket activation for snappy daemon...
мая 07 20:33:19 RockyLinux9 systemd[1]: Listening on Socket activation for snappy daemon.
```

Перевожу SELinux в permissive режим

```bash
╰─➤setenforce 0
╰─➤sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
```

Установка Microk8s

```bash
╰─➤snap install microk8s --classic
2024-05-07T20:45:58+03:00 INFO Waiting for automatic snapd restart...
microk8s (1.29/stable) v1.29.4 from Canonical✓ installed
```
![img02_microk8s_install.png](/devops-08-kubernetes/kubernetes-1.1-kubectl/img/img02_microk8s_install.png)

Добавляю пользователя в группу microk8s, создаю директорию с конфигурацией и даю пользователю доступ к этой директории:

```bash
╰─➤usermod -a -G microk8s $USER
╰─➤mkdir -p ~/.kube
╰─➤chown -f -R $USER ~/.kube
```

Чтобы изменения вступили в силу, выполняю команду:

```bash
╰─➤newgrp microk8s
```

Командой `microk8s status --wait-ready` проверяю статус MicroK8S:

```bash
╰─➤microk8s status --wait-ready
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    dns                  # (core) CoreDNS
    ha-cluster           # (core) Configure high availability on the current node
    helm                 # (core) Helm - the package manager for Kubernetes
    helm3                # (core) Helm 3 - the package manager for Kubernetes
  disabled:
    cert-manager         # (core) Cloud native certificate management
    cis-hardening        # (core) Apply CIS K8s hardening
    community            # (core) The community addons repository
    dashboard            # (core) The Kubernetes dashboard
    gpu                  # (core) Alias to nvidia add-on
    host-access          # (core) Allow Pods connecting to Host services smoothly
    hostpath-storage     # (core) Storage class; allocates storage from host directory
    ingress              # (core) Ingress controller for external access
    kube-ovn             # (core) An advanced network fabric for Kubernetes
    mayastor             # (core) OpenEBS MayaStor
    metallb              # (core) Loadbalancer for your Kubernetes cluster
    metrics-server       # (core) K8s Metrics Server for API access to service metrics
    minio                # (core) MinIO object storage
    nvidia               # (core) NVIDIA hardware (GPU and network) support
    observability        # (core) A lightweight observability stack for logs, traces and metrics
    prometheus           # (core) Prometheus operator for monitoring and logging
    rbac                 # (core) Role-Based Access Control for authorisation
    registry             # (core) Private image registry exposed on localhost:32000
    rook-ceph            # (core) Distributed Ceph storage using Rook
    storage              # (core) Alias to hostpath-storage add-on, deprecated
```

Вижу статус `microk8s is running`.

Также можно посмотреть ноды, включить аддоны, посмотреть конфигурацию и т.д.:

![img03_microk8s_other.png](/devops-08-kubernetes/kubernetes-1.1-kubectl/img/img03_microk8s_other.png)

Поскольку я запустил только MicroK8S, у меня работает всего одна нода.

2. Устанавливаю Kubernetes Dashboard:

```bash
╰─➤microk8s enable dashboard
Infer repository core for addon dashboard
Enabling Kubernetes Dashboard
Infer repository core for addon metrics-server
Enabling Metrics-Server
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
clusterrolebinding.rbac.authorization.k8s.io/microk8s-admin created
Metrics-Server is enabled
Applying manifest
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
secret/microk8s-dashboard-token created

If RBAC is not enabled access the dashboard using the token retrieved with:

microk8s kubectl describe secret -n kube-system microk8s-dashboard-token

Use this token in the https login UI of the kubernetes-dashboard service.

In an RBAC enabled setup (microk8s enable RBAC) you need to create a user with restricted
permissions as shown in:
https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
```


Редактирую файл `/var/snap/microk8s/current/certs/csr.conf.template` и добавляю адреса для внешнего подключения:

![img04_microk8s_ip.png](/devops-08-kubernetes/kubernetes-1.1-kubectl/img/img04_microk8s_ip.png)

3. Обновляю сертификаты:

```bash
╰─➤microk8s refresh-certs --cert front-proxy-client.crt
Taking a backup of the current certificates under /var/snap/microk8s/6809/certs-backup/
Creating new certificates
Signature ok
subject=CN = front-proxy-client
Getting CA Private Key
Restarting service kubelite.
```

Открываю порты для внешних порключений

```bash
╰─➤firewall-cmd --add-port={25000/tcp,16443/tcp,12379/tcp,10250/tcp,10255/tcp,10257/tcp,10259/tcp,10443/tcp} --permanent
success

╰─➤firewall-cmd --reload
```


------

### Задание 2. Установка и настройка локального kubectl
1. Установить на локальную машину kubectl.
2. Настроить локально подключение к кластеру.
3. Подключиться к дашборду с помощью port-forward.

### Выполнение задания 2. Установка и настройка локального kubectl

1. Установил на свою рабочую машину с Pop OS 22.04 kubectl

![img05_local_kubectl.png](/devops-08-kubernetes/kubernetes-1.1-kubectl/img/img05_local_kubectl.png)

Генерируем на виртуальном сервере microk8s config для внешного подключения с помощью kubectl

```bash
╰─➤microk8s config > ~/.kube/config
```
Забираю config microk8s на локальную машину
```bash
╰─➤scp root@192.168.0.150:~/.kube/config ~/.kube/
```
Проверяю подключение к серверу из локальной машины

```bash
╰─➤kubectl get nodes
NAME          STATUS   ROLES    AGE   VERSION
rockylinux9   Ready    <none>   85m   v1.29.4
```

Узнаю токен для входа в Kubernetes Dashboard:

![img06_local_kubectl_token.png](/devops-08-kubernetes/kubernetes-1.1-kubectl/img/img06_local_kubectl_token.png)

Используя `port-forward` подключаюсь к Kubernetes Dashboard:

```bash
╰─➤kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443
Forwarding from 127.0.0.1:10443 -> 8443
Forwarding from [::1]:10443 -> 8443
Handling connection for 10443
```

Авторизуюсь в Kubernetes Dashboard:

![img07_dashboard.png](/devops-08-kubernetes/kubernetes-1.1-kubectl/img/img07_dashboard.png)

------