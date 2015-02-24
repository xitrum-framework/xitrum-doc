Action and view
===============

Để linh hoạt, Xitrum cung cấp 3 loại actions sau:
``Action`` thông thường, ``FutureAction``, và ``ActorAction``.

Action thông thường
-------------------

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("hello")
  class HelloAction extends Action {
    def execute() {
      respondText("Hello")
    }
  }

Bởi vì các action sẽ chạy trực tiếp trên luồng (thread) IO của Netty nên các action không
nên tốn thời gian xử lý (block process), mặt khác nếu thời gian xử lý của thread IO của Netty 
kéo dài, Netty sẽ không còn khả năng đáp ứng các yêu cầu từ phía client hoặc không thể tiếp nhận
các kết nối mới.

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

FutureAction sẽ chạy trong cùng thread pool với ``ActorAction`` dưới đây, được tách
ra từ một phần của Netty thread pool.

Actor action
------------

Nếu vạn muốn action của bạn hoạt động như một Akka actor, hãy kế thừa nó từ ``ActorAction``:

::

  import scala.concurrent.duration._

  import xitrum.ActorAction
  import xitrum.annotation.GET

  @GET("actor")
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

Một actor instance sẽ được tạo khi có một yêu cầu (request), actor sẽ được dừng khi
đóng kết nối hoặc response được gửi bởi các method ``respondText``, ``respondView``, v.v.
Với chunked response, actor sẽ không dừng lại ngay lập tức mà dừng lại khi chunk cuối cùng
được gửi đi.

Actor này sẽ chạy trong thread pool của Akka actor có tên là "xitrum"

Gửi Respond cho client
--------------------------

Từ một action để trả về một respond cho phía client bạn có thể sử dụng những method sau:

* ``respondView``: trả về một tệp view 	, có hoặc không có layout
* ``respondInlineView``: trả về một 	 được nhúng (không phải một tệp 	 riêng lẻ), có hoặc không có layout
* ``respondText("hello")``: trả về một chuỗi ký tự không có layout
* ``respondHtml("<html>...</html>")``: như trên, với content type là "text/html"
* ``respondJson(List(1, 2, 3))``: chuyển đối tượng (object) Scala thành đối tượng JSON và trả về client.
* ``respondJs("myFunction([1, 2, 3])")``
* ``respondJsonP(List(1, 2, 3), "myFunction")``: kết hợp của 2 loại trên.
* ``respondJsonText("[1, 2, 3]")``
* ``respondJsonPText("[1, 2, 3]", "myFunction")``
* ``respondBinary``: trả về một mảng byte
* ``respondFile``: gửi file trực tiếp từ đĩa một cách nhanh chóng bằng kỹ thuật `zero-copy <http://www.ibm.com/developerworks/library/j-zerocopy/>`_ (aka send-file)
* ``respondEventSource("data", "event")`` gửi chunk respond

Gửi trả một 	 view file
------------------------------

Mỗi action có thể liên kết với `Scalate <http://scalate.fusesource.org/>`_
	 view file. Thay vì gửi tra trực tiếp ngay trong action với các method trên đây, bạn có
thể sử dụng một view file riêng biệt.

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

* ``xitrumCss`` bao gồm các tệp CSS mặc định cho Xitrum. Bạn có thể xóa nó nếu bạn không muốn
  sử dụng xitrum-framework.
* ``jsDefaults`` bao gồm các jQuery, jQuery Validate plugin, v.v, bạn nên đặt nó trong thẻ <head>
* ``jsForView`` bao gồm các đoạn mã JavaScript thêm bởi ``jsAddToView``, nên đặt ở phần cuối.

Trong 	 bạn có thể sử dụng các method của class `xitrum.Action <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/Action.scala>`_.
Không những thế bạn có thể sử dụng các utility methods cung cấp bởi Scalate điển hình như ``unescape``.

Xem thêm `Scalate doc <http://scalate.fusesource.org/documentation/index.html>`_.

	 mặc định của Scalate là `Jade <http://scalate.fusesource.org/documentation/jade.html>`_.
Bạn cũng có thể sử dụng `Mustache <http://scalate.fusesource.org/documentation/mustache.html>`_,
`Scaml <http://scalate.fusesource.org/documentation/scaml-reference.html>`_, hoặc `Ssp <http://scalate.fusesource.org/documentation/ssp-reference.html>`_.

Để cấu hình cho 	 mặc định, bạn có thể xem xitrum.conf tại thư mục config trong ứng dụng Xitrum

Bạn cũng có thể override 	 mặc định bằng cách truyền các giá trị "jade", "mustache", "scaml",hoặc "ssp" vào tham số "type" trong method `respondView`.

::

  val options = Map("type" ->"mustache")
  respondView(options)

Ép kiểu cho currentAction
~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu bạn muốn có chính xác instance của action hiện thời, bạn có thể ép kiểu cho (casting) ``currentAction`` thành action mà bạn mong muốn.

::

  p= currentAction.asInstanceOf[MyAction].hello("World")

Nếu bạn có có nhiều dòng code như dưới đây, bạn chỉ cần ép kiểu một lần duy nhất:

::

  - val myAction = currentAction.asInstanceOf[MyAction]; import myAction._

  p= hello("World")
  p= hello("Scala")
  p= hello("Xitrum")

