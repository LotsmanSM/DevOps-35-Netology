# Домашнее задание к занятию «Введение в Terraform»

### Чек-лист готовности к домашнему заданию

1. Скачайте и установите **Terraform** версии =1.5.Х (версия 1.6 может вызывать проблемы с Яндекс провайдером) . Приложите скриншот вывода команды ```terraform --version```.

```bash
╰─➤terraform --version
Terraform v1.5.7
on linux_amd64
```

2. Скачайте на свой ПК этот git-репозиторий. Исходный код для выполнения задания расположен в директории **01/src**.

```bash
╰─➤git clone https://github.com/netology-code/ter-homeworks /home/serg/DevOps-Netology/netology/ter-homeworks/
Клонирование в «/home/serg/DevOps-Netology/netology/ter-homeworks»...
remote: Enumerating objects: 994, done.
remote: Counting objects: 100% (268/268), done.
remote: Compressing objects: 100% (94/94), done.
remote: Total 994 (delta 218), reused 201 (delta 173), pack-reused 726
Получение объектов: 100% (994/994), 218.87 КиБ | 1.41 МиБ/с, готово.
Определение изменений: 100% (534/534), готово.
```

3. Убедитесь, что в вашей ОС установлен docker.

```bash
╰─➤git docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

4. Зарегистрируйте аккаунт на сайте https://hub.docker.com/, выполните команду docker login и введите логин, пароль.

```bash
╰─➤git docker psdocker login -u lotsmansm
Password:
```

------

### Решение задачи 1

1. Перейдите в каталог [**src**](https://github.com/netology-code/ter-homeworks/tree/main/01/src). Скачайте все необходимые зависимости, использованные в проекте. 

```bash
╰─➤git clone https://github.com/netology-code/ter-homeworks /home/serg/DevOps-Netology/netology/ter-homeworks/
Клонирование в «/home/serg/DevOps-Netology/netology/ter-homeworks»...
remote: Enumerating objects: 994, done.
remote: Counting objects: 100% (268/268), done.
remote: Compressing objects: 100% (94/94), done.
remote: Total 994 (delta 218), reused 201 (delta 173), pack-reused 726
Получение объектов: 100% (994/994), 218.87 КиБ | 1.41 МиБ/с, готово.
Определение изменений: 100% (534/534), готово.
```

2. Изучите файл **.gitignore**. В каком terraform-файле, согласно этому .gitignore, допустимо сохранить личную, секретную информацию?

В соответствии с указанным .gitignore файлом, допустимо сохранять личную, секретную информацию в файле с именем "personal.auto.tfvars" в директории проекта.

3. Выполните код проекта. Найдите  в state-файле секретное содержимое созданного ресурса **random_password**, пришлите в качестве ответа конкретный ключ и его значение.

```bash
╰─➤terraform init

Initializing the backend...

Initializing provider plugins...
- Finding kreuzwerker/docker versions matching "~> 3.0.1"...
- Finding latest version of hashicorp/random...
- Installing kreuzwerker/docker v3.0.2...
- Installed kreuzwerker/docker v3.0.2 (unauthenticated)
- Installing hashicorp/random v3.5.1...
- Installed hashicorp/random v3.5.1 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

