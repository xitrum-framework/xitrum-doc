Action 과 view
===============

유연함을 위해, Xitrum은 3가지 형태의 Action을 제공합니다.
보통``Action``、``FutureAction``、그리고``ActorAction``입니다.

Normal Action
-------------

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("hello")
  class HelloAction extends Action {
    def execute() {
      respondText("Hello")
    }
  }

요청은 Netty의 IO스레드로 직접로 처리되므로、시간이 걸리는 처리（블록처리）를 포함하면 안됩니다.
Netty 의 IO쓰레드 를 오래 사용하게 되면 Netty는 새로운 연결을 할 수 없거나 응답을 회신할 수 없게 되기 때문입니다.

FutureAction
------------

::

  import xitrum.FutureAction
  import xitrum.annotation.GET

  @GET("hello")
  class HelloAction extends FutureAction {
    def execute() {
      respondText("hi")
    }
  }

요청은 Netty의 스레드 풀과는 별개로 다음의``ActorAction`` 과 같은 스레드 풀에서 처리됩니다.

Actor Action
------------

Action 을 Akka actor 처럼 정의하려면 、``ActorAction``을 상속하면 됩니다.

::

  import scala.concurrent.duration._

  import xitrum.ActorAction
  import xitrum.annotation.GET

  @GET("hello")
  class HelloAction extends ActorAction {
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

Actor 인스턴스는 요청이 발생할때 생성됩니다. 이 actor 인스턴스는 연결이 끊어지거나、
``respondText``, ``respondView``등의 메소드를 통해 응답을 얻을때 중지됩니다.
청크응답의 경우 즉시 중지되지 않고、마지막 청크가 전송된 시점에서 중지됩니다.

요청은 "xitrum" 이라고 불리는 Akka actor 시스템 스레드 풀에서 처리됩니다.

클라이언트로의 전송
--------------

Action으로 부터 클라이언트로 응답을 전송하려면 다음과 같은 방법을 사용합니다

* ``respondView``: 레이아웃을 포함하거나 포함하지 않고、View 템플릿을 전송합니다
* ``respondInlineView``: 레이아웃을 포함하거나 포함하지 않고、인라인으로 작성된 템플릿을 전송합니다
* ``respondText("hello")``: 레이아웃 파일을 사용하지 않고 문자열을 보냅니다
* ``respondHtml("<html>...</html>")``: contentType 을 "text/html" 형식으로 문자열을 보냅니다
* ``respondJson(List(1, 2, 3))``: Scala 객체를 JSON 으로 변환하여、contentType 을 "application/json" 형식으로 보냅니다
* ``respondJs("myFunction([1, 2, 3])")`` contentType 을 "application/javascript" 으로 문자열을 보냅니다
* ``respondJsonP(List(1, 2, 3), "myFunction")``: 위 두가지를 조합하여 JSONP로 보냅니다
* ``respondJsonText("[1, 2, 3]")``: contentType 을 "application/javascript" 으로 문자열을 보냅니다
* ``respondJsonPText("[1, 2, 3]", "myFunction")``: `respondJs` 、 `respondJsonText` 의 두가지 조합을 JSONP로 보냅니
* ``respondBinary``: 바이트 배열로 보냅니다
* ``respondFile``: 디스크에서 파일을 직접보냅니다. `zero-copy <http://www.ibm.com/developerworks/library/j-zerocopy/>`_ 를 사용하기 때문에 매우 빠릅니다.
* ``respondEventSource("data", "event")``: 청크응답을 보냅니다

템플릿 View 파일 응답
-----------------

모든 Action은  `Scalate <http://scalate.fusesource.org/>`_ 의 템플릿 View 파일과 연관이 있습니다.
위의 응답방식을 사용하여 직접 응답을 보내는 대신 별도의 View파일을 사용하여 응답을 보낼 수 있습니다.

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

* ``xitrumCss`` Xitrum 의 기본 CSS파일입니다.삭제해도 무방합니다.
* ``jsDefaults`` jQuery, jQuery Validate plugin등을 포함하고 있습니다.<head>안에 명시해야 합니다.
* ``jsForView`` ``jsAddToView`` 에 의해 추가된 javascript가 출력됩니다.레이아웃의 끝에 명시해야 합니다.

템플릿 파일에서 `xitrum.Action <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/Action.scala>`_ 클래스의 모든 파일을 사용할 수 있습니다.
또한、``unescape`` 같은 Scalate 유틸리티도 사용할 수 있습니다.Scalate 의 유틸리티는 `Scalate doc <http://scalate.fusesource.org/documentation/index.html>`_　를 참고하세요.

Scalate 템플릿의 기본 유형은 `Jade <http://scalate.fusesource.org/documentation/jade.html>`_ 를 사용하고 있습니다.
또한 `Mustache <http://scalate.fusesource.org/documentation/mustache.html>`_ 、
`Scaml <http://scalate.fusesource.org/documentation/scaml-reference.html>`_ 、
`Ssp <http://scalate.fusesource.org/documentation/ssp-reference.html>`_ 를 선택할 수 있습니다.
템플릿의 기본 유형을 、어플리케이션의 config 디렉토리내의 `xitrum.conf`에서 설정할 수 있습니다.

`respondView` 메소드의 type 매개변수로 "jade"、 "mustache"、"scaml"、"ssp" 중 하나를 지정하여 기본 템플릿 유형을 무시하고 사용할 수 있습니다.

::

  val options = Map("type" ->"mustache")
  respondView(options)

currentAction의 캐스팅
~~~~~~~~~~~~~~~~~~~~

지금의 Action의 인스턴스를 정확하게 지정하려면 、``currentAction`` 를 지정한 Action 캐스팅합니다.

::

  p= currentAction.asInstanceOf[MyAction].hello("World")

여러줄로 사용하는 경우 、캐스트 처리를 한번만 호출합니다.

::

  - val myAction = currentAction.asInstanceOf[MyAction]; import myAction._

  p= hello("World")
  p= hello("Scala")
  p= hello("Xitrum")

Mustache
~~~~~~~~

Mustache에 대한 참고자료:

* `Mustache syntax <http://mustache.github.com/mustache.5.html>`_
* `Scalate implementation <http://scalate.fusesource.org/documentation/mustache.html>`_

Mustach의 구문위반에 강력해서、Jade 에서 할 수 있는 작업중 일부는 사용할 수 없습니다.

Action 에서 뭔가 값을 전달할 경우 、``at`` 메소드를 사용합니다.

Action:

::

  at("name") = "Jack"
  at("xitrumCss") = xitrumCss

Mustache template:

::

  My name is {{name}}
  {{xitrumCss}}

주의:다음키는 예약어 이므로、 ``at`` 메소드를 통해 Scalate 템플릿에 전달할 수 없습니다.

* "context": ``unescape`` 등의 메소드를 포함하여 Scalate 객체
* "helper": 현재 Action 객체

CoffeeScript
~~~~~~~~~~~~

`:coffeescript filter <http://scalate.fusesource.org/documentation/jade-syntax.html#filters>`_ 를 사용하여
CoffeeScript템플릿에 배포 할 수 있습니다.

::

  body
    :coffeescript
      alert "Hello, Coffee!"

출력결과:

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

주의: 그러나 이 작업은 `slow <http://groups.google.com/group/xitrum-framework/browse_thread/thread/6667a7608f0dc9c7>`_ 문제가 있습니다.

::

  jade+javascript+1thread: 1-2ms for page
  jade+coffesscript+1thread: 40-70ms for page
  jade+javascript+100threads: ~40ms for page
  jade+coffesscript+100threads: 400-700ms for page

빠른속도로 동작시키기 위해서는 미리 CoffeeScript에서 Javascript를 생성해야 합니다.

레이아웃
----------

``respondView`` 또 ``respondInlineView`` 를 사용하여 View를 보낸경우
Xitrum은 결과 문자열을 、``renderedView`` 변수로 설정합니다.
그리고 현재 Action의 ``layout`` 메소드가 실행됩니다.
브라우저에 전송되는 데이터는 결국 이 메소드의 결과가 표시됩니다.

기본적으로、``layout`` 메소드는 단지 ``renderedView`` 를 호출합니다.
만약、이 처리방법에 무언가를 추가하려면 、재정의가 필요합니다.만약 、 ``renderedView`` 메소드에 포함하려는 경우、
이 View의 레이아웃의 일부로 포함됩니다.

포인트는  ``layout`` 현재의 Action View가 실행된 후라는 것입니다.
거기에서 반환되는 값이 브라우저에 전달이 되는것 입니다.

이 메커니즘은 매우 간단하고 마법이 없습니다.간단하게 Xitrum 에는 레이아웃이 존재하지 않는다고 생각할 수 있습니다.
거기에는 단지 ``layout`` 메소드가 있을뿐、모두 이 방법으로 표현할 수 있습니다.


전형적인 예로、로일반적인 레이아웃을 부모 클래스로 사용하는 패턴을 보여줍니다.

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


독립적인 레이아웃 파일을 사용하지 않는 패턴
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

respondView 레이아웃을 직접 패스
~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Inline view
-----------

일반적인 Scalate 파일에 포함되지만 、직접Action에 표기할 수 있습니다.

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

Render fragment
--------------

MyAction.jade가
``scr/main/scalate/mypackage/MyAction.jade``
에 있는경우 :
같은 디렉토리에 있는 조각파일을 반환하는 경우:
``scr/main/scalate/mypackage/_MyFragment.jade``


::

  renderFragment[MyAction]("MyFragment")

현재 Action이 ``MyAction``의 경우, 다음과 같이 생략이 가능합니다:

::

  renderFragment("MyFragment")

다른 Action의 View를 응답하는 경우
----------------------------

다음의 메소드를 사용합니다 ``respondView[ClassName]()``:

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

하나의 Action - 여러 View사용
~~~~~~~~~~~~~~~~~~~~~~~~~

::

  package mypackage

  import xitrum.Action
  import xitrum.annotation.GET

  // These are non-routed actions, for mapping to view template files:
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

위와 같이 라우팅과 상관없는 작업을 설명하는것이 어려워 보일수는 있지만
이 방법은 프로그램이 형식에 대해 안정성을 유지할 수 있습니다.

``String`` 값을 이용하여 템블릿 위치를 지정할 수도 있습니다:

::

  respondView("mypackage/HomeAction_NormalUser")
  respondView("mypackage/HomeAction_Moderator")
  respondView("mypackage/HomeAction_Admin")

Component
---------

여러 View에 통합 할 수 있는 재사용이 가능한 구성요소를 생성 수 있습니다.
구성 요소의 개념은 액션과 매우 비슷합니다.
다음과 같은 특징이 있습니다.

* 구성요소는 루트가 없습니다.즉, ``execute`` 메소드는 필요가 없습니다.
* 구성요소는 전체 응답을 반환하지 않습니다. 단편적인 view를 "render" 하기만 합니다.
  따라서、구성요소 내부에서 ``respondXXX`` 대신 ``renderXXX`` 호출해야 합니다.
* Action처럼、구성요소는 단일 혹은 여러 View와 연관이 있거나、또는 연관성없이 사용할 수 있습니다.


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
