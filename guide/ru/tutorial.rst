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

Автоматическая перезагрузка
---------------------------

Xitrum позволяет перезагружать .class файлы (hot swap) без перезапуска программы.
Однако, что бы избежать проблем с производительностью и получить более стабильное
приложение, эта функция должна быть использована только в режиме разработчика
(development mode).

Запуск в IDE
~~~~~~~~~~~~

Во время разработки в IDE на подобии Eclipse или IntelliJ, автоматически будет происходить
перезагрузка кода.

Запуск в SBT
~~~~~~~~~~~~

При использовании SBT, нужно открыть две консоли:

* В первой выполните ``sbt/sbt run``. Эта команда запустить программу и будет
  перезагружать .class файлы когда они изменятся.
* Во второй ``sbt/sbt ~compile``. При изменении исходных файлов они будут автоматически
  компилироваться в .class файлы.

В директории sbt расположен `agent7.jar <https://github.com/xitrum-framework/agent7>`_.
Его задача заключается в перезагрузке .class файлов в рабочей директории (и под директориях).
Внутри скрипта ``sbt/sbt``, agent7.jar подключается специальной опцией ``-javaagent:agent7.jar``.

DCEVM
~~~~~

Обычно JVM позволяет перезагружать только тела методов. Вы можете использовать
`DCEVM <https://github.com/dcevm/dcevm>`_ - открытую модификацию Java HotSpot VM, 
которая позволяет полностью перезагружать классы.

Вы можете установить DCEVM двумя способами:

* `Изменить <https://github.com/dcevm/dcevm/releases>`_ существующую установку Java.
* Установить `собранную <http://dcevm.nentjes.com/>`_ версию (проще).

В первом варианте:

* DCEVM будет включен постоянно.
* Или будет установлен в качестве "альтернативной" JVM. В этом случае, что бы включить
  DCEVM, при запуске ``java`` нужно указывать опцию ``-XXaltjvm=dcevm``.
  Например, вам нужно добавить ``-XXaltjvm=dcevm`` в скрипт ``sbt/sbt``.

Если вы используете IDE (например, Eclipse или IntelliJ), вам нужно настроить
их на использование DCEVM при работе с вашим проектом.

Если вы используете SBT, вам нужно настроить переменную окружения ``PATH`` 
так что бы команда ``java`` была из DCEVM (не из стандартной JVM). Вам 
так же нужен ``javaagent`` описанный выше, поскольку DCEVM поддерживает изменения классов,
но сам их не перезагружает.

Смотри `DCEVM - бесплатная альтернатива JRebel <http://javainformed.blogspot.jp/2014/01/jrebel-free-alternative.html>`_.


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
  tmp
