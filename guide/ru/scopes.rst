Запросы, параметры, куки, сессии
================================

Запросы
-------

Типы параметров
~~~~~~~~~~~~~~~

Доступны два вида параметров запроса: текстовые параметры и параметры файлы (file upload, бинарные данные)

Текстовые параметры делятся на три вида, каждый имеет тип ``scala.collection.mutable.Map[String, List[String]]``:

1. ``uriParams``: параметры после символа ? в ссылке, например: http://example.com/blah?x=1&y=2
2. ``bodyParams``: параметры в теле POST запроса
3. ``pathParams``: параметры в пути запроса, например: ``GET("articles/:id/:title")``

Параметры собираются воедино в переменной ``textParams`` в следующем порядке
(от 1 к 3, более поздние перекрывают более ранние).

``fileUploadParams`` имеет тип scala.collection.mutable.Map[String, List[`FileUpload <http://netty.io/4.0/api/io/netty/handler/codec/http/multipart/FileUpload.html>`_]].

Доступ к параметрам
~~~~~~~~~~~~~~~~~~~

Из контроллера в можете получить доступ к параметрам напрямую, или вы можете использовать
методы доступа.

Для доступа к ``textParams``:

* ``param("x")``: возвращает ``String``, выбрасывает исключение если x не существует
* ``params("x")``: возвращает ``List[String]``, выбрасывает исключение если x не существует
* ``paramo("x")``: возвращает ``Option[String]``
* ``paramso("x")``: возвращает ``Option[List[String]]``

Вы можете преобразовывать их к другим типам (Int, Long, Fload, Double) автоматически
используя ``param[Int]("x")``, ``params[Int]("x")`` и пр. Для преобразования текстовых параметров к
другим типам, перекройте метод `convertTextParam <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala-2.11/xitrum/scope/request/ParamAccess.scala>`_.

Для параметров файлов: ``param[FileUpload]("x")``, ``params[FileUpload]("x")`` и пр.
Более подробно, смотри :doc:`Загрузка файлов </upload>`.

"at"
~~~~

Для передачи данных из контроллера в представление вы можете использовать ``at``.
Тип ``at`` - ``scala.collection.mutable.HashMap[String, Any]``.
Если вы знакомы с Rails, ``at`` это аналог ``@`` из Rails.

Articles.scala

::

  @GET("articles/:id")
  class ArticlesShow extends AppAction {
    def execute() {
      val (title, body) = ...  // Например, получаем из базы данных
      at("title") = title
      respondInlineView(body)
    }
  }

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
          <title>{if (at.isDefinedAt("title")) "My Site - " + at("title") else "My Site"}</title>
        </head>
        <body>
          {renderedView}
          {jsForView}
        </body>
      </html>
    )
  }

"atJson"
~~~~~~~~

``atJson`` - утильный метод который автоматически конвертирует ``at("key")`` в JSON.
Метод может быть полезен для передачи моделей напрямую из Scala в JavaScript.

``atJson("key")`` эквивалент ``xitrum.util.SeriDeseri.toJson(at("key"))``:

Action.scala

::

  case class User(login: String, name: String)

  ...

  def execute() {
    at("user") = User("admin", "Admin")
    respondView()
  }

Action.ssp

::

  <script type="text/javascript">
    var user = ${atJson("user")};
    alert(user.login);
    alert(user.name);
  </script>

RequestVar
~~~~~~~~~~

У ``at`` есть недостаток, он не безопасен относительно типов, т.к. основан на не типизированной коллекции. Если вам нужна большая безопасность, можно использовать идею RequestVar, которая оборачивает ``at``.

RVar.scala

::

  import xitrum.RequestVar

  object RVar {
    object title extends RequestVar[String]
  }

Articles.scala

::

  @GET("articles/:id")
  class ArticlesShow extends AppAction {
    def execute() {
      val (title, body) = ...  // Get from DB
      RVar.title.set(title)
      respondInlineView(body)
    }
  }

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
          <title>{if (RVar.title.isDefined) "My Site - " + RVar.title.get else "My Site"}</title>
        </head>
        <body>
          {renderedView}
          {jsForView}
        </body>
      </html>
    )
  }

