Статичные файлы
===============

Отправка статических файлов с диска
-----------------------------------

Шаблонная директория Xitrum проекта:

::

  config
  public
    favicon.ico
    robots.txt
    404.html
    500.html
    img
      myimage.png
    css
      mystyle.css
    js
      myscript.js
  src
  build.sbt

Xitrum использует директорию ``public`` для хранения статических файлов.
Для генерации ссылок на статические файлы:

::

  /img/myimage.png
  /css/mystyle.css
  /css/mystyle.min.css

Используйте шаблон:

::

  <img src={publicUrl("img/myimage.png")} />

Для работы с обычными файлами в режиме разработчика и их минимизированными версиями
(например, mystyle.css и mystyle.min.css), используйте шаблон:

::

  <img src={publicUrl("css", "mystyle.css", "mystyle.min.css")} />

Для отправки файла с диска из контроллера используйте метод ``respondFile``.

::

  respondFile("/absolute/path")
  respondFile("path/relative/to/the/current/working/directory")

Для оптимизации работы со статическими файлами, вы можете избежать использование
не нужны файлов ограничив их маской (фильтром на основе регулярного выражения).
Если запрос не будет соответствовать регулярному выражению, Xitrum ответит страницей
404 на этот зарос.

Смотри ``pathRegex`` в ``config/xitrum.conf``.

index.html и обработка отсутствующих маршрутов
----------------------------------------------

Если не существует контроллера для данного URL, например ``/foo/bar`` (или ``/foo/bar/``),
Xitrum попытается найти подходящий статический файл ``public/foo/bar/index.html``
(в директории "public"). Если файл существует, то он будет отправлен клиенту.

404 и 500
---------

404.html и 500.html в директории ``public`` используются когда маршрут не обнаружен или на сервере произошла ошибка. 
Пример использования своего собственного обработчика ошибок:

::

  import xitrum.Action
  import xitrum.annotation.{Error404, Error500}

  @Error404
  class My404ErrorHandlerAction extends Action {
    def execute() {
      if (isAjax)
        jsRespond("alert(" + jsEscape("Not Found") + ")")
      else
        renderInlineView("Not Found")
    }
  }

  @Error500
  class My500ErrorHandlerAction extends Action {
    def execute() {
      if (isAjax)
        jsRespond("alert(" + jsEscape("Internal Server Error") + ")")
      else
        renderInlineView("Internal Server Error")
    }
  }

Код ответа устанавливается в 404 или 500 еще до того как код контроллера будет запущен,
соответственно вам не нужно устанавливать его самостоятельно.

Использование файлов ресурсов в соответствии с WebJars 
------------------------------------------------------

WebJars
~~~~~~~

`WebJars <http://www.webjars.org/>`_ предоставляет множество библиотек которые вы можете 
объявить как зависимости вашего проекта.

Например, для использования `Underscore.js <http://underscorejs.org/>`_,
достаточно прописать в ``build.sbt``:

::

  libraryDependencies += "org.webjars" % "underscorejs" % "1.6.0-3"

После этого, в шаблоне .jade:

::

  script(src={webJarsUrl("underscorejs/1.6.0", "underscore.js", "underscore-min.js")})

Xitrum будет автоматически использовать ``underscore.js`` в режиме разработчика, и
``underscore-min.js`` в боевом режиме.

Результат будет таким:

::

  /webjars/underscorejs/1.6.0/underscore.js?XOKgP8_KIpqz9yUqZ1aVzw

Для использования в одного и того же файла во всех режимах:

::

  script(src={webJarsUrl("underscorejs/1.6.0/underscore.js")})

Хранение файлов ресурсов внутри .jar файла согласно WebJars
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Если вы разработчик библиотек и ваша библиотека включает myimage.png, то вы можете
сохранить myimage.png внутри .jar файла. Используя `WebJars <http://www.webjars.org/>`_, например:

::

  META-INF/resources/webjars/mylib/1.0/myimage.png

Использование в проекте:

::

  <img src={webJarsUrl("mylib/1.0/myimage.png")} />

Во всех режимах URL будет:

::

  /webjars/mylib/1.0/myimage.png?xyz123

Ответ файлом из classpath
~~~~~~~~~~~~~~~~~~~~~~~~~

Для ответа файлом находящимся внутри classpath (или внутри .jar файла), даже если файл
хранится не по стандарту `WebJars <http://www.webjars.org/>`_:

::

  respondResource("path/relative/to/the/classpath/element")

Например:

::

  respondResource("akka/actor/Actor.class")
  respondResource("META-INF/resources/webjars/underscorejs/1.6.0/underscore.js")
  respondResource("META-INF/resources/webjars/underscorejs/1.6.0/underscore-min.js")

Кэширование на стороне клиента с ETag и max-age
-----------------------------------------------

Xitrum автоматически добавляет `Etag <http://en.wikipedia.org/wiki/HTTP_ETag>`_ для
статических файлов на диске и в classpath.

ETag для маленьких файлов - MD5 хэш от контента файла. Они кэшируются для последующего использования.
Ключ кэша - ``(путь до файла, время изменения)``. Поскольку время изменения на разных серверах
может отличаться, каждый веб сервер в кластере имеет свой собственный ETag кэш.

Для больших файлов, только время изменения используется как ETag. Такая система не совершенна
поскольку идентичные файлы на разных серверах могут иметь различный ETag, но это все равно лучше
чем не использовать ETag вовсе.

``publicUrl`` и ``webJarsUrl`` автоматически добавляют ETag для ссылок. Например:

::

  webJarsUrl("jquery/2.1.1/jquery.min.js")
  => /webjars/jquery/2.1.1/jquery.min.js?0CHJg71ucpG0OlzB-y6-mQ

Xitrum так же устанавливает заголовки ``max-age`` и ``Expires`` в значение
`1 год <http://code.google.com/intl/en/speed/page-speed/docs/caching.html>`_.
Не переживайте, браузер все равно получит последнею версию файла. Потому что для
файлов хранящихся на диске, после изменении ссылка на файл меняется, т.к. генерируется с 
помощью ``publicUrl`` и ``webJarsUrl``. Их ETag кэш так же обновляется.

GZIP
----

Xitrum автоматически сжимает текстовые ответы. Проверяется заголовок ``Content-Type``
для определения текстового ответа: ``text/html``, ``xml/application`` и пр.

Xitrum всегда сжимает текстовые файлы, но для динамических ответов с целью 
повышения производительности ответы размером меньше 1 килобайта не сжимаются.

Кэш на стороне сервера
----------------------

Для избежания загрузки файлов с диска, Xitrum кэширует маленькие файлы
(не только текстовые) в LRU кэше (вытеснение давно неиспользуемых).
Смотри ``small_static_file_size_in_kb`` и ``max_cached_small_static_files``
в ``config/xitrum.conf``.
