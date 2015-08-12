JavaScript 와 JSON
===================

JavaScript
----------

Xitrum 은 jQuery를 내포하고 있습니다.

또한 일부 jsXXX 헬퍼도 제공하고 있습니다.

JavaScript 조각을 View 에 추가하는 방법
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

액션내에서 ``jsAddToView`` 를 호출합니다.（필요한 경우 여러번 호출이 가능합니다）:

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

레이아웃 내에서 ``jsForView`` 를 호출합니다:

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

JavaScript를 직접호출 하는 경우
~~~~~~~~~~~~~~~~~~~~~~~~~~

Javascript의 응답:

::

  jsRespond("$('#error').html(%s)".format(jsEscape(<p class="error">Could not login.</p>)))

Javascript로 리다이렉션 하는 경우:

::

  jsRedirectTo("http://cntt.tv/")
  jsRedirectTo[LoginAction]()

JSON
----

Xitrum은  `JSON4S <https://github.com/json4s/json4s>`_ 를 내포하고 있습니다.
JSON의 파싱과 생성은 JSON4S 을 읽어보세요.

Scala의 case 객체를 JSON으로 변환하는 경우:

::

  import xitrum.util.SeriDeseri

  case class Person(name: String, age: Int, phone: Option[String])
  val person1 = Person("Jack", 20, None)
  val json    = SeriDeseri.toJson(person)
  val person2 = SeriDeseri.fromJson(json)

JSON의 응답:

::

  val scalaData = List(1, 2, 3)  // An example
  respondJson(scalaData)

JSON은 중접된 구조로 되어 있는 문장을 만들기에 적합합니다.

참고 :doc:`설정 파일 읽어들이기 </howto>`

Knockout.js 플러그인
------------------

참고 `xitrum-ko <https://github.com/xitrum-framework/xitrum-ko>`_
