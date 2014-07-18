Как начать
==========

Эта глава описывает как создать и запустить Xitrum проект.
**Предполагается что вы знакомы с операционной системой Linux и у вас установлена Java.**

Создание пустого проекта Xitrum
-------------------------------

Для создания проекта, скачайте файл
`xitrum-new.zip <https://github.com/xitrum-framework/xitrum-new/archive/master.zip>`_:

::

  wget -O xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

или:

::

  curl -L -o xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

Запуск
------

Сложившийся стандарт запуска Scala проектов - использование
`SBT <https://github.com/harrah/xsbt/wiki/Setup>`_. Проект созданный из шаблона уже включает 
SBT в директории ``sbt``. Если вы хотите установить SBT самостоятельно, воспользуйтесь 
`руководством <https://github.com/harrah/xsbt/wiki/Setup>`_.

Перейдите в директорию созданного проекта и выполните команду ``sbt/sbt run``:

::

  unzip xitrum-new.zip
  cd xitrum-new
  sbt/sbt run

Данная команда выполнит скачивание всех :doc:`зависимостей </deps>`, компиляцию проекта
и запуск main-класса ``quickstart.Boot``, который запустит сервер. В консоль будут напечатаны все
маршруты (routes) проекта:

::

  [INFO] Load routes.cache or recollect routes...
  [INFO] Normal routes:
  GET  /  quickstart.action.SiteIndex
  [INFO] SockJS routes:
  xitrum/metrics/channel  xitrum.metrics.XitrumMetricsChannel  websocket: true, cookie_needed: false
  [INFO] Error routes:
  404  quickstart.action.NotFoundError
  500  quickstart.action.ServerError
  [INFO] Xitrum routes:
  GET        /webjars/swagger-ui/2.0.17/index                            xitrum.routing.SwaggerUiVersioned
  GET        /xitrum/xitrum.js                                           xitrum.js
  GET        /xitrum/metrics/channel                                     xitrum.sockjs.Greeting
  GET        /xitrum/metrics/channel/:serverId/:sessionId/eventsource    xitrum.sockjs.EventSourceReceive
  GET        /xitrum/metrics/channel/:serverId/:sessionId/htmlfile       xitrum.sockjs.HtmlFileReceive
  GET        /xitrum/metrics/channel/:serverId/:sessionId/jsonp          xitrum.sockjs.JsonPPollingReceive
  POST       /xitrum/metrics/channel/:serverId/:sessionId/jsonp_send     xitrum.sockjs.JsonPPollingSend
  WEBSOCKET  /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocket
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr            xitrum.sockjs.XhrPollingReceive
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr_send       xitrum.sockjs.XhrSend
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr_streaming  xitrum.sockjs.XhrStreamingReceive
  GET        /xitrum/metrics/channel/info                                xitrum.sockjs.InfoGET
  WEBSOCKET  /xitrum/metrics/channel/websocket                           xitrum.sockjs.RawWebSocket
  GET        /xitrum/metrics/viewer                                      xitrum.metrics.XitrumMetricsViewer
  GET        /xitrum/metrics/channel/:iframe                             xitrum.sockjs.Iframe
  GET        /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocketGET
  POST       /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocketPOST
  [INFO] HTTP server started on port 8000
  [INFO] HTTPS server started on port 4430
  [INFO] Xitrum started in development mode

Во время запуска, все маршруты будут собраны и напечатаны в лог. Это очень удобно
иметь список всех маршрутов проекта, если вы планируете написать документацию для своего
RESTful API.

Откройте http://localhost:8000/ или https://localhost:4430/ в браузере. В консоль будет
напечатана информация о запросе:

::

  [INFO] GET quickstart.action.SiteIndex, 1 [ms]

Автоматическая перезагрузка
---------------------------

В режиме разработчика Xitrum автоматически перезагружает маршруты и классы в директории
`target/scala-2.11/classes`, для этого вам не нужны дополнительные утилиты вроде
JRebel <http://zeroturnaround.com/software/jrebel/>`_.

Xitrum использует эти новые классы для создания новых экземпляров объектов. Xitrum
не пересоздает уже существующие экземпляры. Такое поведение допустимо для большинства
случаев.

Когда происходит изменение в директории `target/scala-2.11/classes`, Xitrum печатает
сообщение в лог:

::

  [INFO] target/scala-2.11/classes changed; Reload classes and routes on next request

Вы можете использовать SBT для последовательной компиляции проекта вслед за изменением 
исходного кода. Для этого необходимо выполнить команду:

::

  sbt/sbt ~compile

Eclipse и IntelliJ могут быть использованы для редактирования и компиляции проекта.

Импорт проекта в Eclipse
------------------------

`Использование Eclipse для написания Scala кода <http://scala-ide.org/>`_.

Из директории проекта выполните команду:

::

  sbt/sbt eclipse

Файл Eclipse проекта  ``.project`` будет создан из описание проекта ``build.sbt``.
Откройте Eclipse и импортируйте созданный проект.

Импорт проекта в IntelliJ
-------------------------

`IntelliJ <http://www.jetbrains.com/idea/>`_, поддерживает Scala на очень хорошем уровне.

Для создания файлов проекта выполните команду:

::

  sbt/sbt gen-idea

Список игнорируемых файлов
--------------------------

При создании проекта :doc:`по шаблону </tutorial>`, есть ряд файлов которые нужно 
`исключить <https://github.com/xitrum-framework/xitrum-new/blob/master/.gitignore>`_ из системы контроля версий:

::

  .*
  log
  project/project
  project/target
  routes.cache
  target
