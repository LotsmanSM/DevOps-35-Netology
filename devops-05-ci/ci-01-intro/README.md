# Домашнее задание к занятию 7 «Жизненный цикл ПО»

## Подготовка к выполнению

1. Получить бесплатную версию Jira - https://www.atlassian.com/ru/software/jira/work-management/free (скопируйте ссылку в адресную строку). Вы можете воспользоваться любым(в том числе бесплатным vpn сервисом) если сайт у вас недоступен. Кроме того вы можете скачать [docker образ](https://hub.docker.com/r/atlassian/jira-software/#) и запустить на своем хосте self-managed версию jira.

Используя VPN получил бесплатную версию Jira, создал аккаунт.

2. Настроить её для своей команды разработки.
3. Создать доски Kanban и Scrum.

Создал доски Kanban и Scrum:

![img01_Kanban_Scrum.png](img/img01_Kanban_Scrum.png)

Создал статусы для доски Kanban:

![img02_Board_Status.png](img/img02_Board_Status.png)

4. [Дополнительные инструкции от разработчика Jira](https://support.atlassian.com/jira-cloud-administration/docs/import-and-export-issue-workflows/).

## Основная часть

Необходимо создать собственные workflow для двух типов задач: bug и остальные типы задач. Задачи типа bug должны проходить жизненный цикл:

1. Open -> On reproduce.
2. On reproduce -> Open, Done reproduce.
3. Done reproduce -> On fix.
4. On fix -> On reproduce, Done fix.
5. Done fix -> On test.
6. On test -> On fix, Done.
7. Done -> Closed, Open.

Остальные задачи должны проходить по упрощённому workflow:

1. Open -> On develop.
2. On develop -> Open, Done develop.
3. Done develop -> On test.
4. On test -> On develop, Done.
5. Done -> Closed, Open.

Создаю два Workflows согласно заданию:

![img03_2Workflows.png](img/img03_2Workflows.png)

Workflow для типов задач Bug:

![img04_Workflows_Bug.png](img/img04_Workflows_Bug.png)

Workflow для всех остальных типов задач:

![img05_Workflows_Other.png](img/img05_Workflows_Other.png)

**Что нужно сделать**

1. Создайте задачу с типом bug, попытайтесь провести его по всему workflow до Done. 

Создаю задачу с типом Bug:

![img06_TaskBug_Open.png](img/img06_TaskBug_Open.png)

Довел задачу до состояния Done:

![img07_TaskBug_Done.png](img/img07_TaskBug_Done.png)

1. Создайте задачу с типом epic, к ней привяжите несколько задач с типом task, проведите их по всему workflow до Done.

Создал задачу с типом Epic и две задачи с типом Task, привязанные к Epic:

![img08_TaskEpic_Open.png](img/img08_TaskEpic_Open.png)

Довел задачи до состояния Done:

![img09_TaskEpic_Done.png](img/img09_TaskEpic_Done.png)

1. При проведении обеих задач по статусам используйте kanban. 
1. Верните задачи в статус Open.

Вернул задачи обратно в состояние Open:

![img10_Tasks_Open.png](img/img10_Tasks_Open.png)

1. Перейдите в Scrum, запланируйте новый спринт, состоящий из задач эпика и одного бага, стартуйте спринт, проведите задачи до состояния Closed. Закройте спринт.

Перехожу в Scrum проект, создаю задачи с эпиком и планирую спринт:

![img11_Sprint_Start.png](img/img11_Sprint_Start.png)

Довожу задачи до состояния выполнения и закрываю спринт. Судя по Timeline выполнение спринта произошло в рамках запланированного времени:

![img12_Sprint_Stop.png](img/img12_Sprint_Stop.png)

2. Если всё отработалось в рамках ожидания — выгрузите схемы workflow для импорта в XML. Файлы с workflow и скриншоты workflow приложите к решению задания.

## Выгруженные схемы Workflow:

* [bug workflow](Workflows/Bug.xml)
* [other workflow](Workflows/Other.xml)

---