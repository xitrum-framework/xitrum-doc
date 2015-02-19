Scopes
======

Request
-------

Các loại parameter
~~~~~~~~~~~~~~~~~~

Có 2 loại request parameter: textual parameter và file upload parameter (binary).

Có 3 loại textual parameter, thuộc kiểu ``scala.collection.mutable.Map[String, Seq[String]]``:

1. ``queryParams``: parameter nằm sau dấu ? trong URL ,ví dụ : http://example.com/blah?x=1&y=2
2. ``bodyTextParams``: parameter trong phần body của POST request
3. ``pathParams``: parameter nhúng trong URL, ví dụ: ``GET("articles/:id/:title")``

Các parameter được gộp thành kiểu ``textParams`` (từ 1 đến 3, kiểu sau sẽ override kiểu trước).

``bodyFileParams`` thuộc kiểu scala.collection.mutable.Map[String, Seq[`FileUpload <http://netty.io/4.0/api/io/netty/handler/codec/http/multipart/FileUpload.html>`_]].

Accesing parameter
~~~~~~~~~~~~~~~~~~

Từ một action, bạn có thể truy cập đến các parameter trực tiếp, hoặc bạn có thể 
sử dụng các accessor method.

Để truy cập ``textParams``:

* ``param("x")``: trả về ``String``, throws exception nếu x không tồn tại
* ``paramo("x")``: trả về ``Option[String]``
* ``params("x")``: trả về ``Seq[String]``, Seq.empty nếu x không tồn tại

Bạn có thể convert các text parameter thành các kiểu khác như Int, Long, Float, Double 
một các tự động bằng cách sử dụng ``param[Int]("x")``, ``params[Int]("x")`` v.v. Để convert
các text parameter thành các kiểu khác, override 
`convertTextParam <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala-2.11/xitrum/scope/request/ParamAccess.scala>`_.

Với các file upload parameter: ``param[FileUpload]("x")``, ``params[FileUpload]("x")`` v.v.
Để biết chi tiết, hãy xem :doc:`Upload chapter </upload>`.

"at"
~~~~

Để truyền tham số khi thực hiện một request (từ action đến view hoặc layout), có thể 
sử dụng ``at``. ``at`` thuộc kiểu ``scala.collection.mutable.HashMap[String, Any]``.
Nếu bạn từng tiếp xúc với Rails, bạn sẽ nhận ra rằng ``at`` là một bản sao của ``@`` 
trong Rails.

Articles.scala

