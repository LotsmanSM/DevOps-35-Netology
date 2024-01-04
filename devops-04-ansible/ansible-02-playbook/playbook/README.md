# Clickhouse & Vector Install

## Что делает playbook:

Playbook разворачивает на заданном хосте приложения:
- сlickhouse-client
- clickhouse-server
- clickhouse-common
- vector

Скачивает дистрибутив clickhouse-server и сlickhouse-client по указанному пути с указанными именами файлов. Устанавливает clickhouse-server и сlickhouse-client, создает базу данных. Для запуска должен быть открыт порт 9000.

Скачивает дистрибутив Vector по указанному пути с указанным именем файла. Создает директорию и распаковывает скачанный архив в созданную директорию. Создает файл параметров из шаблона. После выполнения действий запускает Vector с указанными параметрами в фоновом режиме.

## Параметры
- IP и способ подключения к целевому хосту необходимо указать в prod.yml, там же указывается пользователь ssh, путь к файлу ключа ssh.
- версии и архитектура пакетов указываются в файлах vars.yml

## Теги
- clickhouse
- vector

## Запуск

- Для запуска playbook нужно выполнить команду
```ansible-playbook -i inventory/prod.yml site.yml```, где ```inventory/prod.yml``` - путь к Inventory файлу, ```site.yml``` - файл playbook. 