╷
│ Warning: Incomplete lock file information for providers
│ 
│ Due to your customized provider installation methods, Terraform was forced to calculate lock file checksums locally for the
│ following providers:
│   - hashicorp/random
│   - kreuzwerker/docker
│ 
│ The current .terraform.lock.hcl file only includes checksums for linux_amd64, so Terraform running on another platform will
│ fail to install these providers.
│ 
│ To calculate additional checksums for another platform, run:
│   terraform providers lock -platform=linux_amd64
│ (where linux_amd64 is the platform to generate)
╵

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```bash
╰─➤terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_password.random_string will be created
  + resource "random_password" "random_string" {
      + bcrypt_hash = (sensitive value)
      + id          = (known after apply)
      + length      = 16
      + lower       = true
      + min_lower   = 1
      + min_numeric = 1
      + min_special = 0
      + min_upper   = 1
      + number      = true
      + numeric     = true
      + result      = (sensitive value)
      + special     = false
      + upper       = true
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

```bash
╰─➤terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_password.random_string will be created
  + resource "random_password" "random_string" {
      + bcrypt_hash = (sensitive value)
      + id          = (known after apply)
      + length      = 16
      + lower       = true
      + min_lower   = 1
      + min_numeric = 1
      + min_special = 0
      + min_upper   = 1
      + number      = true
      + numeric     = true
      + result      = (sensitive value)
      + special     = false
      + upper       = true
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

random_password.random_string: Creating...
random_password.random_string: Creation complete after 0s [id=none]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Ключ `JA7HoeK1ZcJCYjCY`

4. Раскомментируйте блок кода, примерно расположенный на строчках 29–42 файла **main.tf**.
Выполните команду ```terraform validate```. Объясните, в чём заключаются намеренно допущенные ошибки. Исправьте их.

Раскомментировать нужно строки 23-38

```bash
╰─➤terraform validate
╷
│ Error: Missing name for resource
│ 
│   on main.tf line 24, in resource "docker_image":
│   24: resource "docker_image" {
│ 
│ All resource blocks must have 2 labels (type, name).
╵
╷
│ Error: Invalid resource name
│ 
│   on main.tf line 29, in resource "docker_container" "1nginx":
│   29: resource "docker_container" "1nginx" {
│ 
│ A name must start with a letter or underscore and may contain only letters, digits, underscores, and dashes.
╵
```
В 24 строчке пропущено имя "docker_image"

В 29 - имя начиналось с цифры.


```bash
╰─➤terraform validate
╷
│ Error: Reference to undeclared resource
│ 
│   on main.tf line 31, in resource "docker_container" "nginx":
│   31:   name  = "example_${random_password.random_string_FAKE.resulT}"
│ 
│ A managed resource "random_password" "random_string_FAKE" has not been declared in the root module.
╵
```
Управляемый ресурс «random_password» «random_string_FAKE» не объявлен в корневом модуле. Нужно удалить _FAKE в 31 строке

```bash
╰─➤terraform validate
╷
│ Error: Unsupported attribute
│ 
│   on main.tf line 31, in resource "docker_container" "nginx":
│   31:   name  = "example_${random_password.random_string.resulT}"
│ 
│ This object has no argument, nested block, or exported attribute named "resulT". Did you mean "result"?
╵
```
В 31 строке в слове resulT последняя буква большая, исправляем на result

```bash
╰─➤terraform validate
Success! The configuration is valid.
```

5. Выполните код. В качестве ответа приложите: исправленный фрагмент кода и вывод команды ```docker ps```.

```
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
  required_version = ">=0.13" /*Многострочный комментарий.
 Требуемая версия terraform */
}
provider "docker" {}

#однострочный комментарий

resource "random_password" "random_string" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}


resource "docker_image" "nginx" {
  name = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "example_${random_password.random_string.result}"

  ports {
    internal = 80
    external = 8000
  }
}
```

```bash
╰─➤terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # docker_container.nginx will be created
  + resource "docker_container" "nginx" {
      + attach                                      = false
      + bridge                                      = (known after apply)
      + command                                     = (known after apply)
      + container_logs                              = (known after apply)
      + container_read_refresh_timeout_milliseconds = 15000
      + entrypoint                                  = (known after apply)
      + env                                         = (known after apply)
      + exit_code                                   = (known after apply)
      + hostname                                    = (known after apply)
      + id                                          = (known after apply)
      + image                                       = (known after apply)
      + init                                        = (known after apply)
      + ipc_mode                                    = (known after apply)
      + log_driver                                  = (known after apply)
      + logs                                        = false
      + must_run                                    = true
      + name                                        = (sensitive value)
      + network_data                                = (known after apply)
      + read_only                                   = false
      + remove_volumes                              = true
      + restart                                     = "no"
      + rm                                          = false
      + runtime                                     = (known after apply)
      + security_opts                               = (known after apply)
      + shm_size                                    = (known after apply)
      + start                                       = true
      + stdin_open                                  = false
      + stop_signal                                 = (known after apply)
      + stop_timeout                                = (known after apply)
      + tty                                         = false
      + wait                                        = false
      + wait_timeout                                = 60

      + ports {
          + external = 8000
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
    }

  # docker_image.nginx will be created
  + resource "docker_image" "nginx" {
      + id           = (known after apply)
      + image_id     = (known after apply)
      + keep_locally = true
      + name         = "nginx:latest"
      + repo_digest  = (known after apply)
    }

  # random_password.random_string will be created
  + resource "random_password" "random_string" {
      + bcrypt_hash = (sensitive value)
      + id          = (known after apply)
      + length      = 16
      + lower       = true
      + min_lower   = 1
      + min_numeric = 1
      + min_special = 0
      + min_upper   = 1
      + number      = true
      + numeric     = true
      + result      = (sensitive value)
      + special     = false
      + upper       = true
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

docker_image.nginx: Creating...
random_password.random_string: Creating...
random_password.random_string: Creation complete after 0s [id=none]
docker_image.nginx: Creation complete after 8s [id=sha256:a6bd71f48f6839d9faae1f29d3babef831e76bc213107682c5cc80f0cbb30866nginx:latest]
docker_container.nginx: Creating...
docker_container.nginx: Creation complete after 0s [id=bce6ebad97603d7c6db3b47c814739da3e95e0ba32dd40fd7a159db9d5a14f61]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

```bash
╰─➤docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS                  NAMES
bce6ebad9760   a6bd71f48f68   "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:8000->80/tcp   example_BH4xNFw24EsfV4rd
```

6. Замените имя docker-контейнера в блоке кода на ```hello_world```. Не перепутайте имя контейнера и имя образа. Мы всё ещё продолжаем использовать name = "nginx:latest". Выполните команду ```terraform apply -auto-approve```.
Объясните своими словами, в чём может быть опасность применения ключа  ```-auto-approve```. В качестве ответа дополнительно приложите вывод команды ```docker ps```.

Опасность применения ключа -auto-approve заключается в том, что вы не будете иметь возможности внимательно проверить изменения перед их применением. Если есть какие-либо ошибки или проблемы с вашими настройками, они могут привести к нежелательным результатам или даже потере данных.

```bash
╰─➤docker psdocker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
cc5f92fda098   a6bd71f48f68   "/docker-entrypoint.…"   2 seconds ago   Up 2 seconds   0.0.0.0:8000->80/tcp   hello_world
```

8. Уничтожьте созданные ресурсы с помощью **terraform**. Убедитесь, что все ресурсы удалены. Приложите содержимое файла **terraform.tfstate**.


```
{
  "version": 4,
  "terraform_version": "1.5.7",
  "serial": 6,
  "lineage": "02fcd567-40e0-60e8-75e1-f8e71aaa47bf",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "docker_container",
      "name": "nginx",
      "provider": "provider[\"registry.terraform.io/kreuzwerker/docker\"]",
      "instances": [
        {
          "schema_version": 2,
          "attributes": {
            "attach": false,
            "bridge": "",
            "capabilities": [],
            "cgroupns_mode": null,
            "command": [
              "nginx",
              "-g",
              "daemon off;"
            ],
            "container_logs": null,
            "container_read_refresh_timeout_milliseconds": 15000,
            "cpu_set": "",
            "cpu_shares": 0,
            "destroy_grace_seconds": null,
            "devices": [],
            "dns": null,
            "dns_opts": null,
            "dns_search": null,
            "domainname": "",
            "entrypoint": [
              "/docker-entrypoint.sh"
            ],
            "env": [],
            "exit_code": null,
            "gpus": null,
            "group_add": null,
            "healthcheck": null,
            "host": [],
            "hostname": "cc5f92fda098",
            "id": "cc5f92fda098e045e236f27f7f6660cfded495e42041900ef822efdcd5b37e57",
            "image": "sha256:a6bd71f48f6839d9faae1f29d3babef831e76bc213107682c5cc80f0cbb30866",
            "init": false,
            "ipc_mode": "private",
            "labels": [],
            "log_driver": "json-file",
            "log_opts": null,
            "logs": false,
            "max_retry_count": 0,
            "memory": 0,
            "memory_swap": 0,
            "mounts": [],
            "must_run": true,
            "name": "hello_world",
            "network_data": [
              {
                "gateway": "172.17.0.1",
                "global_ipv6_address": "",
                "global_ipv6_prefix_length": 0,
                "ip_address": "172.17.0.2",
                "ip_prefix_length": 16,
                "ipv6_gateway": "",
                "mac_address": "02:42:ac:11:00:02",
                "network_name": "bridge"
              }
            ],
            "network_mode": "default",
            "networks_advanced": [],
            "pid_mode": "",
            "ports": [
              {
                "external": 8000,
                "internal": 80,
                "ip": "0.0.0.0",
                "protocol": "tcp"
              }
            ],
            "privileged": false,
            "publish_all_ports": false,
            "read_only": false,
            "remove_volumes": true,
            "restart": "no",
            "rm": false,
            "runtime": "runc",
            "security_opts": [],
            "shm_size": 64,
            "start": true,
            "stdin_open": false,
            "stop_signal": "SIGQUIT",
            "stop_timeout": 0,
            "storage_opts": null,
            "sysctls": null,
            "tmpfs": null,
            "tty": false,
            "ulimit": [],
            "upload": [],
            "user": "",
            "userns_mode": "",
            "volumes": [],
            "wait": false,
            "wait_timeout": 60,
            "working_dir": ""
          },
          "sensitive_attributes": [],
          "private": "eyJzY2hlbWFfdmVyc2lvbiI6IjIifQ==",
          "dependencies": [
            "docker_image.nginx"
          ]
        }
      ]
    },
    {
      "mode": "managed",
      "type": "docker_image",
      "name": "nginx",
      "provider": "provider[\"registry.terraform.io/kreuzwerker/docker\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "build": [],
            "force_remove": null,
            "id": "sha256:a6bd71f48f6839d9faae1f29d3babef831e76bc213107682c5cc80f0cbb30866nginx:latest",
            "image_id": "sha256:a6bd71f48f6839d9faae1f29d3babef831e76bc213107682c5cc80f0cbb30866",
            "keep_locally": true,
            "name": "nginx:latest",
            "platform": null,
            "pull_triggers": null,
            "repo_digest": "nginx@sha256:10d1f5b58f74683ad34eb29287e07dab1e90f10af243f151bb50aa5dbb4d62ee",
            "triggers": null
          },
          "sensitive_attributes": [],
          "private": "bnVsbA=="
        }
      ]
    },
    {
      "mode": "managed",
      "type": "random_password",
      "name": "random_string",
      "provider": "provider[\"registry.terraform.io/hashicorp/random\"]",
      "instances": [
        {
          "schema_version": 3,
          "attributes": {
            "bcrypt_hash": "$2a$10$Y2US2EgqpnhRU9Oll/taVeRB5hNt2iP1qya/vbVZQLy2DzssYAm4K",
            "id": "none",
            "keepers": null,
            "length": 16,
            "lower": true,
            "min_lower": 1,
            "min_numeric": 1,
            "min_special": 0,
            "min_upper": 1,
            "number": true,
            "numeric": true,
            "override_special": null,
            "result": "h3FIEzyfZ99dqydy",
            "special": false,
            "upper": true
          },
          "sensitive_attributes": []
        }
      ]
    }
  ],
  "check_results": null
}
```

9. Объясните, почему при этом не был удалён docker-образ **nginx:latest**. Ответ **обязательно** подкрепите строчкой из документации [**terraform провайдера docker**](https://docs.comcloud.xyz/providers/kreuzwerker/docker/latest/docs).  (ищите в классификаторе resource docker_image )

```
force_remove (Boolean) If true, then the image is removed forcibly when the resource is destroyed.

