Введение
========

::

  +--------------------+
  |      Клиенты       |
  +--------------------+
            |
  +--------------------+
  |       Netty        |
  +--------------------+
  |       Xitrum       |
  | +----------------+ |
  | | HTTP(S) Сервер | |
  | |----------------| |
  | | Web фреймворк  | |  <- Akka, Hazelcast -> Другие экземпляры
  | +----------------+ |
  +--------------------+
  |     Приложение     |
  +--------------------+

Xitrum - асинхронный и масштабируемый Scala веб фреймворк и HTTP(S) сервер. Он построен
на базе `Netty <http://netty.io/>`_ и `Akka <http://akka.io/>`_.

Из отзывов `пользователей <https://groups.google.com/group/xitrum-framework/msg/d6de4865a8576d39>`_:

  Wow, this is a really impressive body of work, arguably the most
  complete Scala framework outside of Lift (but much easier to use).

  `Xitrum <http://xitrum-framework.github.io/>`_ is truly a full stack web framework, all the bases are covered,
  including wtf-am-I-on-the-moon extras like ETags, static file cache
  identifiers & auto-gzip compression. Tack on built-in JSON converter,
  before/around/after interceptors, request/session/cookie/flash scopes,
  integrated validation (server & client-side, nice), built-in cache
  layer (`Hazelcast <http://www.hazelcast.org/>`_), i18n a la GNU gettext, Netty (with Nginx, hello
  blazing fast), etc. and you have, wow.

Возможности
-----------

* Безопасный относительно типов (typesafe) во всех отношениях где это возможно.
* Полностью асинхронный. Необязательно слать ответ на запрос немедленно, можно запустить сложные вычисления и дать ответ, когда он будет готов. Поддерживаются Long polling, chunked response, WebSockets, SockJs, EventStream.
* Встроенный веб сервер основан на высоко производительном `Netty <http://netty.io/>`_, отдача статических файлов сравнима по производительности с `Nginx <https://gist.github.com/3293596>`_.
* Обширные возможности для кэширования как на серверной так и на клиентской стороне.
  На уровне сервера файлы маленького размера сохраняются в памяти, большие файлы пересылаются с использованием NIO's zero copy.
  На уровне фреймворка есть возможность сохранить в кэш страницу, действие (action) или объект в стиле Rails.
  Учтены рекомендации `Google <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_.
  Ревалидация кэша возможна в любой момент.
* Для статических файлов поддерживаются `Range запросы <http://en.wikipedia.org/wiki/Byte_serving>`_. Эта функция необходима для отдачи видео файлов.
* Поддержка `CORS <http://en.wikipedia.org/wiki/Cross-origin_resource_sharing>`_.
* Автоматический расчет маршрутов (routes) приложения в стиле JAX-RS и Rails. Нет необходимости в объявлении маршрутов в каком-либо файле. Благодаря этому Xitrum позволяет объединять несколько приложений в одно. Все маршруты из jar файлов объединяются и работают как единое приложение.
* Обратная маршрутизация: генерация ссылок на контроллеры и действия.
* Генерация документации на основе `Swagger Doc <http://swagger.wordnik.com/>`_.
* Автоматическая перезагрузка классов и маршрутов при изменении (не требует перезапуска сервера).
* Представления (views) могут быть созданы с использованием `Scalate <http://scalate.fusesource.org/>`_, Scala или xml (во всех случаях происходит проверка типов на этапе компиляции).
* Сессии могут хранится в куках или кластеризованны, например, с помощью `Hazelcast <http://www.hazelcast.org/>`_.
* Встроенная валидация с `jQuery <http://jqueryvalidation.org/>`_ (опционально).
* i18n на основе `GNU gettext <http://en.wikipedia.org/wiki/GNU_gettext>`_. Автоматическая генерация pot файлов из исходников. gettext поддерживает множественные и единственные формы числа.

Идеологически Xitrum находится между `Scalatra <https://github.com/scalatra/scalatra>`_
и `Lift <http://liftweb.net/>`_: более функциональный чем Scalatra и гораздо проще чем Lift. Вы можете очень просто создавать RESTful APIs и postbacks. `Xitrum <http://xitrum-framework.github.io/>`_
является controller-first фреймворком.

:doc:`Связанные сcылки </deps>` список демонстрационных проектов, плагинов и прочее.

Авторы
------

`Xitrum <http://xitrum-framework.github.io/>`_ - проект с открытым `исходным кодом <https://github.com/xitrum-framework/xitrum>`_ проект, вступайте в официальную `Google группу <http://groups.google.com/group/xitrum-framework>`_.

Авторы в списке упорядочены по времени их
`первого вклада в проект <https://github.com/xitrum-framework/xitrum/graphs/contributors>`_.

(*): Участники команды разработки Xitrum.

* `Ngoc Dao (*) <https://github.com/ngocdaothanh>`_
* `Linh Tran <https://github.com/alide>`_
* `James Earl Douglas <https://github.com/JamesEarlDouglas>`_
* `Aleksander Guryanov <https://github.com/caiiiycuk>`_
* `Takeharu Oshida (*) <https://github.com/georgeOsdDev>`_
* `Nguyen Kim Kha <https://github.com/kimkha>`_
* `Michael Murray <https://github.com/murz>`_
