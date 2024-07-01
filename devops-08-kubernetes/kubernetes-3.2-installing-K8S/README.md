# Домашнее задание к занятию «Установка Kubernetes»

### Цель задания

Установить кластер K8s.

### Чеклист готовности к домашнему заданию

1. Развёрнутые ВМ с ОС Ubuntu 20.04-lts.


### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция по установке kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
2. [Документация kubespray](https://kubespray.io/).

-----

### Задание 1. Установить кластер k8s с 1 master node

1. Подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды.
2. В качестве CRI — containerd.
3. Запуск etcd производить на мастере.
4. Способ установки выбрать самостоятельно.

### Решение задания 1. Установить кластер k8s с 1 master node

С помощью `Terraform` разворачиваю 5 VM c Ubuntu 22.04 

[Код Terraform](./src/terraform1/)

```bash
╰─➤ terraform apply
```

```bash
╰─➤ yc compute instance list
+----------------------+----------+---------------+---------+-----------------+-------------+
|          ID          |   NAME   |    ZONE ID    | STATUS  |   EXTERNAL IP   | INTERNAL IP |
+----------------------+----------+---------------+---------+-----------------+-------------+
| fhm4i7f1uq8l2rtvpi6q | worker-1 | ru-central1-a | RUNNING | 158.160.99.208  | 10.0.1.23   |
| fhmaf1378fc8glb9b4um | master-1 | ru-central1-a | RUNNING | 158.160.35.78   | 10.0.1.31   |
| fhmd9fmfbi0djn7r82lu | worker-4 | ru-central1-a | RUNNING | 158.160.44.189  | 10.0.1.16   |
| fhmf97hqkn8ao2ud4fb0 | worker-2 | ru-central1-a | RUNNING | 158.160.116.206 | 10.0.1.4    |
| fhmh97hn37mr8bcacchq | worker-3 | ru-central1-a | RUNNING | 158.160.123.172 | 10.0.1.6    |
+----------------------+----------+---------------+---------+-----------------+-------------+
```

Клонирую репозиторий `kubespray`

```bash
╰─➤ git clone https://github.com/kubernetes-sigs/kubespray
Клонирование в «kubespray»...
remote: Enumerating objects: 74821, done.
remote: Counting objects: 100% (602/602), done.
remote: Compressing objects: 100% (386/386), done.
remote: Total 74821 (delta 286), reused 410 (delta 196), pack-reused 74219
Получение объектов: 100% (74821/74821), 23.75 МиБ | 11.01 МиБ/с, готово.
Определение изменений: 100% (42168/42168), готово.
```
Запускаю разворачивание Kubernetes кластера из репозитория Kubespray.

```bash
╰─➤ ansible-playbook -i inventory/mycluster/hosts.yaml -u ubuntu --become --become-user=root --private-key=~/.ssh/id_ed25519 -e 'ansible_ssh_common_args="-o StrictHostKeyChecking=no"' cluster.yml --flush-cache
```

Проверю, работает ли Kubernetes кластер:

```bash
╰─➤ 
```



## Дополнительные задания (со звёздочкой)

**Настоятельно рекомендуем выполнять все задания под звёздочкой.** Их выполнение поможет глубже разобраться в материале.   
Задания под звёздочкой необязательные к выполнению и не повлияют на получение зачёта по этому домашнему заданию. 

------
### Решение задания 2*. Установить HA кластер

1. Установить кластер в режиме HA.
2. Использовать нечётное количество Master-node.
3. Для cluster ip использовать keepalived или другой способ.

### Задание 2*. Установить HA кластер

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl get nodes`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