Куки
----

Подробнее о `куки <http://en.wikipedia.org/wiki/HTTP_cookie>`_.

Внутри контроллера, используйте ``requestCookies``, для чтения кук отправленных браузером (тип ``Map[String, String]``).

::

  requestCookies.get("myCookie") match {
    case None         => ...
    case Some(string) => ...
  }

Для отправки куки браузеру, создайте экземпляр `DefaultCookie <http://netty.io/4.0/api/io/netty/handler/codec/http/DefaultCookie.html>`_ и добавьте его к массиву ``responseCookies`` который хранит все `куки <http://netty.io/4.0/api/io/netty/handler/codec/http/Cookie.html>`_.

::

  val cookie = new DefaultCookie("name", "value")
  cookie.setHttpOnly(true)  // true: JavaScript не может получить доступ к куки
  responseCookies.append(cookie)

Если вы не укажите путь для через метод ``cookie.setPath(cookiePath)``, то
будет использован корень сайта как путь (``xitrum.Config.withBaseUrl("/")``).
Это позволяет избежать случайного дублирования кук.

Что бы удалить куку отправленную браузером, отправить куку с тем же именем и с
временем жизни 0. Браузер посчитает ее истекшей. Для того что бы создать куку
удаляемую при закрытии браузере, установите время жизни в ``Long.MinValue``:

::

  cookie.setMaxAge(Long.MinValue)

`Internet Explorer не поддерживает "max-age" <http://mrcoles.com/blog/cookies-max-age-vs-expires/>`_,
но Netty умеет это определять и устанавливает "max-age" и "expires" должны образом. Не беспокойтесь!

Браузер не отправляет атрибуты куки обратно на сервер. Браузер отправляет
`только пары имя-значение <http://en.wikipedia.org/wiki/HTTP_cookie#Cookie_attributes>`_.

Если вы хотите подписать ваши куки, что бы защититься от подделки, используйте
``xitrum.util.SeriDeseri.toSecureUrlSafeBase64`` и ``xitrum.util.SeriDeseri.fromSecureUrlSafeBase64``.
Подробнее смотри :doc:`Как шифровать данные </howto>`.

Допустимые символы в куки
~~~~~~~~~~~~~~~~~~~~~~~~~

Вы можете использовать только `ограниченный набор символов в куки <http://stackoverflow.com/questions/1969232/allowed-characters-in-cookies>`_.
Например, если вам нужно передать UTF-8 символы, вы должны закодировать их. Можно использовать, например, ``xitrum.utill.UrlSafeBase64`` или ``xitrum.util.SeriDeseri``.

Пример записи куки:

::

  import io.netty.util.CharsetUtil
  import xitrum.util.UrlSafeBase64

  val value   = """{"identity":"example@gmail.com","first_name":"Alexander"}"""
  val encoded = UrlSafeBase64.noPaddingEncode(value.getBytes(CharsetUtil.UTF_8))
  val cookie  = new DefaultCookie("profile", encoded)
  responseCookies.append(cookie)

Чтение куки:

::

  requestCookies.get("profile").foreach { encoded =>
    UrlSafeBase64.autoPaddingDecode(encoded).foreach { bytes =>
      val value = new String(bytes, CharsetUtil.UTF_8)
      println("profile: " + value)
    }
  }

Сессии
------

Хранение сессии, восстановление, шифрование и прочее выполняются автоматически.

В контроллере, вы можете использовать переменную ``session``, которая имеет тип
``scala.collection.mutable.Map[String, Any]``. Значения в ``session`` должны быть
сериализуемые.

Например, что бы сохранить что пользователь прошел авторизацию, вы можете сохранить
его имя в сессии:

::

  session("userId") = userId

Позднее, если вы хотите убедиться что пользователь авторизован, вы просто проверяете
есть ли его имя в сессии:

::

  if (session.isDefinedAt("userId")) println("This user has logged in")

Хранение идентификатора пользователя и загрузка его из базы данных при каждом запросе
обычно является не плохим решением. В этом случае информация о пользователе обновляется
при каждым запросе (включая изменения в правах доступа).

