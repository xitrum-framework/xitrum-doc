스코프
=====

요청
----

매개변수
~~~~~~

두 가지의 요청 매개변수:

1. 텍스트
2. 파일 업로드(바이너리)

다음과 같은 타입의 ``scala.collection.mutable.Map[String, Seq[String]]`` 세 가지 매개변수:

1. ``queryParams``: URL내의 ? 다음에 오는 매개변수  예: ``http://example.com/blah?x=1&y=2``
2. ``bodyTextParams``: POST 요청의 body에 포함된 매개변수
3. ``pathParams``: URL 내에 포함된 매개변수  예: ``GET("articles/:id/:title")``

이 매개변수들은 위의 순서대로 ``textParams`` 에 병합됩니다.
（1번에서 3번의 순서대로 매개변수를 덮어씁니다）

``bodyFileParams`` 은 ``scala.collection.mutable.Map[String, Seq[`` `FileUpload <http://netty.io/4.0/api/io/netty/handler/codec/http/multipart/FileUpload.html>`_ ``]]`` 의 형태입니다.

매개변수 접근
~~~~~~~~~~~~~~~~~~~~~~~~

액션내에서 매개변수에 직접 접근하거나 접근자 함수를 사용할 수 있습니다.

``textParams`` 에 접근하는 경우:

* ``param("x")``: ``String`` 을 반환하며 x가 존재하지 않으면 예외를 던집니다.
* ``paramo("x")``: ``Option[String]`` 을 반환합니다.
* ``params("x")``: ``Seq[String]`` 을 반환하며 x가 존재하지 않으면 Seq.empty를 반환합니다.

파라미터를 다른 형태(Int, Long, Fload, Double)로 다음과 같이 ``param[Int]("x")`` 이나 ``params[Int]("x")`` 으로 자동으로 변환이 가능합니다.
이 밖에 다른 형태로 변환하고자 하면 `convertTextParam <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala-2.11/xitrum/scope/request/ParamAccess.scala>`_ 를 재정의하여 사용하면 됩니다.

파일 업로드의 경우에는 ``param[FileUpload]("x")`` 나 ``params[FileUpload]("x")`` 를 사용하면 됩니다.
자세한 내용은 :doc:`Upload chapter </upload>` 를 참고하세요.

"at"
~~~~

