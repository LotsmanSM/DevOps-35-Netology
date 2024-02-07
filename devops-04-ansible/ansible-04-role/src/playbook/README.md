# Install:
* Nginx
* Lighthouse
* Clickhouse
* Vector

## Что делает playbook:

Playbook разворачивает на заданных хостах следующие приложения:
- сlickhouse-client
- clickhouse-server
- clickhouse-common
- vector
- nginx
- git
- lighthouse

Сначала на отдельную виртуальную машину устанавливается и конфигурируется web-сервер Nginx, т.к. он нужен для работы Lighthouse. Далее на ту же машину скачивается Lighthouse, создается его файл web-конфигурации по указанному шаблону и перезапускается web-сервер Nginx.

На следующую виртуальную машину скачивается дистрибутив clickhouse-server и сlickhouse-client по указанному пути с указанными именами файлов. Устанавливается clickhouse-server и сlickhouse-client, создается база данных, запускается сервис Clickhouse. 

На последнюю виртуальную машину выполняется установка дистрибутива Vector, путь к источнику установки указан в файле vars.yml. Создается сервис приложения по файлу из шаблона. После выполнения действий запускается Vector.

## Параметры
- IP адреса целевых хостов необходимо указать в файле prod.yml.
- версии и архитектура пакетов, а также пути и остальные нужные параметры указываются в файлах vars.yml


## Теги
- nginx
- lighthouse
- clickhouse
- vector

## Подготовка к запуску

Данный playbook использует Roles. Перед запуском playbook нужно инициализировать роли командой `ansible-galaxy install -r requirements.yml`.

## Запуск

- Для запуска playbook нужно выполнить команду
```ansible-playbook -i inventory/prod.yml site.yml```, где ```inventory/prod.yml``` - путь к Inventory файлу, ```site.yml``` - файл playbook. 