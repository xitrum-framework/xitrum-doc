Контроллеры и представления
===========================

Xitrum располагает двумя видами контроллеров или действий (actions):
стандартный контроллер (normal action) и актор контроллер (actor action).

Стандартный контроллер (normal action)
--------------------------------------

Реализация данного контроллера синхронная.

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("hello")
  class HelloAction extends Action {
    def execute() {
      respondText("Hello")
    }
  }

Реализация метода execute не должна содержать блокирующих или долгих операций, т.к.
в синхронном режиме количество конкурентных подключений очень низкое.

FutureAction
------------

В случае наследования от xitrum.Action, ваш код будет выполнятся в потоке Netty's IO.
Это допустимо только в случае если ваш контроллер очень легковесный и не блокирующий
(возвращает ответ немедленно). В любом другом случае нужно использовать наследование
от xitrum.FutureAction, тогда код контроллера будет выполнятся в отдельном потоке (из
пула потоков).

::

  import xitrum.FutureAction
  import xitrum.annotation.GET

  @GET("hello")
  class HelloAction extends FutureAction {
    def execute() {
      respondText("hi")
    }
  }

Актор контроллер (actor action)
--------------------------------

Используется для реализации асинхронной обработки запросов. В случае наследования
от xitrum.ActorAction контроллер будет обычным актором. С применением акторов система
может обслуживать огромное число конкурентных запросов, но все они будут обработаны асинхронно.

Экземпляр актора будет создан на каждый запрос. Актор будет остановлен в момент закрытия подключения
или когда ответ будет отправлен клиенту. Для chunked запросов актор будет остановлен когда будет
отправлен последний chunk.

::

  import scala.concurrent.duration._

  import xitrum.ActorAction
  import xitrum.annotation.GET

  @GET("hello")
  class HelloAction extends ActorAction with AppAction {
    def execute() {
      // See Akka doc about scheduler
      import context.dispatcher
      context.system.scheduler.scheduleOnce(3 seconds, self, System.currentTimeMillis())

      // See Akka doc about "become"
      context.become {
        case pastTime =>
          respondInlineView(s"It's $pastTime Unix ms 3s ago.")
      }
    }
  }

Отправка ответа клиенту
-----------------------

Что бы отправить данные клиенту используются функции:

* ``respondView``: при ответе использует шаблон ассоциированный с контроллером
* ``respondInlineView``: при ответе использует шаблон переданный как аргумент
* ``respondText("hello")``: ответ строкой "plain/text"
* ``respondHtml("<html>...</html>")``: ответ строкой "text/html"
* ``respondJson(List(1, 2, 3))``: преобразовать Scala объект в JSON и ответить
* ``respondJs("myFunction([1, 2, 3])")``
* ``respondJsonP(List(1, 2, 3), "myFunction")``: совмещение предыдущих двух
* ``respondJsonText("[1, 2, 3]")``
* ``respondJsonPText("[1, 2, 3]", "myFunction")``
* ``respondBinary``: ответ массивом байт
* ``respondFile``: переслать файл с использованием техники `zero-copy <http://www.ibm.com/developerworks/library/j-zerocopy/>`_  (aka send-file)
* ``respondEventSource("data", "event")``

Шаблонизация
------------

Каждый контроллер может быть связан с шаблоном `Scalate <http://scalate.fusesource.org/>`_.
В этом случае при вызове метода `respondView` будет задействован данный шаблон для формирования
ответа.

scr/main/scala/mypackage/MyAction.scala:

::

  package mypackage

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("myAction")
  class MyAction extends Action {
    def execute() {
      respondView()
    }

    def hello(what: String) = "Hello %s".format(what)
  }

scr/main/scalate/mypackage/MyAction.jade:

::

  - import mypackage.MyAction

  !!! 5
  html
    head
      != antiCsrfMeta
      != xitrumCss
      != jsDefaults
      title Welcome to Xitrum

    body
      a(href={url}) Path to the current action
      p= currentAction.asInstanceOf[MyAction].hello("World")

      != jsForView

* ``xitrumCss`` подключает стандартные CSS встроенные в Xitrum. Вы можете убрать их если
  они не требуются
* ``jsDefaults`` подключает jQuery, jQuery Validate и пр. Если используется, вызов должен
  быть размешен в секции <head>
* ``jsForView`` использует функцию контроллера ``jsAddToView`` и  включает JS фаргмент в шаблон.
  Если используется, вызов должен быть в конце шаблона

В шаблонах допускается использование любых методов из трейта `xitrum.Action <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/Action.scala>`_. Дополнительно можно использовать утильные методы Scalate,
такие как ``unescape`` (см. `Scalate doc <http://scalate.fusesource.org/documentation/index.html>`_).

