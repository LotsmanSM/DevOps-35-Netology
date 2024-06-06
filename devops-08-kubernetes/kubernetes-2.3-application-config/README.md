# Домашнее задание к занятию «Конфигурация приложений»

### Цель задания

В тестовой среде Kubernetes необходимо создать конфигурацию и продемонстрировать работу приложения.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8s).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым GitHub-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/configuration/secret/) Secret.
2. [Описание](https://kubernetes.io/docs/concepts/configuration/configmap/) ConfigMap.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу

1. Создать Deployment приложения, состоящего из контейнеров nginx и multitool.
2. Решить возникшую проблему с помощью ConfigMap.
3. Продемонстрировать, что pod стартовал и оба конейнера работают.
4. Сделать простую веб-страницу и подключить её к Nginx с помощью ConfigMap. Подключить Service и показать вывод curl или в браузере.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

### Решение задания 1. Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу

1. Пишу Deployment приложения, состоящего из контейнеров nginx и multitool.

Применяю манифест [deployment.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/deployment.yaml) и вижу, что один из контейнеров пода не запустился:

```bash
╰─➤kubectl create namespace config-test
namespace/config-test created

╰─➤kubectl apply -f deployment.yaml
deployment.apps/nginx-multitool created

╰─➤kubectl -n config-test get pods
NAME                               READY   STATUS              RESTARTS   AGE
nginx-multitool-69dd69d59c-kcdgs   2/2     ContainerCreating   0          95s
```

![img01.png](/devops-08-kubernetes/kubernetes-2.3-application-config/img/img01.png)

2. Причина заключается в том, что стандартный порт, который используется в multitool уже занят, поэтому нужно использовать альтернативный порт. Этот альтернативный порт укажу в виде переменной `HTTP_PORT` в ConfigMap и укажу значение переменной равное `1180`.

3. Применю манифест [configmap.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/configmap.yaml) и проверю изменилось ли состояние контейнера multitool в созданном поде:

```bash
╰─➤kubectl apply -f configmap.yaml 
configmap/multitool-maps created

╰─➤kubectl -n config-test get pods
NAME                               READY   STATUS    RESTARTS   AGE
nginx-multitool-69dd69d59c-kcdgs   2/2     Running   0          95s
```

![img02.png](/devops-08-kubernetes/kubernetes-2.3-application-config/img/img02.png)

Контейнер запустился, так как проблемная ситуация с портом контейнера была устранена.

4. Сделаю простую веб-страницу и подключу её к Nginx с помощью ConfigMap. Для этого модернизирую Deployment, добавив в него volumeMounts ссылающийся на путь по умолчанию для nginx, где находится индексная страница - /usr/share/nginx/html/, а также сошлюсь на сам ConfigMap. Подключаю Service и применяю ConfigMap.

Применяю манифест [deployment.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/nginx_service.yaml) и проверю, покажет ли nginx из контейнера пода созданную мной простую индексную страницу:

```bash
╰─➤kubectl apply -f service.yaml
service/nginx-multitool-svc created

╰─➤kubectl -n config-test exec nginx-multitool-69dd69d59c-kcdgs -- curl nginx-multitool-svc:80
Defaulted container "nginx" out of: nginx, multitool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<html>
<h1>Welcome</h1>
</br>
<h1>Hi! This is a configmap Index file </h1>
</html>
100    83  100    83    0     0  88675      0 --:--:-- --:--:-- --:--:-- 83000
```

![img03.png](/devops-08-kubernetes/kubernetes-2.3-application-config/img/img03.png)

Текст индексной страницы, написанной мной в ConfigMap и текст индексной страницы из контейнера пода одинаковы, следовательно она взята именно из содержимого ConfigMap.

5. Ссылка на манифесты:

[deployment.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/deployment.yaml)

[service.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/service.yaml)

[configmap.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/configmap.yaml)


------

### Задание 2. Создать приложение с вашей веб-страницей, доступной по HTTPS 

1. Создать Deployment приложения, состоящего из Nginx.
2. Создать собственную веб-страницу и подключить её как ConfigMap к приложению.
3. Выпустить самоподписной сертификат SSL. Создать Secret для использования сертификата.
4. Создать Ingress и необходимый Service, подключить к нему SSL в вид. Продемонстировать доступ к приложению по HTTPS. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

### Решение задания 2. Создать приложение с вашей веб-страницей, доступной по HTTPS 

1. Пишу манифест [nginx_deployment.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/nginx_deployment.yaml) приложения, состоящего из Nginx

```bash
╰─➤kubectl apply -f nginx_deployment.yaml 
deployment.apps/myapp-pod created
```

2. Создаю собственную веб-страницу и подключаю её как [nginx_configmap.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/nginx_configmap.yaml) к приложению. В Deployment ссылаюсь на имя, указанное в ConfigMap.

```bash
╰─➤kubectl apply -f nginx_configmap.yaml 
configmap/index-html-configmap created
```

3. Выпускаю самоподписной сертификат SSL:

```bash
╰─➤openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout certs/tls.key -out certs/tls.crt -subj "/CN=my-app.com" -days 365
...+....+...+...+..............+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*...+....+......+..+.........+....+..+....+...+..+......+.......+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*...+.........+.......+........+....+...+...............+...................................+....+....................+.+.....+...+...................+...........+......+......+....+.........+..+...+....+...+..+.+...........+...+.+....................+.+...........+....+......+...+..+...+............+.......+.....+...+............+......+...............+......+.+............+........+.........+......+.......+..+.+..+......................+.....................+..+.......+.....+.........+.+...+............+......+............+...+..+...+....+.....+...+.+.........+...+........+......+.+........................+.....+...............+.+.................+...............+.............+..+......+.+..............+................+...........+.........+................+............+.....+.+....................+.........+.......+.....+.+...+......+...........+...+....+......+.....+....+..+.+.........+...+............+......+..................+...........+.+..+......+.......+..+..........+...........+......+....+..+....+...+..+....+.....+....+......+.....+......+...+.......+...........+..........+.........+......+....................+....+...+.....+...+.......+.....+.+...........+.+..+...........................+......+...+.+...+..+......+.......+..+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
...........+...+.+.....+.+.....+..........+.....+.+............+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*..................+...+.....+.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.....+...........+.+...+.....+......+.+...............+..+...+...+.+..............+......+.+.....+.......+........+..........+.........+.....+.+..+.+.....+..........+.........+...+........+.+...........+............+.+.........+........+..........+...+..+...+.......+..+.+.................+.........+...............+.............+.....+.+..+.........+....+.........+...+.....+...+.........+.+.....+.......+..+......+.+..............+.......+........+............+..................+.+.........+...........+...+.+.....+.+........+...+.........+..........+..................+......+..............+...+..........+.........+...+...+..+.+..............+.........................+......+.....+......+.+.........+..........................+.......+......+...............+..+............+......+......+.....................+...............+........................+.+..+......+......+...+.......+...+............+....................+......+.............+.....+.+......+..+.+.............................+......+.+...............+.....+.+........+....+...+..+...+............+..........+............+...............+......+.....+.........+..........+...+..+......+.......+..+...+...+...................+......+.........+..............+.........+......+....+...+........+.......+........+.......+....................+...+............+.............+.....+......+.+..+......+.........+...+.............+.........+......+......+..............................+.....+....+............+..+...+.........+...+...+....+..................+...+.........+.....+......+...+.......+..+.............+...+.....+.+.....+.+.........+...........+.............+.........+.................+..................+.+.....+.+.........+...................................+.......+..............+.+..+................+.....+.+...........+.......+.....+.......+......+...+......+........+...+........................+....+......+...+.....+.+..+..................+.......+...+............+....................+...+.+.....+................+.................+.+......+......+.....+..........+...+.....+............+....+.....+.+.........+..............+.......+...+......+.....+.........+....+...+...............+..............+...............+.+........+..........+.....................+...+.....+...+.......+......+..+....+...+............+......+.....+...+....+...............+..+......+.......+.....+................+.....+....+...+.........+...............+.....+...+...+...+....+.....+......+......+..................+................+..............+...+....+.....+.+........+.+.....+...+.+............+............+......+..+.........+..........+...+............+...+...........................+...........+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-----
```

![img04.png](/devops-08-kubernetes/kubernetes-2.3-application-config/img/img04.png)

[tls.crt](/devops-08-kubernetes/kubernetes-2.3-application-config/src/certs/tls.crt)

[tls.key](/devops-08-kubernetes/kubernetes-2.3-application-config/src/certs/tls.key)

4. Создаю [nginx_ingress.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/nginx_ingress.yaml) и необходимый [nginx_service.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/nginx_service.yaml), подключаю к нему SSL. 

```bash
╰─➤kubectl -n config-test apply -f nginx_ingress.yaml 
ingress.networking.k8s.io/my-ingress created

╰─➤kubectl -n config-test get ingress
NAME         CLASS    HOSTS        ADDRESS        PORTS     AGE
my-ingress   public   my-app.com   192.168.49.2   80, 443   25s
```

 Создаю Secret для использования сертификата:

```bash
╰─➤kubectl create secret tls my-app-secret-tls --namespace config-test --cert=certs/tls.crt --key=certs/tls.key
secret/my-app-secret-tls created

╰─➤kubectl get secret -o yaml
apiVersion: v1
items:
- apiVersion: v1
  data:
    tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZDekNDQXZPZ0F3SUJBZ0lVQSsydGx4R1J0NDNadExHSXpyWncwaDNrSmVVd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0ZURVRNQkVHQTFVRUF3d0tiWGt0WVhCd0xtTnZiVEFlRncweU5EQTJNRFV5TURBek16TmFGdzB5TlRBMgpNRFV5TURBek16TmFNQlV4RXpBUkJnTlZCQU1NQ20xNUxXRndjQzVqYjIwd2dnSWlNQTBHQ1NxR1NJYjNEUUVCCkFRVUFBNElDRHdBd2dnSUtBb0lDQVFDcXpkSjJpeE1hWkptSHpBWUNobmRNbFk4TS9WdVc1eWFEamcvc3pyOFAKQVZXS0ZqVzhJU0x3TnhUVU0vT0hFak5DeE5UVGtiakthbWhCOTJvekVsT2tqcE9pSTh1eUM2YUgwaTIvNmxhdwpLekFFRTFlMGFydkJ1NWFxTmF6UDFyQ2I0VTRhbXZaTWJva3ZjK0J6Y2Z6UFJib1Rya1U5WEJTYW0xVjFGVzZ2CnNNVUd0K24zajRtdGdOaHNFQlY2MFpveHhPRVdIbUx1cjJpMFVkNVBheCszVm5rVEFmckVCUkdvZklFTC9HTTkKTGNLWmY5MHNwaFJUNjBpRVVhR3MrVlowMDBBWmZGdzdlOVlzRDFYY3o3SWp6Ylh2MzErY1ZINUIybUVhNFRiNQpMclVjVXRCbithNnR5alA4S1Yxd29rRDdONy95UHF3cFdEYUM4cjJZS0tjWmlTYU9iRXUvdDRJMjZyUnBxeVpNClRXRE5vSHcrdXR4RklESHlVMndnSERUek5zR2JvaHFrak45Ym83NmlpZDBPYksyZ1ptak5LUUZoaEFSYmZqMVEKREhlNmd1RGt1bVZKZkZhT2hXN2krdUtTZitLM0l6RVBwUEh0TCs2NnFsNnZNcjlNMVRzbFpKUWxPelhEWnJJaApPcTFZdXdwY2NGa29Xa3Jycy90NlA5ZzhERk1VL2x0M1ZSUnR5ellMaGlKV2tCeHdLTk9FOTRZRlpVaFdRMHZPCnJDZ3JabE5MYVR4LytHYzc1b2lvM3RqdUQyQ1NzcnZNYSs1VkdMT0V4R2d0elpoOHozbUp5bHpEOXNGWjM5UE0KVjNIb0JsMElzdWcvVkJUejNYUFVvUW1aMVJoOUEwdnBvdTVxWEFtVTdObFBXdFZUZmVxdHpxdFFPbk5NYkVCRApKUUlEQVFBQm8xTXdVVEFkQmdOVkhRNEVGZ1FVcEMydDRGVmFWa2cwTUVlb1BCVVp1QkppcEg4d0h3WURWUjBqCkJCZ3dGb0FVcEMydDRGVmFWa2cwTUVlb1BCVVp1QkppcEg4d0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBTkJna3EKaGtpRzl3MEJBUXNGQUFPQ0FnRUFJbUFBMDdLTnNkU0FsTFgyU0J3UXE5elg1ME5JSlBTZndySk1IM3BOdjN1VAprZkFJMVk5Z25XS0I3bEhUZ280aVQwTDhCTXdnMkR5TitwR1hwV05teEtlNnlZVGR4VDdYaWZpVnpWbm5YMURCClV2Z3ExRm1hbzBtSXhiU1JPODFLSkxMTCtYTGVodlVIOUg0RDNKdUtIaE1uSHI5ZG0vNnR2TGNHSjB0L3N3ZnQKUThJSjJyOFdWdEY5ZVY0RlhCWEdkampZY2E2MjZsYThwTW44ZXo4WG8vcG9vOWdrM2ZkQiszbGk0eDEyS1pWSwpTbVlja04zRHFFMkxZL2FsYmJwY3VQUVA4bExsNTB4L0xycU9KcjRxeGc1ZmxhQ04za3VjZGlka2ZRVmg0UXhMCjgwTUR4U1dzYXBaTFhJRE90MXNBdnhPRDNnemMvZ3BRQUZOOVoyVkRDSUIybzNjR0VoNHVVRDdPUFUrcDV4MU0KdDVQRXpucWJRbTJFb0xFL0d6am56U0FNNjFjTThBT3JjRmFYTlB6UVI3S1cxb2MxdWJPZjBqVDRtS2d0K1lGSQpUZnFsTlNSRzBJRHBXRDFuYmtlMTk1RXFyUmh3SWR0ZVkyYjJhYWgrMnFLSEd1VkpLZmhMK1ZrOWhXWW1iVEF4ClhBb2l6K091WlFHSG5lWE91Vkl0OGFhWVpWODhOMnJPeHVYT1ZsVUp5Q2pZcElyT2pybWZ3UHRzcUpaWGtmcDMKczhSRzNjYjMvUFlLUDdTdWNBT3psL1VMbCtXazVWWGJlTXl3M1ZBQ1J6dkowdXBxK01TNjkwK2wzS3ZXZ1ZXUwpMRVkzY29HTFVva0RsZjFsNTJFVW1YNHlMVTVMT0ZCZ29STnVTQkdTWCtXYS9IWGc5cnlBRUJzeDNXVGFhUXc9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRZ0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1N3d2dna29BZ0VBQW9JQ0FRQ3F6ZEoyaXhNYVpKbUgKekFZQ2huZE1sWThNL1Z1VzV5YURqZy9zenI4UEFWV0tGalc4SVNMd054VFVNL09IRWpOQ3hOVFRrYmpLYW1oQgo5Mm96RWxPa2pwT2lJOHV5QzZhSDBpMi82bGF3S3pBRUUxZTBhcnZCdTVhcU5helAxckNiNFU0YW12Wk1ib2t2CmMrQnpjZnpQUmJvVHJrVTlYQlNhbTFWMUZXNnZzTVVHdCtuM2o0bXRnTmhzRUJWNjBab3h4T0VXSG1MdXIyaTAKVWQ1UGF4KzNWbmtUQWZyRUJSR29mSUVML0dNOUxjS1pmOTBzcGhSVDYwaUVVYUdzK1ZaMDAwQVpmRnc3ZTlZcwpEMVhjejdJanpiWHYzMStjVkg1QjJtRWE0VGI1THJVY1V0Qm4rYTZ0eWpQOEtWMXdva0Q3TjcveVBxd3BXRGFDCjhyMllLS2NaaVNhT2JFdS90NEkyNnJScHF5Wk1UV0ROb0h3K3V0eEZJREh5VTJ3Z0hEVHpOc0dib2hxa2pOOWIKbzc2aWlkME9iSzJnWm1qTktRRmhoQVJiZmoxUURIZTZndURrdW1WSmZGYU9oVzdpK3VLU2YrSzNJekVQcFBIdApMKzY2cWw2dk1yOU0xVHNsWkpRbE96WERackloT3ExWXV3cGNjRmtvV2tycnMvdDZQOWc4REZNVS9sdDNWUlJ0Cnl6WUxoaUpXa0J4d0tOT0U5NFlGWlVoV1Ewdk9yQ2dyWmxOTGFUeC8rR2M3NW9pbzN0anVEMkNTc3J2TWErNVYKR0xPRXhHZ3R6Wmg4ejNtSnlsekQ5c0ZaMzlQTVYzSG9CbDBJc3VnL1ZCVHozWFBVb1FtWjFSaDlBMHZwb3U1cQpYQW1VN05sUFd0VlRmZXF0enF0UU9uTk1iRUJESlFJREFRQUJBb0lDQUFJU1FHYmhIV0J3ejE3UzlkQ3loa0JXCndQY1luSE42UnFDS1NMMm5yUy8ycFcycEFzcFBBWkExcnNvNi9nMUpobmNkRVhLbVhmNFFaOGJEQkJYdDl6Y3oKNW16dEw3TnZTanZ6Njh1YndTVGVSVFVMY2dFVldVVUtiQk9RMXBGbnFsa2RsSmVrZ08rZzJJZUxpWEdFOUpxagozeE9OaGJmdWhhNXhTMHBCOGdkdDVwbkVBYkdYbTBVUUhxL0N5eXZqM2xHVHNHSVhDTDZad0hTTldKdVFja0JFCkszQTBVakR0MmM2NEFjMmVLQ3J1QXVIZko5UzZoOTBUcVp1M0xMVi9DWklkbkxXaWFURHNlY2FyZ2ZCTlVYejMKS2Vsb2hVMk5SY0d4THdQSEx1WTdMNFdTS0laV1JBekYrcmJvWG9KMjZVQlNwd0IrUzVLdHgrMXpHYUwrZlRaQQpQZkJPdFVMVkRsVFlmUWtHSUVvMVQ3bGtwRmh6ZWhJUU1RMWpWaFBGYTBYRFIvNlA1d3EzTUFDcmZ6T2MvT2hUCi9OSmVxZHZwbVQ2T0dNd1JtczVRVzcrWXlqZEhGT0Rva0k5TzJRdDNPenNwMkZNWEFnOXByOElVbGtRbUtWTWgKTE8vOHV6MlhHYk1tOHBTQWpqMGtIK1J2ZkJ1MmdWOTB0NEk1RWpXTTluTTZCbkIxdU53b1ltUllBRDM0UFZSdwp3NkhzUkZtejd1MTlPS0w4d1gvNEFmQ1hqMHNZRGc1cFJ0SFgrWlhrNUl4ckxvR2FhK2U1ckFrdjBTYjVaRkowCkp0TlNQQVZreHJjdUtqYjUyOXZ1WDgzdXMvQTVnSThlQm9oR0hHYlhrNStsME1zeWk5bjlsWVlyOWRTRGZidVAKN0JYZE1XU2x3blB0NnZ5aVF2ejVBb0lCQVFEUkdlRHhRSlVudGpPVXNIWkY2dEUxbVpkMWM4Slh3Uk1GM1FwMApDN2JOMGo5YnZNQmFVd1FOWGpMVkE1c3I0bG5oWjY1V1pHUFN6cks3bU9GU0RCenlGcURjSTd5Um9yL2pBMUFJCnVBVFRFSTI4UHBaK3cvZ1NvL3g2Z3ZWWnppWEVaVnNrUHd6MlJsNXNLWDEwbExVVUxlZWY5MW9ObHpnVzQ1MWkKUCtFc21xbi9RdmsyWUo2VG4xM2tyQ2RROEFnTGIzS252U1NEVExsWU9RRlh6MEdxNlplNTFKM0RwSEg4blNBcQp0UGlNSUNDMitMaCtPQm40QXFNM2xwdlRPQ0JNekVVNmIvSC9hYjA0bnVkUzR4bGdWTlhyZlgyK0VNSityUDAvCk8yZUV2QXBaVENzSWFhNko2WXFJWEo5a0ZsMFhURmFDS0QvdmJFcThUZVJ2YU91TkFvSUJBUURSSFFKUGRLVkQKOTRlenlmZGVzR0dJWVBSLy9vMElnVFpkOERneUFvK2praE5EdENNUWdQY25RVzFCeEVFTGd2QXJQQ3JDWlFWcQpIbGNPMld6L1lORnpHZ0lMVEhuTXZ2OVpqbzNXWTlLTkQ5RmN6MlJycjQyMU11Q1NoV0lnZjE3K0VyUmEwNUVJCmdNQVQwekhadDd0dk5Fb1d5c3JJMXd5cE0vSzdrYThWcC9mWTA3ZU5RSXJpOE93RTgyU29HRHp1eWV1VUtrYnEKWmNZVmppMXFQaEdpQWpxY0JmOUZaUUt1ejNjSjRiNHVWMnhsTzk5aDJXbWhWY3ZiWGVJVlArTFUzQ3VsQ0d5ZApRU2NuVnFwQXB3Q3VQV3pIRmE1b2VFTzJNWUtjWkdqdUZ6WkhFaUpiMHYvRTNMQlI4WlBwSjhBMHE1cVJpa1dQCkFldUdFSno1MG9QNUFvSUJBQ2ljNXlUVWoyUFVMcmFOZzV0VzNXV1V2R2N5b2FlYnQ0OG0vSlhIaEt6N1RoVUsKVnkzeis5Q0E0RXloVTYwMVhKRzhLbzliRmt4bW15NTJwaVRpZDJqSjNscURrbWVTL2NRZzY1V1Y4Rkh5WUNVVQozdlFtS2ZPczZDZi9jWm9Nd1NjaExJK2dzMnJPQmg3cC9CVDlvU0lYUEdyRWh6Z21pOTFlUGo1TCsvZEczd2ZXClFVTS9odTFUUWRCZFk1R0QzWHdqSEZqYUV0Snh2M29VTUYrV3dNRnFkMjYvamhqbXdzRDIzNzJMd3M2c21zNFAKQnY1MDlRNUhyTjNxSWIvbm9kWm93blYwTXNPU0RRK0hSWlRDeVRYOXBFTUY3N3RQMUFiNG9JTjhqVUdwcURUcAo1MTNOOFBtV1k3TFNrcDdFL1RXK1BQc3d5Q0kvblZCdnJKTzdCQzBDZ2dFQkFLMlBBQzNtU0l6QzA1UzdXbDd5CjBlQ1phQlVidHY2S0VBK2pvMkNPazUxVlRqdnhOUEVydVBhUjdSYWF4c25CSVlrZzVQUjNXQ2tkaVhBL3NhRzgKUDlyaWlUUExnNFFXT21XZ1ZjVE5FU0lYTU5OeEpvM2lKU0Z4V3NjQmdkSXJKVEtIWDczS3Z5TnBpUUpyVllLNApaZzhFUFVIeGlxRnJLNHo4R3NqblA0UWY1eXZGZlNEMW90QjgyY2U2STU4SWp2bzZDUmJ1aC9GZ0N5bzAyU2pHCjMyZXhwZWQ5YXNPejlLZ1dkVngwU3A2MzNMV2hIZVJleUxjcE9JdVh2bCtZcUxHM0UxcGtSWkczVThIb3dtSHEKdWp2anEzY0pYYnBEcHg5K3RFTU5hN0hBL2tHNm9WM0pJSlBKLzJYanRibmNUa0RvOU44Ni9rU1ZlVi9LUmg5cgpSREVDZ2dFQVBNVUtaNkt0QXM2TkdJNEc4b1lSVU9yeUpVbmtGZmNzQzJZZTlpYkc2aGJmdXYyUHl1WTVzdWdkCmtYUWJGajVQd0JXVHJUcnh4UlR6ZGQrbldRaDFBRUtVdjh3c3gyZk5GL0J0VGNCVFdCTmJocWpJUnpkQjRqc2gKQzdpRnd0amhiZ3FiYWt3N2t4WDdRTUw2YUFLT1RJYXJqMjJsdjd3U0h2ODJBd1VTZHFkQ3BKMit6VFI1VDBSdwo0VWl3RmZQZFdhOUFrVTlhdkh3UlFDTVpOQ3hUZ0R3WDd6M2xETFVJVFZhbjFzb2drS2p1cVlmYjZuaEw5VDFYCkprTzYrdTN1bFB3TGlib0hDYXMyb3FCS3BQd080MzVaRWd5WXlKSFJzczh6T2JaSFVYeUVTTkhmYnFPbVpVRU8Kcnl3U1FQQjcxako1bHpjNmVSVUFQbG9KL1k4dWNBPT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=
  kind: Secret
  metadata:
    creationTimestamp: "2024-06-05T20:18:27Z"
    name: my-app-secret-tls
    namespace: default
    resourceVersion: "1191496"
    uid: 06d8763c-c218-4a4c-8aeb-dde6ad8dcc2d
  type: kubernetes.io/tls
kind: List
metadata:
  resourceVersion: ""
```

Применяю манифест [nginx_service.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/nginx_service.yaml)

```bash
╰─➤kubectl -n config-test apply -f nginx_service.yaml 
service/myservice created

╰─➤kubectl -n config-test get svc
NAME        TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
myservice   NodePort   10.152.183.222   <none>        80:32000/TCP   84s

╰─➤kubectl -n config-test get pods
NAME                         READY   STATUS    RESTARTS   AGE
myapp-pod-6555dff9d4-8khxr   1/1     Running   0          10m

╰─➤kubectl -n config-test get deployment
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
myapp-pod   1/1     1            1           10m

╰─➤ubectl -n config-test get ingress
NAME         CLASS    HOSTS        ADDRESS        PORTS     AGE
my-ingress   public   my-app.com   192.168.49.2   80, 443   10m

╰─➤kubectl -n config-test get node
NAME          STATUS   ROLES    AGE   VERSION
rockylinux9   Ready    <none>   30d   v1.29.4

╰─➤kubectl -n config-test get cm
NAME                   DATA   AGE
index-html-configmap   1      12m
kube-root-ca.crt       1      12m
```

Создаю dns запись `192.168.49.2    my-app.com` в файле `/etc/hosts`

![img05.png](/devops-08-kubernetes/kubernetes-2.3-application-config/img/img05.png)

```bash
╰─➤curl -k https://my-app.com
<html>
<h1>Welcome</h1>
</br>
<h1>Hi! This is a configmap Index file </h1>
</html
```

![img06.png](/devops-08-kubernetes/kubernetes-2.3-application-config/img/img06.png)

![img07.png](/devops-08-kubernetes/kubernetes-2.3-application-config/img/img07.png)

5. Ссылка на манифесты:

[nginx_deployment.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/nginx_deployment.yaml)

[nginx_configmap.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/nginx_configmap.yaml)

[nginx_service.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/nginx_service.yaml)

[nginx_ingress.yaml](/devops-08-kubernetes/kubernetes-2.3-application-config/src/nginx_ingress.yaml)

------



kubectl -n config-test get secrets
kubectl -n config-test get svc
kubectl -n config-test get pods
kubectl -n config-test get deployments
kubectl -n config-test get ingress
kubectl -n config-test get cm