``at`` 을 사용하여 요청을 전달하는 동안 매개변수를 전달할 수 있습니다(액션이나, 뷰, 또는 레이아웃에서）.
``at`` 은 ``scala.collection.mutable.HashMap[String, Any]`` 타입입니다.
``at`` 은 Rails에서 ``@`` 과 같은 역할을 수행합니다.

Articles.scala:

::

  @GET("articles/:id")
  class ArticlesShow extends AppAction {
    def execute() {
      val (title, body) = ...  // Get from DB
      at("title") = title
      respondInlineView(body)
    }
  }

AppAction.scala:

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

``atJson`` 은 ``at("key")`` 을 자동으로 JSON으로 변환 시 사용되는 헬퍼입니다.
Scala에서 Javascript로 모델을 전달 시에 유용하게 사용됩니다.

``atJson("key")`` 은 ``xitrum.util.SeriDeseri.toJson(at("key"))`` 과 같습니다.

Action.scala:

::

  case class User(login: String, name: String)

  ...

  def execute() {
    at("user") = User("admin", "Admin")
    respondView()
  }

Action.ssp:

::

  <script type="text/javascript">
    var user = ${atJson("user")};
    alert(user.login);
    alert(user.name);
  </script>

RequestVar
~~~~~~~~~~

 ``at`` 은 어떠한 값도 map으로 저장이 가능해서 typesafe하지 않습니다.
안전하게 사용하려면 ``at`` 의 래퍼인 ``RequestVar`` 을 사용하면 됩니다.

RVar.scala:

::

  import xitrum.RequestVar

  object RVar {
    object title extends RequestVar[String]
  }

Articles.scala:

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

쿠키
----

위키피디아에 정의되어 있습니다. `cookies <http://en.wikipedia.org/wiki/HTTP_cookie>`_

액션 내에 ``requestCookies`` 를 사용하여 ``Map[String, String]`` 형식으로 브라우저에서 보낸 쿠키를 읽을 수 있습니다.

::

  requestCookies.get("myCookie") match {
    case None         => ...
    case Some(string) => ...
  }

브라우저에서 쿠키를 전송하려면 `DefaultCookie <http://netty.io/4.0/api/io/netty/handler/codec/http/DefaultCookie.html>`_ 인스턴스를 생성하고 `Cookie <http://netty.io/4.0/api/io/netty/handler/codec/http/Cookie.html>`_ 를 가지고 있는 ``ArrayBuffer`` 형식으로 ``responseCookies`` 에 추가합니다.

::

  val cookie = new DefaultCookie("name", "value")
  cookie.setHttpOnly(true)  // true: JavaScript cannot access this cookie
  responseCookies.append(cookie)

``cookie.setPath(cookiePath)`` 를 설정하지 않고 사용하면
루트 (``xitrum.Config.withBaseUrl("/")``)가 설정되고 원치 않는 중복을 막아줍니다.

브라우저에서 보낸 쿠키를 삭제하려면 같은 이름의 쿠키를 "max-age"를 0으로 설정하면 브라우저에서는 즉시 쿠키를 만료시킵니다.
브라우저가 종료될 때 쿠키를 삭제하려면 "max-age"를 ``Long.MinValue`` 으로 설정합니다:

::

  cookie.setMaxAge(Long.MinValue)

`Internet Explorer는 "max-age"를 지원하지 않습니다. <http://mrcoles.com/blog/cookies-max-age-vs-expires/>`_ .
그러나, Netty는 "max-age"와 "expires"를 동시에 찾아내기 때문에 걱정하지 않아도 됩니다.

브라우저는 쿠키의 속성을 서버로 전송하지 않습니다.
브라우저는 `name-value pairs <http://en.wikipedia.org/wiki/HTTP_cookie#Cookie_attributes>`_ 만을 보냅니다.

서명된 쿠키를 사용하여 쿠키의 변조를 방지하려면
``xitrum.util.SeriDeseri.toSecureUrlSafeBase64`` 와 ``xitrum.util.SeriDeseri.fromSecureUrlSafeBase64`` 을 사용하세요.
자세한 내용은 :doc:`How to encrypt data </howto>` 를 참고하세요

쿠키가 가능한 문자들
~~~~~~~~~~~~~~~

쿠키는 `arbitrary characters in cookie <http://stackoverflow.com/questions/1969232/allowed-characters-in-cookies>`_ 를 사용할 수 없습니다.
UTF-8 문자는 UTF-8로 인코딩해야 합니다.
인코딩시 ``xitrum.utill.UrlSafeBase64`` 또는 ``xitrum.util.SeriDeseri`` 가 사용가능합니다.

쓰기 예제:

::

  import io.netty.util.CharsetUtil
  import xitrum.util.UrlSafeBase64

  val value   = """{"identity":"example@gmail.com","first_name":"Alexander"}"""
  val encoded = UrlSafeBase64.noPaddingEncode(value.getBytes(CharsetUtil.UTF_8))
  val cookie  = new DefaultCookie("profile", encoded)
  responseCookies.append(cookie)

읽기 예제:

::

  requestCookies.get("profile").foreach { encoded =>
    UrlSafeBase64.autoPaddingDecode(encoded).foreach { bytes =>
      val value = new String(bytes, CharsetUtil.UTF_8)
      println("profile: " + value)
    }
  }

세션
----

세션의 저장, 복원, 암호화 등은 Xitrum에 의해 자동화 되므로 신경쓰지 않아도 됩니다.

액션내에서 ``session`` 은 ``scala.collection.mutable.Map[String, Any]`` 의 인스턴스이고 ``session`` 은 반드시 직렬화 가능해야 합니다.

로그인 시에 사용자 이름을 세션에 저장하는 예:

::

  session("userId") = userId

사용자의 로그인 여부를 판단하려면 세션에 사용자 이름 항목이 있는지 확인하면 됩니다.

::

  if (session.isDefinedAt("userId")) println("This user has logged in")

사용자의 ID를 저장하여 매번 접근할때마다 데이터베이스에서 사용자를 검색하는 것은 매우 바람직합니다.
사용자의 정보변경을 알 수 있기 때문입니다.(권한 및 인증을 포함하여)

session.clear()
~~~~~~~~~~~~~~~

`One line of code will protect you from session fixation <http://guides.rubyonrails.org/security.html#session-fixation>`_.

session fixation 은 위의 항목을 참고하세요. session fixation 공격을 방지하기 위해
사용자의 로그인 시 ``session.clear()`` 을 호출합니다.

::

  @GET("login")
  class LoginAction extends Action {
    def execute() {
      ...
      session.clear()  // Reset first before doing anything else with the session
      session("userId") = userId
    }
  }

로그아웃 시에도 ``session.clear()`` 을 호출합니다.

SessionVar
~~~~~~~~~~

``RequestVar`` 와 마찬가지로 SessionVar는 조금 더 안전한 방법을 제공합니다.
예를 들어, 사용자 로그인 후 사용자 이름을 세션에 저장할 수 있습니다.

SessionVar의 선언:

::

  import xitrum.SessionVar

  object SVar {
    object username extends SessionVar[String]
  }

로그인 성공 후:

::

  SVar.username.set(username)

사용자 이름 표시:

::

  if (SVar.username.isDefined)
    <em>{SVar.username.get}</em>
  else
    <a href={url[LoginAction]}>Login</a>

* SessionVar 삭제: ``SVar.username.remove()``
* 모든 세션 초기화: ``session.clear()``

세션 스토어
~~~~~~~~

Xitrum은 세 가지의 세션 스토어를 제공합니다.
`config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_
원하는 방향대로 세션을 수정할 수 있습니다.

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

클러스터 내에서 여러 서버를 사용하게 된다면 `Hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_ 를 클러스터 간 세션 공유 저장소로 사용할 수 있습니다.

CookieSessionStore이나 Hazelcast를 세션 저장용으로 사용한다면 세션에 사용되는 데이터는 직렬화가 가능해야 합니다.
만약 직렬화가 불가능한 데이터일 경우에는 LruSessionStore를 사용하세요.
LruSessionStore를 사용하여 여러 서버를 사용하게 된다면 "sticky sessions"이 가능한 로드 밸런서를 사용해야 합니다.

일반적으로 위에 언급된 기본 세션 저장소면 충분히 구현이 가능하지만 특별한 세션 저장소를 직접 구축하려면
`SessionStore <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/scope/session/SessionStore.scala>`_
또는
`ServerSessionStore <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/scope/session/ServerSessionStore.scala>`_
을 상속받아 구현하여야 합니다.

설정 방법은 다음의 두 가지 방식이 있습니다:

::

  store = my.session.StoreClassName

또는:

::

  store {
    "my.session.StoreClassName" {
      option1 = value1
      option2 = value2
    }
  }

세션은 클라이언트에 저장하는 것이 확장에 도움이 됩니다
(직렬화가 가능하고 `4KB 이하 <http://stackoverflow.com/questions/640938/what-is-the-maximum-size-of-a-web-browsers-cookies-key>`_).
서버 측(메모리 혹은 데이터베이스)에는 필요할 때에만 저장하세요.

참고:
`Web Based Session Management - Best practices in managing HTTP-based client sessions <http://www.technicalinfo.net/papers/WebBasedSessionManagement.html>`_.

클라이언트 세션 저장과 서버 세션 저장
~~~~~~~~~~~~~~~~~~~~~~~~~~

두 가지 종류의 세션 저장이 가능:

* 클라이언트에만 저장
* 클라이언트 + 서버 사용:

클라이언트만 사용:

* 세션 데이터는 암호화된 쿠키로 클라이언트에 저장됩니다.
* 서버는 어떠한 데이터도 저장할 필요가 없습니다.
* 요청이 발생하면 서버는 복호화해서 사용합니다.

클라이언트 + 서버 사용:

* 세션은 두 가지의 정보가 있습니다: 세션ID, 세션데이터.
* 서버는 lookup table에서 데이터를 찾는 것처럼 세션을 저장합니다.
* ID는 암호화 되어 클라이언트에 저장됩니다.
* 요청이 발생하면 서버는 아이디를 복호화하여 데이터를 찾게됩니다.
* 신용카드처럼 ID만 저장되고 금액은 저장되지 않는 것과 같습니다.

위 두 가지 경우에 있어서 클라이언트는 반드시 쿠키를 저장하고 있어야만 합니다
(암호화된 데이터 vs 암호화된 ID). "Store sessions at server side" 가 의미하는 것은 서버 측에서 데이터가 저장되는 것만을 의미합니다.

object vs. val
--------------

``val`` 대신에 ``object`` 를 사용하세요.

**아래와 같이 사용하지 마세요**:

::

  object RVar {
    val title    = new RequestVar[String]
    val category = new RequestVar[String]
  }

  object SVar {
    val username = new SessionVar[String]
    val isAdmin  = new SessionVar[Boolean]
  }

위의 코드는 컴파일은 되지만 실행되지 않습니다. 왜냐하면 "Vars"는 내부적으로 조회 시에 클래스 이름이 사용됩니다.
``title``, ``category``, ``val`` 을 사용하는 경우 "xitrum.RequestVar" 라는 클래스 이름으로 사용됩니다.
``username`` 과 ``isAdmin`` 도 마찬가지 입니다.
