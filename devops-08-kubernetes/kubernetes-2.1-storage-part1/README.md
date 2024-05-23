# Домашнее задание к занятию «Хранение в K8s. Часть 1»

### Цель задания

В тестовой среде Kubernetes нужно обеспечить обмен файлами между контейнерам пода и доступ к логам ноды.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке MicroK8S](https://microk8s.io/docs/getting-started).
2. [Описание Volumes](https://kubernetes.io/docs/concepts/storage/volumes/).
3. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1 

**Что нужно сделать**

Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.
4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

### Решение задания 1

1. Пишу Deployment приложения, состоящего из контейнеров busybox и multitool.

Конфиг: [deployment.yaml](/devops-08-kubernetes/kubernetes-2.1-storage-part1/src/deployment.yaml)

```bash
╰─➤kubectl create namespace volume1
namespace/volume1 created

╰─➤kubectl apply -f deployment.yaml
deployment.apps/volumes-test created
```


2. Чтобы busybox писал данные каждые пять секунд в некий файл в общей директории, буду использовать команду создающую общую директорию и общий файл. Далее в созданный файл каждые пять секунд будет записываться сообщение "Test message".

3. Для обеспечения чтения файла контейнером multitool, в манифесте Deployment укажу общую с контейнером busybox директорию, читать файл буду с помощью команды `tail`.

4. Проверю, запишутся ли данные в файл контейнером busybox и будут ли они доступны контейнеру multitool.

Сделать это можно как из самих контейнеров, так и посмотрев их логи.

Проверю данные из контейнеров:

```bash
╰─➤kubectl get pods -n volume1
NAME                            READY   STATUS    RESTARTS   AGE
volumes-test-7c47668bf7-sfqxb   2/2     Running   0          28s

╰─➤kubectl -n volume1 exec -it volumes-test-7c47668bf7-sfqxb -c multitool -- sh
/ # ls
bin         dev         etc         lib         mnt         proc        run         srv         testvolume  usr
certs       docker      home        media       opt         root        sbin        sys         tmp         var
/ # cd testvolume/
/testvolume # ls
success.txt
/testvolume # cat success.txt 
Thu May 23 18:59:58 UTC 2024 - Test message
Thu May 23 19:00:03 UTC 2024 - Test message
Thu May 23 19:00:08 UTC 2024 - Test message
Thu May 23 19:00:13 UTC 2024 - Test message
Thu May 23 19:00:18 UTC 2024 - Test message
/testvolume # 
```

![img01.png](/devops-08-kubernetes/kubernetes-2.1-storage-part1/img/img01.png)

```bash
╰─➤kubectl -n volume1 exec -it volumes-test-7c47668bf7-sfqxb -c busybox -- sh
/ # ls
bin         dev         etc         home        proc        root        sys         testvolume  tmp         usr         var
/ # cd testvolume/
/testvolume # ls
success.txt
/testvolume # cat success.txt 
Thu May 23 18:59:58 UTC 2024 - Test message
Thu May 23 19:00:03 UTC 2024 - Test message
Thu May 23 19:00:08 UTC 2024 - Test message
Thu May 23 19:00:13 UTC 2024 - Test message
Thu May 23 19:00:18 UTC 2024 - Test message
Thu May 23 19:00:23 UTC 2024 - Test message
Thu May 23 19:00:28 UTC 2024 - Test message
Thu May 23 19:00:33 UTC 2024 - Test message
Thu May 23 19:00:38 UTC 2024 - Test message
Thu May 23 19:00:43 UTC 2024 - Test message
/testvolume # 
```

![img02.png](/devops-08-kubernetes/kubernetes-2.1-storage-part1/img/img02.png)

Из обоих контейнеров пода файл виден, доступен, в него действительно записываются данные каждые 5 секунд.

Также можно проверить, читает ли контейнер multitool файл success.txt, посмотрев его лог:

```bash
╰─➤kubectl logs -n volume1 volumes-test-7c47668bf7-sfqxb multitool 
Thu May 23 18:59:58 UTC 2024 - Test message
Thu May 23 19:00:03 UTC 2024 - Test message
Thu May 23 19:00:08 UTC 2024 - Test message
Thu May 23 19:00:13 UTC 2024 - Test message
Thu May 23 19:00:18 UTC 2024 - Test message
Thu May 23 19:00:23 UTC 2024 - Test message
Thu May 23 19:00:28 UTC 2024 - Test message
Thu May 23 19:00:33 UTC 2024 - Test message
Thu May 23 19:00:38 UTC 2024 - Test message
Thu May 23 19:00:43 UTC 2024 - Test message
Thu May 23 19:00:48 UTC 2024 - Test message
Thu May 23 19:00:53 UTC 2024 - Test message
Thu May 23 19:00:58 UTC 2024 - Test message
Thu May 23 19:01:03 UTC 2024 - Test message
Thu May 23 19:01:08 UTC 2024 - Test message
```

![img03.png](/devops-08-kubernetes/kubernetes-2.1-storage-part1/img/img03.png)

Видно, что контейнер multitool читает файл.

5. Ссылка на манифест [deployment.yaml](/devops-08-kubernetes/kubernetes-2.1-storage-part1/src/deployment.yaml)

------

### Задание 2

**Что нужно сделать**

Создать DaemonSet приложения, которое может прочитать логи ноды.

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
3. Продемонстрировать возможность чтения файла изнутри пода.
4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.

### Решение задания 2

1. Пишу манифест DaemonSet приложения, состоящего из multitool. Применяю манифест и проверяю DaemonSet и Pod:

Конфиг: [daemonset.yaml](/devops-08-kubernetes/kubernetes-2.1-storage-part1/src/daemonset.yaml)

```bash
╰─➤kubectl apply -f daemonset.yaml
daemonset.apps/test-daemonset created

╰─➤kubectl -n volume1 get daemonsets
NAME             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
test-daemonset   1         1         1       1            1           <none>          48s

╰─➤kubectl -n volume1 get pods
NAME                            READY   STATUS    RESTARTS   AGE
test-daemonset-gfjj9            1/1     Running   0          36s
volumes-test-7c47668bf7-sfqxb   2/2     Running   0          68m
```

![img04.png](/devops-08-kubernetes/kubernetes-2.1-storage-part1/img/img04.png)

2. Т.к. в RockyLinux 9 `/var/log/syslog` это пустой каталог, то было принято решение использовать файл `/var/log/messages`. Для обеспечения возможность чтения файла `/var/log/messages` кластера MicroK8S внутри контейнера буду использовать параметр subPath, который позволит монтировать не всю директорию /var/log c машины - кластера MicroK8S, а именно один файл `messages`. Также буду использовать параметр readOnly, чтобы избежать проблем с доступом к файлу `messages`, находящемуся на машине - кластере MicroK8S.

3. Проверю возможность чтения файла изнутри пода:

```bash
╰─➤ubectl -n volume1 exec -it test-daemonset-gfjj9 -- sh
/ # ls
bin         dev         etc         lib         mnt         opt         root        sbin        sys         usr
certs       docker      home        media       nodes-logs  proc        run         srv         tmp         var
/ # cd nodes-logs/
/nodes-logs # ls -la
total 14080
drwxr-xr-x    2 root     root            22 May 23 20:07 .
drwxr-xr-x    1 root     root            80 May 23 20:07 ..
-rw-------    1 root     root      10240211 May 23 20:09 messages
/nodes-logs # tail -n 10 messages
May 23 23:08:07 RockyLinux9 microk8s.daemon-containerd[791]: time="2024-05-23T23:08:07+03:00" level=info msg="Released host-wide IPAM lock." source="ipam_plugin.go:378"
May 23 23:08:07 RockyLinux9 microk8s.daemon-containerd[791]: 2024-05-23 23:08:07.020 [INFO][162472] k8s.go 589: Teardown processing complete. ContainerID="14b2f37bb049d4efc7e304ca53cd6db998dad7a047b5e84bb7c395434986139c"
May 23 23:08:07 RockyLinux9 microk8s.daemon-containerd[791]: time="2024-05-23T23:08:07.021336295+03:00" level=info msg="TearDown network for sandbox \"14b2f37bb049d4efc7e304ca53cd6db998dad7a047b5e84bb7c395434986139c\" successfully"
May 23 23:08:07 RockyLinux9 microk8s.daemon-containerd[791]: time="2024-05-23T23:08:07.025548544+03:00" level=info msg="RemovePodSandbox \"14b2f37bb049d4efc7e304ca53cd6db998dad7a047b5e84bb7c395434986139c\" returns successfully"
May 23 23:08:11 RockyLinux9 NetworkManager[757]: <info>  [1716494891.6724] dhcp4 (ens18): state changed new lease, address=192.168.0.150
May 23 23:08:11 RockyLinux9 systemd[1]: Starting Network Manager Script Dispatcher Service...
May 23 23:08:11 RockyLinux9 systemd[1]: Started Network Manager Script Dispatcher Service.
May 23 23:08:21 RockyLinux9 systemd[1]: NetworkManager-dispatcher.service: Deactivated successfully.
May 23 23:09:26 RockyLinux9 systemd[1]: run-containerd-runc-k8s.io-8bc3a4078159af43088b4e2ce8e7150f975bebc447b5d83017e0231e3025cd5e-runc.xKDhzC.mount: Deactivated successfully.
May 23 23:09:49 RockyLinux9 systemd[1]: run-containerd-runc-k8s.io-f9b074a2f6e1bd91a4100d4637703d2da204bda081fd1bb7c564507d372882f7-runc.LMLci5.mount: Deactivated successfully.
/nodes-logs #
```

![img05.png](/devops-08-kubernetes/kubernetes-2.1-storage-part1/img/img05.png)

Видно, что в контейнере пода присутствует директория /nodes-logs/ с файлом `messages`, который примонтирован из машины - кластера MicroK8S.

4. Ссылка на манифест [daemonset.yaml](/devops-08-kubernetes/kubernetes-2.1-storage-part1/src/daemonset.yaml)

------