::

  @GET("articles/:id")
  class ArticlesShow extends AppAction {
    def execute() {
      val (title, body) = ...  // Get from DB
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

``atJson`` là một helper method tự động convert ``at("key")`` sang JSON.
Nếu bạn chuyển model từ Scala sang JavaScript.


``atJson("key")`` tương đương với ``xitrum.util.SeriDeseri.toJson(at("key"))``:

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

``at`` không typesafe bởi vì bạn có thể đặt mọi thứ vào trong map. Để typesafe 
hơn, bạn nên sử dụng RequestVar một class đóng gói ``at``.

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

Cookie
------

Bạn có thể đọc thêm Wikipedia về `cookies <http://en.wikipedia.org/wiki/HTTP_cookie>`_.

Trong một action, sử dụng ``requestCookies``, ``Map[String, String]``, để đọc cookie 
gửi bởi browser.

::

  requestCookies.get("myCookie") match {
    case None         => ...
    case Some(string) => ...
  }

Để gửi cookie đến browser, tạo một `DefaultCookie <http://netty.io/4.0/api/io/netty/handler/codec/http/DefaultCookie.html>`_
và thêm nó vào ``responseCookies``, một ``ArrayBuffer`` đã bao gồm `Cookie <http://netty.io/4.0/api/io/netty/handler/codec/http/Cookie.html>`_.

::

  val cookie = new DefaultCookie("name", "value")
  cookie.setHttpOnly(true)  // true: JavaScript cannot access this cookie
  responseCookies.append(cookie)

Nếu bạn không set path của cookie bằng cách gọi ``cookie.setPath(cookiePath)``,
đường path của nó sẽ được gán là root path của site (``xitrum.Config.withBaseUrl("/")``).
Việc này đề phòng việc trùng lặp cookie.

Để xóa cookie gửi bởi browser, gửi một cookie trùng tên và đặt max age của 
cookie này là 0. Browser sẽ giải phóng cookie này ngay lập tức. Để báo với browser 
xóa cookie khi tắt browser, đặt max age thành ``Long.MinValue``:

::

  cookie.setMaxAge(Long.MinValue)

`Internet Explorer không hỗ trợ "max-age" <http://mrcoles.com/blog/cookies-max-age-vs-expires/>`_,
nhưng Netty có thể nhận diện và xuất ra "max-age" hoặc "expires" một cách chính xác. Don't worry!

Browser sẽ không gửi các cookie attribute ngược trở lại server. Browser 
sẽ `only send the cookie name-value pairs <http://en.wikipedia.org/wiki/HTTP_cookie#Cookie_attributes>`_.

Nếu bạn muốn ngăn chặn các người dùng khác giả mạo cookie, sử dụng 
``xitrum.util.SeriDeseri.toSecureUrlSafeBase64`` và ``xitrum.util.SeriDeseri.fromSecureUrlSafeBase64``.
Để biết thêm thông tin, xem :doc:`How to encrypt data </howto>`.

Sử dụng kí tự trong cookie
~~~~~~~~~~~~~~~~~~~~~~~~~~

Bạn không thế sử dụng 
`các ký tự động trong cookie <http://stackoverflow.com/questions/1969232/allowed-characters-in-cookies>`_.
Ví dụ, nếu bạn muốn sử dụng kí tự UTF-8, bạn cần phải encode, bằng cách sử 
dụng ``xitrum.utill.UrlSafeBase64`` hoặc ``xitrum.util.SeriDeseri``.

Viết cookie:

::

  import io.netty.util.CharsetUtil
  import xitrum.util.UrlSafeBase64

  val value   = """{"identity":"example@gmail.com","first_name":"Alexander"}"""
  val encoded = UrlSafeBase64.noPaddingEncode(value.getBytes(CharsetUtil.UTF_8))
  val cookie  = new DefaultCookie("profile", encoded)
  responseCookies.append(cookie)

Đọc cookie:

::

  requestCookies.get("profile").foreach { encoded =>
    UrlSafeBase64.autoPaddingDecode(encoded).foreach { bytes =>
      val value = new String(bytes, CharsetUtil.UTF_8)
      println("profile: " + value)
    }
  }

Session
-------

Xitrum tự động quản lý Session bao gồm lưu trữ, trả về dữ liệu, mã hóa, v.v.
Bạn không cần phải bận tâm đến Session.

Trong action, bạn có thể sử dụng action ``session``, một instance 
``scala.collection.mutable.Map[String, Any]``. Mọi thứ lưu trữ trong ``session`` 
phải serializable.

Ví dụ, để đánh dấu một người dùng đã đăng nhập, bạn có để đặt username của người 
dùng vào session:

::

  session("userId") = userId

Sau đó, nếu bạn muốn kiểm tra người dùng đã đăng nhập hay chưa, chỉ cần kiểm tra
đã có username trong session hay chưa:

::

  if (session.isDefinedAt("userId")) println("This user has logged in")

Lưu trữ user ID và lấy thông tin người dùng từ database mỗi lần truy cập thường 
được sử dụng hơn, Cách này bạn có thể biết được thông tin người dùng đã được cập 
nhất (bao gồm quyền và xác thực) ở mỗi lần truy cập.

session.clear()
~~~~~~~~~~~~~~~

`Với một dòng mã bạn có thể bảo vệ ứng xụng khỏi session fixation <http://guides.rubyonrails.org/security.html#session-fixation>`_.

Hãy đọc link trên đây để biết thêm về session fixation. Để ngăn chặn tấn công 
bằng session fixation, trong action cho phép người dùng đăng nhập, gọi method 
``session.clear()``.

::

  @GET("login")
  class LoginAction extends Action {
    def execute() {
      ...
      session.clear()  // Reset first before doing anything else with the session
      session("userId") = userId
    }
  }

Để thực hiện đăng xuất, cũng gọi method ``session.clear()``.

SessionVar
~~~~~~~~~~

SessionVar, giống như RequestVar, là một cách làm cho session typesafe hơn.

Lấy một ví dụ, bạn muốn lưu trữ username vào session sau khi thực hiện đăng 
nhập:

Khai báo session var:

::

  import xitrum.SessionVar

  object SVar {
    object username extends SessionVar[String]
  }

Sau khi đăng nhập thành công:

::

  SVar.username.set(username)

Hiển thị username:

::

  if (SVar.username.isDefined)
    <em>{SVar.username.get}</em>
  else
    <a href={url[LoginAction]}>Login</a>

* Để xóa session var: ``SVar.username.remove()``
* Để reset toàn bộ session: ``session.clear()``

Lưu trữ session
~~~~~~~~~~~~~~~

Xitrum cung cấp 3 cách lưu trữ session.
Trong tệp `config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_
bạn có thể chọn các lưu trữ bạn muốn:

CookieSessionStore:

::

  # Store sessions on client side
  store = xitrum.scope.session.CookieSessionStore

LruSessionStore:

::

  # Simple in-memory server side session store
  store {
    "xitrum.local.LruSessionStore" {
      maxElems = 10000
    }
  }

Nếu bạn chạy một cụm nhiều máy chr, bạn có thể 
`sử dụng Hazelcast để lưu trữ cluster-aware session <https://github.com/xitrum-framework/xitrum-hazelcast>`_,


Lưu ý rằng khi bạn sử dụng CookieSessionStore hoặc Hazelcast, dữ liệu trong session 
phải được serializable. Nếu bạn phải lưu trữ những thứ unserializable, sử dụng 
LruSessionStore. Nếu bạn sử dụng LruSessionStore và vẫn muốn chạy một cụm nhiều 
máy chủ, bạn phải sử dụng load balancer có hỗ trợ sticky sessions.

3 cách lưu trữ session trên đây đủ sử dụng trong các trường hợp thông thường.
Nếu bạn có một trường hợp đặc biệt và muốn sử dụng cách lưu trữ session riêng,
kế thừa
`SessionStore <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/scope/session/SessionStore.scala>`_
hoặc
`ServerSessionStore <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/scope/session/ServerSessionStore.scala>`_
và implement các abstract method.

Việc cấu hình có thể sử dụng một trong 2 cách:

::

  store = my.session.StoreClassName

Hoặc:

::

  store {
    "my.session.StoreClassName" {
      option1 = value1
      option2 = value2
    }
  }

Lưu trữ session ở cookie của client bất cứ khi nào có thể (serializable và
`nhỏ hơn 4KB dữ liệu <http://stackoverflow.com/questions/640938/what-is-the-maximum-size-of-a-web-browsers-cookies-key>`_),
 it's more scalable.
Lưu trữ session ở phía server (trong bộ nhớ hoặc Database) chỉ khi cần thiết.

Good read:
`Web Based Session Management - Best practices in managing HTTP-based client sessions <http://www.technicalinfo.net/papers/WebBasedSessionManagement.html>`_.

Lưu trữ Session ở Client hay Server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có 2 hình thức lưu trữ session:

* Chỉ ở phía client
* Kết hợp cả 2 : client và server

Với chỉ lưu trữ ở client:

* Dữ liệu trong session được lưu trữ trong cookie mã hóa ở phía client.
* Phía server không cần phải lưu trữ bất cứ thứ gì.
* Khi có một request truyền tới, server sẽ tiến hành giải mã dữ liệu.


Kết hợp cả 2 : client và server:

* Một session có 2 phần: session ID và session data.
* Server lưu trữ dữ liệu trong session, theo cặp ID -> data
* ID cũng được lưu trữ trong cookie đã được mã hóa ở client.
* Khi có một request truyền tới, server sẽ giải mã ID, và sử dụng ID để tìm data
* Các này giống như sử dụng thẻ tín dụng. Số tiền không lưu trong thẻ tín dụng mà
ở ID

Trong cả 2 cách, client phải lưu trữ một vài thứ như cookie (dữ liệu được mã hóa
và ID được mã hóa). "Lưu trữ session ở server" có nghĩa là lưu trữ dữ liệu của 
session ở phía server.

object vs. val
--------------

Sử dụng ``object`` thay vì ``val``.

**Không làm như sau**:

::

  object RVar {
    val title    = new RequestVar[String]
    val category = new RequestVar[String]
  }

  object SVar {
    val username = new SessionVar[String]
    val isAdmin  = new SessionVar[Boolean]
  }

Đoạn code trên là đúng cú pháp và sẽ được biên dịch nhưng không chạy, bởi vì các
Var bản thân chúng sử dụng class nameđể tìm kiếm. Khi sử dụng ``val``, ``title`` 
và ``category`` sẽ có chung class name "xitrum.RequestVar". Tương tự với ``username``
và ``isAdmin``.
