RESTful APIs
============

Разработка RESTful APIs с использованием Xitrum.

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("articles")
  class ArticlesIndex extends Action {
    def execute() {...}
  }

  @GET("articles/:id")
  class ArticlesShow extends Action {
    def execute() {...}
  }

Подобным образом описываются POST, PUT, PATCH, DELETE, и OPTIONS запросы.
Xitrum автоматически обрабатывает HEAD запросы как GET с пустым ответом.

Для HTTP клиентов не поддерживающих PUT и DELETE (например, обычные браузеры), используется метод POST c параметрами ``_method=put`` или ``_method=delete`` внутри тела запроса.

При старте веб приложения, Xitrum сканирует аннотации, создает таблицу маршрутизации
и печатает ее в лог. Из лога понятно какое API приложение поддерживает на данный момент:

::

  [INFO] Routes:
  GET /articles     quickstart.action.ArticlesIndex
  GET /articles/:id quickstart.action.ArticlesShow

Маршруты (routes) автоматически строятся в духе JAX-RS и Rails. Нет необходимости
объявлять все маршруты в одном месте. Допускается включать одно приложение в другое.
Например, движок блога можно упаковать в JAR файл и подключить его в другое приложение,
после этого у приложения появятся все возможности блога. Маршрутизация осуществляется
в два направления, можно генерировать URL по контроллеру (обратная маршрутизация).
Автоматическое документирование ваших маршрутов можно выполнить используя
`Swagger Doc <http://swagger.wordnik.com/>`_.

Кэш маршрутов
-------------

Для более быстро скорости запуска, маршруты кэшируются в файл ``routes.cache``.
В режиме разработчика, этот файл не используется. В случае изменения зависимостей
содержащих маршруты, необходимо удалить ``routes.cache``. Этот файл не должен попасть
в ваши систему контроля версий.

Очередность маршрутов
---------------------

Возможно вам потребуется организовать маршруты в определенном порядке.

::

  /articles/:id --> ArticlesShow
  /articles/new --> ArticlesNew

В данном случае необходимо что бы второй маршрут был проверен первым.
Для этих целей нужно использовать аннотацию ``First``:

::

  import xitrum.annotation.{GET, First}

  @GET("articles/:id")
  class ArticlesShow extends Action {
    def execute() {...}
  }

  @First  // This route has higher priority than "ArticlesShow" above
  @GET("articles/new")
  class ArticlesNew extends Action {
    def execute() {...}
  }

``Last`` работает помещает маршрут на обработку последним.

Несколько маршрутов для одного контроллера
------------------------------------------

::

  @GET("image", "image/:format")
  class Image extends Action {
    def execute() {
      val format = paramo("format").getOrElse("png")
      // ...
    }
  }

Точка в маршруте
----------------

::

  @GET("articles/:id", "articles/:id.:format")
  class ArticlesShow extends Action {
    def execute() {
      val id     = param[Int]("id")
      val format = paramo("format").getOrElse("html")
      // ...
    }
  }

Регулярные выражения в маршруте
-------------------------------

Регулярные выражения могут быть использованы для задания ограничений в маршруте:

::

  GET("articles/:id<[0-9]+>")

Обработка не стандартных маршрутов
----------------------------------

Использование символа ``/`` не допускается в именах параметров. Если есть необходимость в его
использовании вы можете определить маршрут следующим образом:

::

  GET("service/:id/proxy/:*")

Например, данный маршрут будет обрабатывать запросы:

::

  /service/123/proxy/http://foo.com/bar

Извлечение значение из части ``:*``:

::

  val url = param("*")  // Будет "http://foo.com/bar"

Ссылка на контроллер
--------------------

Xitrum пытается быть достаточно безопасным. Не пишите ссылки самостоятельно (в явном виде).
Используйте генератор ссылок:

::

  <a href={url[ArticlesShow]("id" -> myArticle.id)}>{myArticle.title}</a>

Редирект на контроллер
----------------------

