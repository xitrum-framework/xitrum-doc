HOWTO
=====

Эта глава представляет некоторое число небольших примеров. Каждый пример достаточно
мал что бы писать отдельную главу.

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

Авторизация
-----------

Вы можете защитить весь сайт или некоторые контроллеры с использованием
`basic authentication (базовая аутентификация) <http://en.wikipedia.org/wiki/Basic_access_authentication>`_.

Важно: Xitrum не поддерживает
`digest authentication (цифровая аутентификация) <http://en.wikipedia.org/wiki/Digest_access_authentication>`_
поскольку она не так безопасна как кажется. Она подвержена ``man-in-the-middle`` атаке.
Для большей безопасности вы должны использовать HTTPS, поддержка которого встроена в Xitrum
(не нужен дополнительный прокси вроде Apache или Nginx).

Конфигурация для базовой аутентификации
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

В config/xitrum.conf:

::

  "basicAuth": {
    "realm":    "xitrum",
    "username": "xitrum",
    "password": "xitrum"
  }

Базовая аутентификация на конкретный контроллер
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  import xitrum.Action

  class MyAction extends Action {
    beforeFilter {
      basicAuth("Realm") { (username, password) =>
        username == "username" && password == "password"
      }
    }
  }

Загрузка конфигурационных файлов
--------------------------------

JSON файл
~~~~~~~~~

JSON подходит для конфигурационных файлов со сложной структурой.

Сохраняйте вашу конфигурацию в директорию "config". Эта директория попадает в classpath
в режиме разработки благодаря build.sbt и в боевом режиме благодаря скрипту запуска script/runner (и script/runner.bat).

myconfig.json:

::

  {
    "username": "God",
    "password": "Does God need a password?",
    "children": ["Adam", "Eva"]
  }

Загрузка:

::

  import xitrum.util.Loader

  case class MyConfig(username: String, password: String, children: List[String])
  val myConfig = Loader.jsonFromClasspath[MyConfig]("myconfig.json")

Замечания:

* Ключи и строки должны быть в двойных кавычках
* На данный момент нельзя писать комментарии в JSON файле

Файлы свойств (protperties)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Вы можете использовать файлы свойств, но рекомендуется использовать
JSON везде где это возможно. Файлы свойств не безопасны относительно типа, не поддерживают
UTF-8 и не подразумевают вложенность.

myconfig.properties:

::

  username = God
  password = Does God need a password?
  children = Adam, Eva

Загрузка:

::

  import xitrum.util.Loader

  // Here you get an instance of java.util.Properties
  val properties = Loader.propertiesFromClasspath("myconfig.properties")

Typesafe конфигурационный файл
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Xitrum включает Akka, которая включает
`конфигурационную библиотеку <https://github.com/typesafehub/config>`_ от
`Typesafe <http://typesafe.com/company>`_.
Возможно это самый лучший путь загрузки конфигурационных файлов.

myconfig.conf:

::

  username = God
  password = Does God need a password?
  children = ["Adam", "Eva"]

Загрузка:

::

  import com.typesafe.config.{Config, ConfigFactory}

  val config   = ConfigFactory.load("myconfig.conf")
  val username = config.getString("username")
  val password = config.getString("password")
  val children = config.getStringList("children")

Сериализация и десериализация
-----------------------------

Сериализация ``Array[Byte]``:

::

  val bytes = SeriDeseri.toBytes("my serializable object")

Десериализация:

::

  val option = SeriDeseri.fromBytes[MyType](bytes)  // Option[MyType]

Шифрование данных
-----------------

Xitrum предоставляет встроенное шифрование:

::

  import xitrum.util.Secure

  // Array[Byte]
  val encrypted = Secure.encrypt("my data".getBytes)

  // Option[Array[Byte]]
  val decrypted = Secure.decrypt(encrypted)

Вы можете использовать ``xitrum.util.UrlSafeBase64`` для кодирования и декодирования бинарных данных
в обычную строку.

::

  // Строка которая может быть использована как URL или в куки
  val string = UrlSafeBase64.noPaddingEncode(encrypted)

  // Option[Array[Byte]]
  val encrypted2 = UrlSafeBase64.autoPaddingDecode(string)

Или короче:

::

  import xitrum.util.SeriDeseri

  val mySerializableObject = new MySerializableClass

  // String
  val encrypted = SeriDeseri.toSecureUrlSafeBase64(mySerializableObject)

  // Option[MySerializableClass]
  val decrypted = SeriDeseri.fromSecureUrlSafeBase64[MySerializableClass](encrypted)

``SeriDeseri`` использует `Twitter Chill <https://github.com/twitter/chill>`_
для сериализации и десериализации. Ваши данные должны быть сериализуемыми.

Вы можете задать ключ шифрования.

::

  val encrypted = Secure.encrypt("my data".getBytes, "my key")
  val decrypted = Secure.decrypt(encrypted, "my key")

::

  val encrypted = SeriDeseri.toSecureUrlSafeBase64(mySerializableObject, "my key")
  val decrypted = SeriDeseri.fromSecureUrlSafeBase64[MySerializableClass](encrypted, "my key")

Если ключ не указан, то ``secureKey`` из xitrum.conf будет использован.

Множество сайтов на одном доменном имени
----------------------------------------

При использовании прокси, например, Nginx, для запуска нескольких сайтов на одном
доменном имени:

::

  http://example.com/site1/...
  http://example.com/site2/...

Вы можете указать baseUrl в config/xitrum.conf.

В JS коде, для того что бы использовать корректные ссылки в Ajax запросах, используйте ``withBaseUrl``
из `xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_.

::

  # Если текущий сайт имеет baseUrl "site1", результат будет:
  # /site1/path/to/my/action
  xitrum.withBaseUrl('/path/to/my/action')

Преобразование разметки (markdown) в HTML
-----------------------------------------

Если ваш проект использует :doc:`шаблонизатор Scalate </template_engines>`,
тогда:

::

  import org.fusesource.scalamd.Markdown
  val html = Markdown("input")

В другом случае, вам нужно добавить зависимость в build.sbt:

::

  libraryDependencies += "org.fusesource.scalamd" %% "scalamd" % "1.6"

Мониторинг изменений файлов
---------------------------

Вы можете зарегистрировать слушателя изменений файлов и директорий
`StandardWatchEventKinds <http://docs.oracle.com/javase/7/docs/api/java/nio/file/StandardWatchEventKinds.html>`_.

::

  import java.nio.file.Paths
  import xitrum.util.FileMonitor

  val target = Paths.get("absolute_path_or_path_relative_to_application_directory").toAbsolutePath
  FileMonitor.monitor(FileMonitor.MODIFY, target, { path =>
    // Do some callback with path
    println(s"File modified: $path")

    // And stop monitoring if necessary
    FileMonitor.unmonitor(FileMonitor.MODIFY, target)
  })

``FileMonitor`` внутри себя использует
`Schwatcher <https://github.com/lloydmeta/schwatcher>`_.