Mustache
~~~~~~~~~

Các tài liệu tham khảo cho Mustache:

* `Mustache syntax <http://mustache.github.com/mustache.5.html>`_
* `Scalate implementation <http://scalate.fusesource.org/documentation/mustache.html>`_

Bạn không thể làm một vài điều với Mustache như với Jade bởi vì cú pháp của Mustache khá cứng nhắc và cần tuân thủ nghiêm ngặt.

Để truyền tham số từ action vào 	 của Mustache bạn phải sử dụng method ``at``:

Action:

::

  at("name") = "Jack"
  at("xitrumCss") = xitrumCss

Mustache 	:

::

  My name is {{name}}
  {{xitrumCss}}

Ghi nhớ rằng bạn không thể sử dụng các từ khóa dưới đây cho method ``at`` để truyền tham số cho Scalate 	, bởi vì chúng đã được sử dụng từ trước.

* "context": dùng cho đối tượng (object) Sclate utility, đối tượng này đã bao gồm các method như ``unescape``
* "helper": sử dụng cho đối tượng current action

CoffeeScript
~~~~~~~~~~~~

Bạn có thể nhúng CoffeeScript trong Scalate 	 bằng cách sử dụng:
`:coffeescript filter <http://scalate.fusesource.org/documentation/jade-syntax.html#filters>`_:

::

  body
    :coffeescript
      alert "Hello, Coffee!"

Output:

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

Nhưng bạn cũng nhớ rằng việc sử dụng chúng `tốn thời gian <http://groups.google.com/group/xitrum-framework/browse_thread/thread/6667a7608f0dc9c7>`_:

::

  jade+javascript+1thread: 1-2ms for page
  jade+coffesscript+1thread: 40-70ms for page
  jade+javascript+100threads: ~40ms for page
  jade+coffesscript+100threads: 400-700ms for page

Để tăng tốc độ bạn có thể generate CoffeeScript trước JavaScript.

Layout
------

Khi bạn gửi trả một view với ``respondView`` hoặc ``respondInlineView``, Xitrum sẽ chuyển nó thành một String, và đặt String đó trong biến ``renderedView``. Xitrum sau đó sẽ gọi đến method ``layout`` của current action, cuối cùng Xitrum sẽ gửi trả kết quả của method này về trình duyệt web.

Mặc định, medthod ``layout`` sẽ tự trả về ``renderedView``. Nếu bạn muốn trang trí cho view bạn cần override method này. Nếu bạn include ``renderView`` trong method này, view sẽ bao gồm các phần trong layout của bạn. 

Điểm mấu chốt ở đây là ``layout`` được gọi sau khi action view của bạn hiện lên, và trong mọi trường hợp đều trả về trình duyệt một kết quả. Kỹ thuật này khá đơn giản và rõ ràng. Nói một cách dễ hiểu hơn, bạn có thể nghĩ rằng sẽ không có một layout nào trong Xitrum. Tất cả chỉ xoay quanh method ``layout`` và bạn có thể làm bất cứ điều gì với method này.

Thông thường, bạn tạo một class cha bao gồm các layout chung:

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

Sử dụng layout không dùng tệp riêng biệt:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Truyền trực tiếp layout đến method respondView
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Thông thường, bạn viết view trong một tệp Scalate, ạn cũng có thể viết chúng trực tiếp như sau:
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
---------------

Giả sử tệp MyAction.jade có đường dẫn:
scr/main/scalate/mypackage/MyAction.jade

Nếu bạn muốn tạo tệp fragment trong cùng thư mục:
scr/main/scalate/mypackage/_MyFragment.jade

::

  renderFragment[MyAction]("MyFragment")

Nếu ``MyAction`` là current action, bạn có thể bỏ qua:

::

  renderFragment("MyFragment")

Trả về view cho action khác
----------------------------

Sử dụng cú pháp ``respondView[ClassName]()``:

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

Một action - nhiều view
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu bạn muốn có nhiều view cho một action:

::

  package mypackage

  import xitrum.Action
  import xitrum.annotation.GET

  // These are non-routed actions, for mapping to view 	 files:
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

Sử dụng các non-routed action như trên khá phức tạp, nhưng đó là cách typesafe.

Bạn cũng có thể sử dụng ``String``để chỉ ra đường dẫn đến 	:

::

  respondView("mypackage/HomeAction_NormalUser")
  respondView("mypackage/HomeAction_Moderator")
  respondView("mypackage/HomeAction_Admin")

Component
---------

Bạn có thể tạo và tái sử dụng các component của view.
Về cơ bản, một component gần giống với một action và có các tính chất sau:

* Component không có route, do đó không cần đến method ``execute``.
* Component không trả về một respond hoàn chỉnh, Component chỉ ``render`` ra các fragment của view. Do đó 
  trong một component, thay vì sử dụng ``repondXXX``, bạn hãy sử dụng ``renderXXX``.
* Giống với một action, một component có thể không có, có một, hoặc có nhiều view liên kết với nhau.

::

  package mypackage

  import xitrum.{FutureAction, Component}
  import xitrum.annotation.GET

  class CompoWithView extends Component {
    def render() = {
      // Render associated view 	, e.g. CompoWithView.jade
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
