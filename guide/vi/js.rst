JavaScript and JSON
===================

JavaScript
----------

Xitrum đã inlcude jQuery. Có một vài jsXXX helper.

Thêm các đoạn JavaScript vào một view
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trong action, gọi method ``jsAddToView`` (nhiều lần nếu cần):

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

Trong layout, gọi method ``jsForView``:

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

Respond JavaScript trực tiếp không sử dụng view
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để respond JavaScript:

::

  jsRespond("$('#error').html(%s)".format(jsEscape(<p class="error">Could not login.</p>)))

Một các trực tiếp:

::

  jsRedirectTo("http://cntt.tv/")
  jsRedirectTo[LoginAction]()

JSON
----

Xitrum đã include `JSON4S <https://github.com/json4s/json4s>`_.
Bạn có thể đọc thêm để biết các parse và generate ra JSON.

Để convert từ Scala case object thành JSON string và ngược lại:

::

  import xitrum.util.SeriDeseri

  case class Person(name: String, age: Int, phone: Option[String])
  val person1 = Person("Jack", 20, None)
  val json    = SeriDeseri.toJson(person1)
  val person2 = SeriDeseri.fromJson[Person](json)

Để respond JSON:

::

  val scalaData = List(1, 2, 3)  // An example
  respondJson(scalaData)

JSON cũng thuận tiện cho các tệp cấu hình cần tới các cấu trúc lồng nhau:
Xem :doc:`Load config files </howto>`.

Plugin cho Knockout.js
----------------------

Xem https://github.com/xitrum-framework/xitrum-ko
