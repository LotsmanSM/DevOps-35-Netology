# Домашнее задание к занятию «Хранение в K8s. Часть 2»

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке NFS в MicroK8S](https://microk8s.io/docs/nfs). 
2. [Описание Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
3. [Описание динамического провижининга](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/). 
4. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
6. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

### Решение задания 1

Создание Deployment приложения, использующего локальный PV, созданный вручную.

1. Пишу манифест Deployment приложения, состоящего из контейнеров busybox и multitool.

Ссылка на манифест [deployment.yaml](/devops-08-kubernetes/kubernetes-2.2-storage-part2/src/deployment.yaml)

Применяю Deployment и проверяю его статус:

```bash
╰─➤kubectl create namespace volume2
namespace/volume2 created

╰─➤kubectl apply -f deployment.yaml 
deployment.apps/volumes-test2 created

╰─➤kubectl -n volume2 get pods
NAME                             READY   STATUS    RESTARTS   AGE
volumes-test2-6fb79c77d6-79rqf   0/2     Pending   0          16s
```

![img01.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img01.png)

Статус пода в состоянии Pending. Если посмотреть через describe причину, то можно увидеть следующее:

```bash
╰─➤kubectl -n volume2 describe pods
Name:             volumes-test2-58b75d984c-g8slh
Namespace:        volume2
Priority:         0
Service Account:  default
Node:             <none>
Labels:           app=volumes2
                  pod-template-hash=58b75d984c
Annotations:      <none>
Status:           Pending
IP:               
IPs:              <none>
Controlled By:    ReplicaSet/volumes-test2-58b75d984c
Containers:
  busybox:
    Image:      dockerhub.timeweb.cloud/library/busybox:latest
    Port:       <none>
    Host Port:  <none>
    Command:
      sh
      -c
      mkdir -p /out/logs && while true; do echo "$(date) - Test message" >> /out/logs/success.txt; sleep 5; done
    Environment:  <none>
    Mounts:
      /out/logs from volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vd6j8 (ro)
  multitool:
    Image:      dockerhub.timeweb.cloud/wbitt/network-multitool:latest
    Port:       <none>
    Host Port:  <none>
    Command:
      sh
      -c
      tail -f /out/logs/success.txt
    Environment:  <none>
    Mounts:
      /out/logs from volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vd6j8 (ro)
Conditions:
  Type           Status
  PodScheduled   False 
Volumes:
  volume:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  pvc-vol
    ReadOnly:   false
  kube-api-access-vd6j8:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  100s  default-scheduler  0/1 nodes are available: persistentvolumeclaim "pvc-vol" not found. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.
```

Под не запустился по причине отсутствия PVC с именем `pvc-vol`.

2. Пишу манифест PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.

Ссылка на манифест [pv.yaml](/devops-08-kubernetes/kubernetes-2.2-storage-part2/src/pv.yaml)

Ссылка на манифест [pvc.yaml](/devops-08-kubernetes/kubernetes-2.2-storage-part2/src/pvc.yaml)

Применяю манифесты PV и PVC и проверяю их статусы:

```bash
╰─➤kubectl apply -f pv.yaml
persistentvolume/local-volume created

╰─➤kubectl apply -f pvc.yaml 
persistentvolumeclaim/pvc-vol created

╰─➤kubectl -n volume2 get pv
NAME           CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS    VOLUMEATTRIBUTESCLASS   REASON   AGE
local-volume   2Gi        RWO            Retain           Bound    volume2/pvc-vol   local-storage   <unset>                          58s

╰─➤kubectl -n volume2 get pvc
NAME      STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS    VOLUMEATTRIBUTESCLASS   AGE
pvc-vol   Bound    local-volume   2Gi        RWO            local-storage   <unset>                 45s
```

![img02.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img02.png)

PV и PVC запущены.

Теперь проверю статус пода, который ожидал создания PVC с именем `pvc-vol`:

```bash
╰─➤kubectl -n volume2 get pods
NAME                             READY   STATUS    RESTARTS   AGE
volumes-test2-58b75d984c-g8slh   2/2     Running   0          4m45s
```

Под запущен.

3. Проверю, сможет ли multitool прочитать файл, в который busybox пишет данные каждые пять секунд в общей директории.

Проверить доступность файла можно из самого контейнера:

```bash
╰─➤kubectl exec -it -n volume2 volumes-test2-58b75d984c-g8slh -c multitool sh
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
/ # ls
bin     certs   dev     docker  etc     home    lib     media   mnt     opt     out     proc    root    run     sbin    srv     sys     tmp     usr     var
/ # cd /out/logs/
/out/logs # ls
success.txt
/out/logs # tail -f success.txt 
Sun Jun  2 06:21:56 UTC 2024 - Test message
Sun Jun  2 06:22:01 UTC 2024 - Test message
Sun Jun  2 06:22:06 UTC 2024 - Test message
Sun Jun  2 06:22:11 UTC 2024 - Test message
Sun Jun  2 06:22:16 UTC 2024 - Test message
Sun Jun  2 06:22:21 UTC 2024 - Test message
Sun Jun  2 06:22:26 UTC 2024 - Test message
Sun Jun  2 06:22:31 UTC 2024 - Test message
Sun Jun  2 06:22:36 UTC 2024 - Test message
Sun Jun  2 06:22:41 UTC 2024 - Test message
Sun Jun  2 06:22:46 UTC 2024 - Test message
```

![img03.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img03.png)

Также можно посмотреть логи самого контейнера в поде:

```bash
╰─➤kubectl -n volume2 logs volumes-test2-58b75d984c-g8slh multitool
Sun Jun  2 06:27:11 UTC 2024 - Test message
Sun Jun  2 06:27:16 UTC 2024 - Test message
Sun Jun  2 06:27:21 UTC 2024 - Test message
Sun Jun  2 06:27:26 UTC 2024 - Test message
Sun Jun  2 06:27:31 UTC 2024 - Test message
Sun Jun  2 06:27:36 UTC 2024 - Test message
Sun Jun  2 06:27:41 UTC 2024 - Test message
Sun Jun  2 06:27:46 UTC 2024 - Test message
Sun Jun  2 06:27:51 UTC 2024 - Test message
Sun Jun  2 06:27:56 UTC 2024 - Test message
Sun Jun  2 06:28:01 UTC 2024 - Test message
Sun Jun  2 06:28:06 UTC 2024 - Test message
Sun Jun  2 06:28:11 UTC 2024 - Test message
Sun Jun  2 06:28:16 UTC 2024 - Test message
Sun Jun  2 06:28:21 UTC 2024 - Test message
Sun Jun  2 06:28:26 UTC 2024 - Test message
Sun Jun  2 06:28:31 UTC 2024 - Test message
Sun Jun  2 06:28:36 UTC 2024 - Test message
Sun Jun  2 06:28:41 UTC 2024 - Test message
```

![img04.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img04.png)

Multitool имеет доступ к файлу и может прочитать его.

4. Удаляю Deployment и PVC:

```bash
╰─➤kubectl -n volume2 delete deployment volumes-test2 
deployment.apps "volumes-test2" deleted

╰─➤kubectl -n volume2 delete pvc pvc-vol 
persistentvolumeclaim "pvc-vol" deleted

╰─➤kubectl -n volume2 get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM             STORAGECLASS    VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-volume   500Mi      RWO            Retain           Released   volume2/pvc-vol   local-storage   <unset>                          17m
```

![img05.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img05.png)

5. Проверю на сервере, сохранился ли файл на локальном диске ноды:

![img06.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img06.png)

Файл присутствует в директории `/data/pvc-first`. Также при конфигурировании pv использовался режим ReclaimPolicy: Retain при котором "Retain - после удаления PV ресурсы из внешних провайдеров автоматически не удаляются". Даже после удаления pv файлы также останутся.

```bash
╰─➤kubectl -n volume2 delete pv pv-volume 
Warning: deleting cluster-scoped resources, not scoped to the provided namespace
persistentvolume "pv-volume" deleted
```
![img06.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img06.png)

6. Ссылка на манифесты:

[deployment.yaml](/devops-08-kubernetes/kubernetes-2.2-storage-part2/src/deployment.yaml)

[pv.yaml](/devops-08-kubernetes/kubernetes-2.2-storage-part2/src/pv.yaml)

[pvc.yaml](/devops-08-kubernetes/kubernetes-2.2-storage-part2/src/pvc.yaml)

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

### Решение задания 2

Создание Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Устанавливаю и настраиваю NFS-сервер на ноде с MicroK8S:

```bash
╰─➤dnf install nfs-utils -y
Последняя проверка окончания срока действия метаданных: 0:08:12 назад, Вс 02 июн 2024 10:57:22.
Зависимости разрешены.
====================================================================================================================================================
 Пакет                                  Архитектура                    Версия                                  Репозиторий                    Размер
====================================================================================================================================================
Установка:
 nfs-utils                              x86_64                         1:2.5.4-25.el9                          baseos                         429 k
Установка зависимостей:
 gssproxy                               x86_64                         0.8.4-6.el9                             baseos                         108 k
 keyutils                               x86_64                         1.6.3-1.el9                             baseos                          72 k
 libev                                  x86_64                         4.33-5.el9                              baseos                          52 k
 libverto-libev                         x86_64                         0.3.2-3.el9                             baseos                          13 k
 rpcbind                                x86_64                         1.2.6-7.el9                             baseos                          56 k

Результат транзакции
====================================================================================================================================================
Установка  6 Пакетов

Объем загрузки: 729 k
Объем изменений: 1.8 M
Загрузка пакетов:
(1/6): libev-4.33-5.el9.x86_64.rpm                                                                                  469 kB/s |  52 kB     00:00    
(2/6): libverto-libev-0.3.2-3.el9.x86_64.rpm                                                                        106 kB/s |  13 kB     00:00    
(3/6): rpcbind-1.2.6-7.el9.x86_64.rpm                                                                               447 kB/s |  56 kB     00:00    
(4/6): gssproxy-0.8.4-6.el9.x86_64.rpm                                                                              3.4 MB/s | 108 kB     00:00    
(5/6): keyutils-1.6.3-1.el9.x86_64.rpm                                                                              1.8 MB/s |  72 kB     00:00    
(6/6): nfs-utils-2.5.4-25.el9.x86_64.rpm                                                                            3.4 MB/s | 429 kB     00:00    
----------------------------------------------------------------------------------------------------------------------------------------------------
Общий размер                                                                                                        1.4 MB/s | 729 kB     00:00     
Проверка транзакции
Проверка транзакции успешно завершена.
Идет проверка транзакции
Тест транзакции проведен успешно.
Выполнение транзакции
  Подготовка       :                                                                                                                            1/1 
  Установка        : keyutils-1.6.3-1.el9.x86_64                                                                                                1/6 
  Установка        : libev-4.33-5.el9.x86_64                                                                                                    2/6 
  Установка        : libverto-libev-0.3.2-3.el9.x86_64                                                                                          3/6 
  Установка        : gssproxy-0.8.4-6.el9.x86_64                                                                                                4/6 
  Запуск скриптлета: gssproxy-0.8.4-6.el9.x86_64                                                                                                4/6 
  Запуск скриптлета: rpcbind-1.2.6-7.el9.x86_64                                                                                                 5/6 
  Установка        : rpcbind-1.2.6-7.el9.x86_64                                                                                                 5/6 
  Запуск скриптлета: rpcbind-1.2.6-7.el9.x86_64                                                                                                 5/6 
Created symlink /etc/systemd/system/multi-user.target.wants/rpcbind.service → /usr/lib/systemd/system/rpcbind.service.
Created symlink /etc/systemd/system/sockets.target.wants/rpcbind.socket → /usr/lib/systemd/system/rpcbind.socket.

  Запуск скриптлета: nfs-utils-1:2.5.4-25.el9.x86_64                                                                                            6/6 
  Установка        : nfs-utils-1:2.5.4-25.el9.x86_64                                                                                            6/6 
  Запуск скриптлета: nfs-utils-1:2.5.4-25.el9.x86_64                                                                                            6/6 
  Проверка         : libverto-libev-0.3.2-3.el9.x86_64                                                                                          1/6 
  Проверка         : rpcbind-1.2.6-7.el9.x86_64                                                                                                 2/6 
  Проверка         : libev-4.33-5.el9.x86_64                                                                                                    3/6 
  Проверка         : gssproxy-0.8.4-6.el9.x86_64                                                                                                4/6 
  Проверка         : nfs-utils-1:2.5.4-25.el9.x86_64                                                                                            5/6 
  Проверка         : keyutils-1.6.3-1.el9.x86_64                                                                                                6/6 

Установлен:
  gssproxy-0.8.4-6.el9.x86_64 keyutils-1.6.3-1.el9.x86_64 libev-4.33-5.el9.x86_64 libverto-libev-0.3.2-3.el9.x86_64 nfs-utils-1:2.5.4-25.el9.x86_64
  rpcbind-1.2.6-7.el9.x86_64 

Выполнено!

╰─➤systemctl enable --now nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.

╰─➤systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; preset: disabled)
     Active: active (exited) since Sun 2024-06-02 11:06:48 MSK; 9s ago
       Docs: man:rpc.nfsd(8)
             man:exportfs(8)
    Process: 19194 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 19195 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 19213 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
   Main PID: 19213 (code=exited, status=0/SUCCESS)
        CPU: 15ms

июн 02 11:06:48 RockyLinux9 systemd[1]: Starting NFS server and services...
июн 02 11:06:48 RockyLinux9 systemd[1]: Finished NFS server and services.


╰─➤microk8s enable community
Infer repository core for addon community
Cloning into '/var/snap/microk8s/common/addons/community'...
done.
Community repository is now enabled

╰─➤microk8s enable nfs
Infer repository community for addon nfs
Infer repository core for addon helm3
Addon core/helm3 is already enabled
Installing NFS Server Provisioner - Helm Chart 1.4.0

Node Name not defined. NFS Server Provisioner will be deployed on random Microk8s Node.

If you want to use a dedicated (large disk space) Node as NFS Server, disable the Addon and start over: microk8s enable nfs -n NODE_NAME
Lookup Microk8s Node name as: kubectl get node -o yaml | grep 'kubernetes.io/hostname'

Preparing PV for NFS Server Provisioner

persistentvolume/data-nfs-server-provisioner-0 created
"nfs-ganesha-server-and-external-provisioner" has been added to your repositories
Release "nfs-server-provisioner" does not exist. Installing it now.
NAME: nfs-server-provisioner
LAST DEPLOYED: Sun Jun  2 11:11:16 2024
NAMESPACE: nfs-server-provisioner
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NFS Provisioner service has now been installed.

A storage class named 'nfs' has now been created
and is available to provision dynamic volumes.

You can use this storageclass by creating a `PersistentVolumeClaim` with the
correct storageClassName attribute. For example:

    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: test-dynamic-volume-claim
    spec:
      storageClassName: "nfs"
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi

NFS Server Provisioner is installed

WARNING: Install "nfs-common" package on all MicroK8S nodes to allow Pods with NFS mounts to start: sudo apt update && sudo apt install -y nfs-common
WARNING: NFS Server Provisioner servers by default hostPath storage from a single Node.
```

2. Пишу манифест Deployment приложения состоящего из multitool:

Ссылка на манифест [deployment_nfs.yaml](/devops-08-kubernetes/kubernetes-2.2-storage-part2/src/deployment_nfs.yaml)

```bash
╰─➤kubectl apply -f deployment_nfs.yaml
deployment.apps/mtool created

╰─➤kubectl -n volume2 get pods
NAME                     READY   STATUS    RESTARTS   AGE
mtool-7d7dc94fc8-kqrvk   0/1     Pending   0          13s
```

![img07.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img07.png)

Так как в манифесте я указал использование NFS сервера, но еще не создал PVC, то под будет находиться в режиме ожидания.

Проверю PV, вижу, что он создан автоматически:

```bash
╰─➤kubectl -n volume2 get pv
NAME                            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                  STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
data-nfs-server-provisioner-0   1Gi        RWO            Retain           Bound    nfs-server-provisioner/data-nfs-server-provisioner-0                  <unset>                          6m7s
```

![img08.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img08.png)

Пишу манифест PVC и применяю его, а также посмотрю состояние пода:

Ссылка на манифест [pvc_nfs.yaml](/devops-08-kubernetes/kubernetes-2.2-storage-part2/src/pvc_nfs.yaml)

```bash
╰─➤kubectl apply -f pvc_nfs.yaml 
persistentvolumeclaim/pvc-vol created

╰─➤kubectl -n volume2 get pods
NAME                     READY   STATUS              RESTARTS   AGE
mtool-7d7dc94fc8-j9dh7   0/1     ContainerCreating   0          75s

╰─➤kubectl -n volume2 get pods
NAME                     READY   STATUS    RESTARTS   AGE
mtool-7d7dc94fc8-j9dh7   1/1     Running   0          94s
```

![img09.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img09.png)

При появлении PVC с именем, указанным в манифесте Deployment, под запускается и переходит в режим готовности.

3. Проверю возможность чтения и записи файла изнутри пода. Для этого войду в оболочку контейнера пода и создам файл:

```bash
╰─➤kubectl -n volume2 exec -it mtool-7d7dc94fc8-j9dh7 bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
mtool-7d7dc94fc8-j9dh7:/# cd data/
mtool-7d7dc94fc8-j9dh7:/data# ls
mtool-7d7dc94fc8-j9dh7:/data# echo "$(date) Volume test" > file.txt
mtool-7d7dc94fc8-j9dh7:/data# ls
file.txt
mtool-7d7dc94fc8-j9dh7:/data# cat file.txt 
Sun Jun  2 09:11:38 UTC 2024 Volume test
mtool-7d7dc94fc8-j9dh7:/data# 
```

![img10.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img10.png)

Через describe pv проверю, по какому пути смонтирована NFS директория:


```bash
kubectl -n volume2 describe pv
Name:            data-nfs-server-provisioner-0
Labels:          <none>
Annotations:     <none>
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    
Status:          Bound
Claim:           nfs-server-provisioner/data-nfs-server-provisioner-0
Reclaim Policy:  Retain
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        1Gi
Node Affinity:   <none>
Message:         
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /var/snap/microk8s/common/nfs-storage
    HostPathType:  
Events:            <none>


Name:            pvc-e11e2009-88ba-4240-a43e-cef5b3aaa10b
Labels:          <none>
Annotations:     EXPORT_block:
                   
                   EXPORT
                   {
                     Export_Id = 1;
                     Path = /export/pvc-e11e2009-88ba-4240-a43e-cef5b3aaa10b;
                     Pseudo = /export/pvc-e11e2009-88ba-4240-a43e-cef5b3aaa10b;
                     Access_Type = RW;
                     Squash = no_root_squash;
                     SecType = sys;
                     Filesystem_id = 1.1;
                     FSAL {
                       Name = VFS;
                     }
                   }
                 Export_Id: 1
                 Project_Id: 0
                 Project_block: 
                 Provisioner_Id: cd23e0f2-dd7b-4726-8344-5042bfef38c0
                 kubernetes.io/createdby: nfs-dynamic-provisioner
                 pv.kubernetes.io/provisioned-by: cluster.local/nfs-server-provisioner
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    nfs
Status:          Bound
Claim:           volume2/nfs-pvc
Reclaim Policy:  Delete
Access Modes:    RWX
VolumeMode:      Filesystem
Capacity:        700Mi
Node Affinity:   <none>
Message:         
Source:
    Type:      NFS (an NFS mount that lasts the lifetime of a pod)
    Server:    10.152.183.58
    Path:      /export/pvc-e11e2009-88ba-4240-a43e-cef5b3aaa10b
    ReadOnly:  false
Events:        <none>
```

Подключаюсь к серверу и перейдя в эту директорию, то можно увидеть созданный из контейнера пода файл:


```bash
╰─➤cd /var/snap/microk8s/common/nfs-storage/pvc-e11e2009-88ba-4240-a43e-cef5b3aaa10b/

╰─➤ls
file.txt

╰─➤cat file.txt 
Sun Jun  2 09:11:38 UTC 2024 Volume test
```

![img11.png](/devops-08-kubernetes/kubernetes-2.2-storage-part2/img/img11.png)

Это говорит о том, что NFS работает и из пода файл доступен для чтения и записи.

4. Ссылка на манифесты:

[deployment_nfs.yaml](/devops-08-kubernetes/kubernetes-2.2-storage-part2/src/deployment_nfs.yaml)

[pvc_nfs.yaml](/devops-08-kubernetes/kubernetes-2.2-storage-part2/src/pvc_nfs.yaml)

------