keep_locally (Boolean) If true, then the Docker image won't be deleted on destroy operation. If this is false, it will delete the image from the docker local storage on destroy operation.
```
------

### Решение задания 2*

1. Изучите в документации provider [**Virtualbox**](https://docs.comcloud.xyz/providers/shekeriev/virtualbox/latest/docs) от 
shekeriev.
2. Создайте с его помощью любую виртуальную машину. Чтобы не использовать VPN, советуем выбрать любой образ с расположением в GitHub из [**списка**](https://www.vagrantbox.es/).

В качестве ответа приложите plan для создаваемого ресурса и скриншот созданного в VB ресурса.

```bash
╰─➤terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # virtualbox_vm.vm1 will be created
  + resource "virtualbox_vm" "vm1" {
      + cpus   = 2
      + id     = (known after apply)
      + image  = "https://github.com/tommy-muehle/puppet-vagrant-boxes/releases/download/1.1.0/centos-7.0-x86_64.box"
      + memory = "1.0 gib"
      + name   = "centos-7"
      + status = "running"

      + network_adapter {
          + device                 = "IntelPro1000MTDesktop"
          + host_interface         = "vboxnet0"
          + ipv4_address           = (known after apply)
          + ipv4_address_available = (known after apply)
          + mac_address            = (known after apply)
          + status                 = (known after apply)
          + type                   = "hostonly"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + IPAddress = (known after apply)

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```