Читайте подробнее про `редирект <http://en.wikipedia.org/wiki/URL_redirection>`_.

::

  import xitrum.Action
  import xitrum.annotation.{GET, POST}

  @GET("login")
  class LoginInput extends Action {
    def execute() {...}
  }

  @POST("login")
  class DoLogin extends Action {
    def execute() {
      ...
      // After login success
      redirectTo[AdminIndex]()
    }
  }

  GET("admin")
  class AdminIndex extends Action {
    def execute() {
      ...
      // Check if the user has not logged in, redirect him to the login page
      redirectTo[LoginInput]()
    }
  }

Допускается делать редирект на тот же самый контроллер с помощью метода ``redirecToThis()``.

Форвардинг (перенаправление) на контроллер
------------------------------------------

Используйте ``forwardTo[AnotherAction]()``. ``redirectTo`` заставляет браузер делать новый запрос, в то
время как ``forwardTo`` работает в рамках одного запроса.

Определение Ajax запроса
------------------------

Используйте ``isAjax``.

::

  // В контроллере
  val msg = "A message"
  if (isAjax)
    jsRender("alert(" + jsEscape(msg) + ")")
  else
    respondText(msg)

Anti-CSRF
---------

Для запросов отличных от GET Xitrum автоматически защищает приложение от
`Cross-site request forgery <http://en.wikipedia.org/wiki/CSRF>`_  атаки.

Включите в шаблон ``antiCsrfMeta``:

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

Тогда секция ``<head>`` будет включать в себя csrf-token:

::

  <!DOCTYPE html>
  <html>
    <head>
      ...
      <meta name="csrf-token" content="5402330e-9916-40d8-a3f4-16b271d583be" />
      ...
    </head>
    ...
  </html>

Этот токен будет автоматически включен во все Ajax запросы jQuery как заголовок
``X-CSRF-Token`` если вы подключите `xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_. xitrum.js  подключается вызовом ``jsDefaults``. Если вы не хотите
использовать ``jsDefaults``, вы можете подключить xitrum.js следующим образом (или посылать токен самостоятельно):

::

  <script type="text/javascript" src={url[xitrum.js]}></script>

antiCsrfInput и antiCsrfToken
-----------------------------

Xitrum использует CSRF токен из заголовка запроса с именем ``X-CSRF-Token``. Если заголовок
не установлен, Xitrum берет значение из параметра ``csrf-token`` переданного в теле запроса
(не из URL).

Если вы вручную создаете формы, и не используйте мета тэг и xitrum.js как сказано выше,
то вам нужно использовать методы контроллера ``antiCsrfInput`` или ``antiCsrfToken``:

::

  form(method="post" action={url[AdminAddGroup]})
    != antiCsrfInput

::

  form(method="post" action={url[AdminAddGroup]})
    input(type="hidden" name="csrf-token" value={antiCsrfToken})

SkipCsrfCheck
-------------

Для некоторые API не требуется защита от CSRF атак, в этом случае проще всего
пропустить эту проверку. Для этого дополнительно наследуйте свой контроллер
от трейта xitrum.SkipCsrfCheck:

::

  import xitrum.{Action, SkipCsrfCheck}
  import xitrum.annotation.POST

  trait Api extends Action with SkipCsrfCheck

  @POST("api/positions")
  class LogPositionAPI extends Api {
    def execute() {...}
  }

  @POST("api/todos")
  class CreateTodoAPI extends Api {
    def execute() {...}
  }

Управление маршрутами
---------------------

Xitrum автоматически собирает маршруты при запуске.
Для управления этими маршрутами используйте
`xitrum.Config.routes <http://xitrum-framework.github.io/api/3.17/index.html#xitrum.routing.RouteCollection>`_.

Например:

::

  import xitrum.{Config, Server}

  object Boot {
    def main(args: Array[String]) {
      // Вы можете поправить маршруты до запуска сервера
      val routes = Config.routes

      // Удаление маршрутов относящихся к конкретному классу
      routes.removeByClass[MyClass]()

      if (demoVersion) {
        // Удаление маршрутов начинающихся с префикса
        routes.removeByPrefix("premium/features")

        // Допустимый вариант
        routes.removeByPrefix("/premium/features")
      }

      ...

      Server.start()
    }
  }

