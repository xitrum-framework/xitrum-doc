JavaScript и JSON
===================

JavaScript
----------

Xitrum включает jQuery (опционально) с дополнительным набором утильных функций jsXXX.

Вставка JavaScript фрагментов в представление
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

В контроллере вы можете использовать метод ``jsAddToView`` (множество раз, если необходимо):

::

  class MyAction extends AppAction {
    def execute() {
      ...
      jsAddToView("alert('Hello')")
      ...
      jsAddToView("alert('Hello again')")
      ...
      respondInlineView(<p>My view</p>)
    }
  }

В шаблоне метод ``jsForView``:

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
        </head>
        <body>
          <div id="flash">{jsFlash}</div>
          {renderedView}
          {jsForView}
        </body>
      </html>
    )

Отправка JavaScript непосредственно (без представления)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Для отправки JavaScript:

::

  jsRespond("$('#error').html(%s)".format(jsEscape(<p class="error">Could not login.</p>)))

Для редиректа:

::

  jsRedirectTo("http://cntt.tv/")
  jsRedirectTo[LoginAction]()

JSON
----

Xitrum включает `JSON4S <https://github.com/json4s/json4s>`_.
Пожалуйста прочтите документацию проекта о том как считывать и генерировать JSON.

Конвертация case объекта в строку JSON:

::

  import xitrum.util.SeriDeseri

  case class Person(name: String, age: Int, phone: Option[String])
  val person1 = Person("Jack", 20, None)
  val json    = SeriDeseri.toJson(person1)
  val person2 = SeriDeseri.fromJson[Person](json)

Отправка JSON клиенту:

::

  val scalaData = List(1, 2, 3)  // Например
  respondJson(scalaData)

JSON так же полезен для написания конфигурационных файлов со вложенными структурами.
Смотри :doc:`Загрузка конфигурационных файлов </howto>`.

Плагин для Knockout.js
----------------------

Смотри https://github.com/xitrum-framework/xitrum-ko