Синтаксис `Jade <http://scalate.fusesource.org/documentation/jade.html>`_ используется по умолчанию для Scalate.
Так же вы можете использовать синтаксис `Mustache <http://scalate.fusesource.org/documentation/mustache.html>`_,
`Scaml <http://scalate.fusesource.org/documentation/scaml-reference.html>`_ или
`Ssp <http://scalate.fusesource.org/documentation/ssp-reference.html>`_.
Что бы установить предпочитаемый синтаксис, отредактируйте файл xitrum.conf в директории config.

Кроме этого, метод `respondView` позволяет переопределять синтаксис шаблона.

::

  respondView(Map("type" ->"mustache"))

currentAction и приведение типов
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Если известен подкласс контроллера который используется с шаблоном, то можно выполнить
приведение ``currentAction`` к этому подклассу.

::

  p= currentAction.asInstanceOf[MyAction].hello("World")

Или так:

::

  - val myAction = currentAction.asInstanceOf[MyAction]; import myAction._

  p= hello("World")
  p= hello("Scala")
  p= hello("Xitrum")

Mustache
~~~~~~~~

Важно:

* `Mustache syntax <http://mustache.github.com/mustache.5.html>`_
* `Scalate implementation <http://scalate.fusesource.org/documentation/mustache.html>`_

Mustache намеренно ограничивает возможности шаблонизации до минимума логики. Поэтому многие
возможности используемые в Jade не применимы в Mustache.

Для передачи моделей из контроллера в шаблон необходимо использовать ``at``:

Контролер:

::

  at("name") = "Jack"
  at("xitrumCss") = xitrumCss

Шаблон Mustache:

::

  Мое имя {{name}}
  {{xitrumCss}}

Примечание: следующие слова зарезервированы и не могут быть использованы
как ключ в ``at``:

* "context": Scalate объект предоставляющий методы ``unescape`` и пр.
* "helper": текущий контроллер

CoffeeScript
~~~~~~~~~~~~

Scalate позволяет включать CoffeeScript в шаблоны
`:coffeescript filter <http://scalate.fusesource.org/documentation/jade-syntax.html#filters>`_:

::

  body
    :coffeescript
      alert "Hello, Coffee!"

Результат:

::

  <body>
    <script type='text/javascript'>
      //<![CDATA[
        (function() {
          alert("Hello, Coffee!");
        }).call(this);
      //]]>
    </script>
  </body>

Однако, эта возможность работает достаточно `медленно <http://groups.google.com/group/xitrum-framework/browse_thread/thread/6667a7608f0dc9c7>`_:

::

  jade+javascript+1thread: 1-2ms for page
  jade+coffesscript+1thread: 40-70ms for page
  jade+javascript+100threads: ~40ms for page
  jade+coffesscript+100threads: 400-700ms for page

Рекомендуется самостоятельно компилировать CoffeeScript в JavaScript для оптимизации производительности.

Макет (Layout)
--------------

При использовании ``respondView`` или ``respondInlineView``, Xitrum
выполняет шаблонизацию в строку, и присваивает результат в переменную ``renderedView``.
Затем, Xitrum вызывает метод ``layout`` текущего контроллера и отправляет результат работы
этого метода как ответ сервера.

По умолчанию метод ``layout`` просто возвращает переменную ``renderedView``.
В случае перекрытия этого метода появляется возможность декорировать шаблон.
Таким образом достаточно просто реализовать произвольный макет (layout) для всех контроллеров.

Механизм ``layout`` очень простой и понятный. Никакой магии. Для удобства, вы можете
думать что Xitrum не поддерживает макеты (layout), есть только метод ``layout`` и вы вольны
делать с ним все что захотите.

Обычно, создается базовый класс для реализация стандартного макета:

src/main/scala/mypackage/AppAction.scala

::

  package mypackage
  import xitrum.Action

  trait AppAction extends Action {
    override def layout = renderViewNoLayout[AppAction]()
  }

src/main/scalate/mypackage/AppAction.jade

::

  !!! 5
  html
    head
      != antiCsrfMeta
      != xitrumCss
      != jsDefaults
      title Welcome to Xitrum

    body
      != renderedView
      != jsForView

src/main/scala/mypackage/MyAction.scala

::

  package mypackage
  import xitrum.annotation.GET

  @GET("myAction")
  class MyAction extends AppAction {
    def execute() {
      respondView()
    }

    def hello(what: String) = "Hello %s".format(what)
  }

scr/main/scalate/mypackage/MyAction.jade:

