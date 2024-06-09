# Домашнее задание к занятию «Helm»

### Цель задания

В тестовой среде Kubernetes необходимо установить и обновить приложения с помощью Helm.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение, например, MicroK8S.
2. Установленный локальный kubectl.
3. Установленный локальный Helm.
4. Редактор YAML-файлов с подключенным репозиторием GitHub.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://helm.sh/docs/intro/install/) по установке Helm. [Helm completion](https://helm.sh/docs/helm/helm_completion/).

------

### Задание 1. Подготовить Helm-чарт для приложения

1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 
2. Каждый компонент приложения деплоится отдельным deployment’ом или statefulset’ом.
3. В переменных чарта измените образ приложения для изменения версии.

### Решение задания 1. Подготовить Helm-чарт для приложения

1. Для начала установлю на ноду Helm используя скрипт:

```bash
╰─➤ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

╰─➤ chmod 700 get_helm.sh

╰─➤ ./get_helm.sh
Downloading https://get.helm.sh/helm-v3.15.1-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
[sudo] пароль для serg: 
helm installed into /usr/local/bin/helm

╰─➤ helm version
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/serg/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/serg/.kube/config
version.BuildInfo{Version:"v3.15.1", GitCommit:"e211f2aa62992bd72586b395de50979e31231829", GitTreeState:"clean", GoVersion:"go1.22.3"}
```
Cценарий автозаполнения Helm для оболочки bash. В текущем сеансе оболочки:

```bash
╰─➤source <(helm completion bash)
```
Для каждого нового сеанса:

```bash
╰─➤ helm completion bash > /etc/bash_completion.d/helm
```

Создаю собственный helm chart с именем `myhelm-grafana`:

```bash
╰─➤helm create myhelm-grafana
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/serg/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/serg/.kube/config
Creating myhelm-grafana
```

2 - 3. Создаю два файла Values - [values_dvl.yaml](/devops-08-kubernetes/kubernetes-2.5-helm/src/myhelm-grafana/values_dvl.yaml) и [values_test.yaml](/devops-08-kubernetes/kubernetes-2.5-helm/src/myhelm-grafana/values_test.yaml) для DEVELOP и TEST окружения, дописываю в них необходимые параметры для запуска Grafana, такие как имя образа, тег, порт. Приложения будут развернуты отдельными Deployment.

------
### Задание 2. Запустить две версии в разных неймспейсах

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.
2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.
3. Продемонстрируйте результат.

### Решение задания 2. Запустить две версии в разных неймспейсах

1 - 3. Создам отдельный Namespace с именем app1, запущу обе версии приложения в этом Namespace:

```bash
╰─➤kubectl create namespace app1
namespace/app1 created

╰─➤helm install grafana-test myhelm-grafana/ --values myhelm-grafana/values_test.yaml -n app1
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/serg/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/serg/.kube/config
NAME: grafana-test
LAST DEPLOYED: Sun Jun  9 18:48:32 2024
NAMESPACE: app1
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace app1 -l "app.kubernetes.io/name=myhelm-grafana,app.kubernetes.io/instance=grafana-test" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace app1 $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app1 port-forward $POD_NAME 8080:$CONTAINER_PORT

╰─➤helm install grafana-dvl myhelm-grafana/ --values myhelm-grafana/values_dvl.yaml -n app1
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/serg/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/serg/.kube/config
NAME: grafana-dvl
LAST DEPLOYED: Sun Jun  9 18:48:48 2024
NAMESPACE: app1
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace app1 -l "app.kubernetes.io/name=myhelm-grafana,app.kubernetes.io/instance=grafana-dvl" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace app1 $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app1 port-forward $POD_NAME 8080:$CONTAINER_PORT
```

Проверю результат:

```bash
╰─➤helm list -n app1
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/serg/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/serg/.kube/config
NAME        	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART               	APP VERSION
grafana-dvl 	app1     	1       	2024-06-09 18:48:48.916658369 +0300 MSK	deployed	myhelm-grafana-0.1.0	1.16.0     
grafana-test	app1     	1       	2024-06-09 18:48:32.469372644 +0300 MSK	deployed	myhelm-grafana-0.1.0	1.16.0

╰─➤kubectl -n app1 get deployment
NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
grafana-dvl-myhelm-grafana    1/1     1            1           110s
grafana-test-myhelm-grafana   1/1     1            1           2m7s
```

![img01.png](/devops-08-kubernetes/kubernetes-2.5-helm/img/img01.png)

Приложения действительно развернуты с помощью Helm в виде отдельных Deployments.

Разверну еще одну версию приложения, но уже в Namespace app2:

```bash
╰─➤kubectl create namespace app2
namespace/app2 created

╰─➤helm install grafana-prepod myhelm-grafana/ --values myhelm-grafana/values_preprod.yaml -n app2
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/serg/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/serg/.kube/config
NAME: grafana-prepod
LAST DEPLOYED: Sun Jun  9 18:53:05 2024
NAMESPACE: app2
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace app2 -l "app.kubernetes.io/name=myhelm-grafana,app.kubernetes.io/instance=grafana-prepod" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace app2 $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app2 port-forward $POD_NAME 8080:$CONTAINER_PORT

╰─➤helm list -n app2
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/serg/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/serg/.kube/config
NAME          	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART               	APP VERSION
grafana-prepod	app2     	1       	2024-06-09 18:53:05.728073753 +0300 MSK	deployed	myhelm-grafana-0.1.0	1.16.0

╰─➤kubectl -n app2 get deployment
NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
grafana-prepod-myhelm-grafana   1/1     1            1           47s
```

![img02.png](/devops-08-kubernetes/kubernetes-2.5-helm/img/img02.png)

Приложение также успешно развернуто.

Между собой приложения отличаются версиями образов, указанных в тегах.

Для проверки работоспособности Grafana проброшу порт и проверю, откроется ли Web-интерфейс приложения:

```bash
╰─➤export POD_NAME=$(kubectl get pods --namespace app2 -l "app.kubernetes.io/name=myhelm-grafana,app.kubernetes.io/instance=grafana-prepod" -o jsonpath="{.items[0].metadata.name}")

╰─➤export CONTAINER_PORT=$(kubectl get pod --namespace app2 $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")

╰─➤kubectl --namespace app2 port-forward $POD_NAME 8080:$CONTAINER_PORT
Forwarding from 127.0.0.1:8080 -> 3000
Forwarding from [::1]:8080 -> 3000
Handling connection for 8080
Handling connection for 8080
```

![img03.png](/devops-08-kubernetes/kubernetes-2.5-helm/img/img03.png)

![img04.png](/devops-08-kubernetes/kubernetes-2.5-helm/img/img04.png)

Запустилась последняя на данный момент версия Grafana v11.1.0, что соответствует указанному в файле переменных `values_preprod.yaml` тегу `main`.