Получение полных (сырых) данных запроса
---------------------------------------

Обычно когда mime тип запроса не соответствует ``application/x-www-form-urlencoded``,
предполагается что содержимое запроса будет обработано в ручном режиме.

Получение тела запроса в виде строки:

::

  val body = requestContentString

JSON:

::

  val myJValue = requestContentJValue  // => JSON4S (http://json4s.org) JValue
  val myMap = requestContentJson[Map[String, Int]]

Если вам нужно получить полный доступ к запросу, используйте `request.getContent <http://netty.io/4.0/api/io/netty/handler/codec/http/FullHttpRequest.html>`_. Он возвращает `ByteBuf <http://netty.io/4.0/api/io/netty/buffer/ByteBuf.html>`_.

Документирование API
--------------------

Из коробки вы можете документировать API и использованием `Swagger <https://developers.helloreverb.com/swagger/>`_.
Добавьте аннотацию ``@Swagger`` к контроллеру который нужно задокументировать
Xitrum генерирует `/xitrum/swagger.json <https://github.com/wordnik/swagger-core/wiki/API-Declaration>`_.
Этот файл может быть использован в `Swagger UI <https://github.com/wordnik/swagger-ui>`_
для генерации интерактивной документации.

Xitrum включает Swagger UI, по пути ``/xitrum/swagger-ui``,
например http://localhost:8000/xitrum/swagger-ui.

.. image:: ../img/swagger.png

Рассмотрим `пример <https://github.com/xitrum-framework/xitrum-placeholder>`_:

::

  import xitrum.{Action, SkipCsrfCheck}
  import xitrum.annotation.{GET, Swagger}

  @Swagger(
    Swagger.Tags("image", "APIs to create images"),
    Swagger.Description("Dimensions should not be bigger than 2000 x 2000"),
    Swagger.OptStringQuery("text", "Text to render on the image, default: Placeholder"),
    Swagger.Produces("image/png"),
    Swagger.Response(200, "PNG image"),
    Swagger.Response(400, "Width or height is invalid or too big")
  )
  trait ImageApi extends Action with SkipCsrfCheck {
    lazy val text = paramo("text").getOrElse("Placeholder")
  }

  @GET("image/:width/:height")
  @Swagger(  // <-- Inherits other info from ImageApi
    Swagger.Summary("Generate rectangle image"),
    Swagger.IntPath("width"),
    Swagger.IntPath("height")
  )
  class RectImageApi extends Api {
    def execute {
      val width  = param[Int]("width")
      val height = param[Int]("height")
      // ...
    }
  }

  @GET("image/:width")
  @Swagger(  // <-- Inherits other info from ImageApi
    Swagger.Summary("Generate square image"),
    Swagger.IntPath("width")
  )
  class SquareImageApi extends Api {
    def execute {
      val width  = param[Int]("width")
      // ...
    }
  }

`JSON для Swagger <https://github.com/wordnik/swagger-spec/blob/master/versions/1.2.md>`_
будет генерироваться при доступе ``/xitrum/swagger``.

Swagger UI использует эту информацию для генерации интерактивной документации к API.

Возможные параметры на подобии Swagger.IntPath определяются шаблоном:

* ``<Тип переменной><Тип параметра>`` (обязательный параметр)
* ``Opt<Тип переменной><Тип параметра>`` (опциональный параметр)

Типы переменных: Byte, Int, Int32, Int64, Long, Number, Float, Double, String, Boolean, Date, DateTime

Типы параметров: Path, Query, Body, Header, Form

Подробнее о `типах переменных <https://github.com/wordnik/swagger-core/wiki/Datatypes>`_
и `типах параметров <https://github.com/wordnik/swagger-core/wiki/Parameters>`_.