::

  - import mypackage.MyAction

  a(href={url}) Path to the current action
  p= currentAction.asInstanceOf[MyAction].hello("World")

Макет в отдельном файле
~~~~~~~~~~~~~~~~~~~~~~~

AppAction.scala

::

  import xitrum.Action
  import xitrum.view.DocType

  trait AppAction extends Action {
    override def layout = DocType.html5(
      <html>
        <head>
          {antiCsrfMeta}
          {xitrumCss}
          {jsDefaults}
          <title>Welcome to Xitrum</title>
        </head>
        <body>
          {renderedView}
          {jsForView}
        </body>
      </html>
    )
  }

Использование макета непосредственно в respondView
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  val specialLayout = () =>
    DocType.html5(
      <html>
        <head>
          {antiCsrfMeta}
          {xitrumCss}
          {jsDefaults}
          <title>Welcome to Xitrum</title>
        </head>
        <body>
          {renderedView}
          {jsForView}
        </body>
      </html>
    )

  respondView(specialLayout _)

Внутренние представления
------------------------

Обычно, шаблон описывается в отдельном файле, но существует возможность писать
шаблоны непосредственно в контроллере:

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("myAction")
  class MyAction extends Action {
    def execute() {
      val s = "World"  // Will be automatically HTML-escaped
      respondInlineView(
        <p>Hello <em>{s}</em>!</p>
      )
    }
  }

Фрагменты
---------

MyAction.jade:
``scr/main/scalate/mypackage/MyAction.jade``

Шаблонизация с помощью фрагмента
``scr/main/scalate/mypackage/_MyFragment.jade``:

::

  renderFragment[MyAction]("MyFragment")

Можно записать короче, если ``MyAction`` - текущий контроллер:

::

  renderFragment("MyFragment")

Использование шаблона смежного контроллера
------------------------------------------

Использование метода ``respondView[ClassName]()``:

::

  package mypackage

  import xitrum.Action
  import xitrum.annotation.{GET, POST}

  @GET("login")
  class LoginFormAction extends Action {
    def execute() {
      // Respond scr/main/scalate/mypackage/LoginFormAction.jade
      respondView()
    }
  }

  @POST("login")
  class DoLoginAction extends Action {
    def execute() {
      val authenticated = ...
      if (authenticated)
        redirectTo[HomeAction]()
      else
        // Reuse the view of LoginFormAction
        respondView[LoginFormAction]()
    }
  }

Один контроллер - много представлений
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Использование нескольких шаблонов для одного контроллера:

::

  package mypackage

  import xitrum.Action
  import xitrum.annotation.GET

  // Шаблоны автоматически не маршрутизируются
  // scr/main/scalate/mypackage/HomeAction_NormalUser.jade
  // scr/main/scalate/mypackage/HomeAction_Moderator.jade
  // scr/main/scalate/mypackage/HomeAction_Admin.jade
  trait HomeAction_NormalUser extends Action
  trait HomeAction_Moderator  extends Action
  trait HomeAction_Admin      extends Action

  @GET("")
  class HomeAction extends Action {
    def execute() {
      val userType = ...
      userType match {
        case NormalUser => respondView[HomeAction_NormalUser]()
        case Moderator  => respondView[HomeAction_Moderator]()
        case Admin      => respondView[HomeAction_Admin]()
      }
    }
  }

Использование дополнительных не автоматических маршрутов выглядит утомительно, однако
это более безопасно относительно типов (typesafe).

Компонент
---------

Компоненты позволяют создавать переиспользуемое поведение и могут быть включены
во множество представлений. Концептуально компонент очень близок к контроллеру, но:

* Не имеет маршрутов, поэтому отсутствует метод ``execute``.
* Компонент не отправляет ответ сервера, он просто выполняет шаблонизацию фрагмента.
  Поэтому внутри компонента, вместо вызовов ``respondXXX``, необходимо использовать ``renderXXX``.
* Как и контроллеры, компонент может иметь ни одного, одно или множество связанных представлений.

::

  package mypackage

  import xitrum.{FutureAction, Component}
  import xitrum.annotation.GET

  class CompoWithView extends Component {
    def render() = {
      // Render associated view template, e.g. CompoWithView.jade
      // Note that this is renderView, not respondView!
      renderView()
    }
  }

  class CompoWithoutView extends Component {
    def render() = {
      "Hello World"
    }
  }

  @GET("foo/bar")
  class MyAction extends FutureAction {
    def execute() {
      respondView()
    }
  }

MyAction.jade:

::

  - import mypackage._

  != newComponent[CompoWithView]().render()
  != newComponent[CompoWithoutView]().render()