session.clear()
~~~~~~~~~~~~~~~

`Одна строчка кода позволяет защититься от фиксации сессии <http://guides.rubyonrails.org/security.html#session-fixation>`_.

Прочитайте статью по ссылке выше что бы узнать подробнее про эту атаку. Для защиты
от атаки, в контроллере который использует логин пользователя, вызовете ``session.clear()``.

::

  @GET("login")
  class LoginAction extends Action {
    def execute() {
      ...
      session.clear()  // Сброс сессии прежде чем выполнять какие либо дейтсвияthe session
      session("userId") = userId
    }
  }

Это касается так же контроллера, который выполняет "выход пользователя" (log out).

SessionVar
~~~~~~~~~~

SessionVar, как и RequestVar, это способ сделать сессию более безопасной.

Например, вы хотите хранить имя пользователя в сессии после того как он прошел авторизацию:

Объявите session var:

::

  import xitrum.SessionVar

  object SVar {
    object username extends SessionVar[String]
  }

Присвойте значение во время авторизации:

::

  SVar.username.set(username)

Отобразите имя пользователя:

::

  if (SVar.username.isDefined)
    <em>{SVar.username.get}</em>
  else
    <a href={url[LoginAction]}>Login</a>

* Для удаления используйте: ``SVar.username.delete()``
* Для сброса всей сессии используйте: ``session.clear()``

Хранилище сессии
~~~~~~~~~~~~~~~~

В файле `config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_
есть возможность настроить хранилище сессии:

Хранилище может быть объявлено в двух видах:

::

  store = my.session.StoreClassName

Или:

::

  store {
    "my.session.StoreClassName" {
      option1 = value1
      option2 = value2
    }
  }

Из коробки Xitrum предоставляет 2 простых хранилища:

::

  # Хранение сессии на стороне клиента в куках
  store = xitrum.scope.session.CookieSessionStore

И:

::

  # Простое хранилище на стороне сервера
  store {
    "xitrum.local.LruSessionStore" {
      maxElems = 10000
    }
  }

Рекомендуется хранить сессии на стороне сервера
(`хранение состояния на сервере <https://github.com/xitrum-framework/xitrum-imperatively>`_),
поскольку состояние часто имеет больше размер чем можно сохранить в куки.

Если вы запускаете несколько серверов, вы можете использовать
`Hazelcast для хранения кластеризованных сессии <https://github.com/xitrum-framework/xitrum-hazelcast>`_.

Важно, если вы используете ``CookieSessionStore`` или Hazelcast, ваши данные должны быть сериализуемыми. Если
ваши данные не подлежат сериализации используйте ``LruSessionStore``.
При использовании ``LruSessionStore`` вы можете кластеризовать сессии используя load balancer и sticky sessions.

Эти три типа хранилища сессии обычно покрывают все необходимые случаи. Существует
возможность определить свою реализацию хранилища сессии, используйте наследование от
`SessionStore <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/session/SessionStore.scala>`_
или
`ServerSessionStore <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/session/ServerSessionStore.scala>`_ и реализуйте абстрактные методы.

Используйте куки когда это возможно, поскольку они более масштабируемы.
Храните сессии на сервере (в памяти или базе данных) если это необходимо.

Дальнейшее чтение:
`Web Based Session Management - Best practices in managing HTTP-based client sessions <http://www.technicalinfo.net/papers/WebBasedSessionManagement.html>`_.

object vs. val
--------------

Пожалуйста, используйте ``object`` вместо ``val``.

**Не делайте так**:

::

  object RVar {
    val title    = new RequestVar[String]
    val category = new RequestVar[String]
  }

  object SVar {
    val username = new SessionVar[String]
    val isAdmin  = new SessionVar[Boolean]
  }

Приведенный код компилируется но не работает корректно, потому что Vars внутри
себя используют имена классов что бы выполнять поиск. При использовании
``val``, ``title`` и ``category`` мы имеем тоже самое имя класса "xitrum.RequestVar".
Одно и тоже как и для ``username`` и ``isAdmin``.
