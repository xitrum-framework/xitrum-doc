スコープ
========

リクエストスコープ
------------------

リクエストパラメーター
~~~~~~~~~~~~~~~~~~~~~~

リクエストパラメーターには2種類あります:

1. テキストパラメータ
2. ファイルアップロードパラメーター（バイナリー）

テキストパラメーターは ``scala.collection.mutable.Map[String, Seq[String]]`` の型をとる3種類があります:

1. ``queryParams``: URL内の?以降で指定されたパラメーター  例: ``http://example.com/blah?x=1&y=2``
2. ``bodyTextParams``: POSTリクエストのbodyで指定されたパラメーター
3. ``pathParams``: URL内に含まれるパラメーター  例: ``GET("articles/:id/:title")``

これらのパラメーターは上記の順番で、 ``textParams`` としてマージされます。
（後からマージされるパラメーターは上書きとなります。）

``bodyFileParams`` は ``scala.collection.mutable.Map[String, Seq[`` `FileUpload <http://netty.io/4.0/api/io/netty/handler/codec/http/multipart/FileUpload.html>`_ ``]]`` の型をとります。

パラメーターへのアクセス
~~~~~~~~~~~~~~~~~~~~~~~~

アクションからは直接、またはアクセサメソッドを使用して上記のパラメーターを取得することができます。

``textParams`` にアクセスする場合:

* ``param("x")``: ``String`` を返却します。xが存在しないエクセプションがスローされます。
* ``paramo("x")``: ``Option[String]`` を返却します。
* ``params("x")``: ``Seq[String]`` を返却します。 xが存在しない場合``Seq.empty``を返却します。

``param[Int]("x")`` や ``params[Int]("x")`` と型を指定することでテキストパラメーターを別の型として取得することができます。
テキストパラメーターを独自の型に変換する場合、 `convertTextParam <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala-2.11/xitrum/scope/request/ParamAccess.scala>`_ をオーバーライドすることで可能となります。

ファイルアップロードに対しては、``param[FileUpload]("x")`` や ``params[FileUpload]("x")`` でアクセスすることができます。
詳しくは :doc:`ファイルアップロードの章 </upload>` を参照してください。

"at"
~~~~

リクエストの処理中にパラメーターを受け渡し(例えばアクションからViewやレイアウトファイルへ）を行う場合、
``at`` を使用することで実現できます。 ``at`` は ``scala.collection.mutable.HashMap[String, Any]`` の型となります。
``at`` はRailsにおける ``@`` と同じ役割を果たします。

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

``atJson`` は ``at("key")`` を自動的にJSONに変換するヘルパーメソッドです。
ScalaからJavascriptへのモデルの受け渡しに役立ちます。

``atJson("key")`` は ``xitrum.util.SeriDeseri.toJson(at("key"))`` と同等です。

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

前述の ``at`` はどのような値もmapとして保存できるため型安全ではありません。
より型安全な実装を行うには、 ``at`` のラッパーである ``RequestVar`` を使用します。

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

クッキー
--------

クッキーの仕組みについては `Wikipedia <http://en.wikipedia.org/wiki/HTTP_cookie>`_ を参照してください。

アクション内では ``requestCookies`` を使用することで、ブラウザから送信されたクッキーを ``Map[String, String]`` として取得できます。

::

  requestCookies.get("myCookie") match {
    case None         => ...
    case Some(string) => ...
  }

ブラウザにクッキーを送信するには、`DefaultCookie <http://netty.io/4.0/api/io/netty/handler/codec/http/DefaultCookie.html>`_ インスタンスを生成し、`Cookie <http://netty.io/4.0/api/io/netty/handler/codec/http/Cookie.html>`_ を含む ``ArrayBuffer`` である、 ``responseCookies`` にアペンドします。

::

  val cookie = new DefaultCookie("name", "value")
  cookie.setHttpOnly(true)  // true: JavaScript cannot access this cookie
  responseCookies.append(cookie)

``cookie.setPath(cookiePath)`` でパスをセットせずにクッキーを使用した場合、
クッキーのパスはサイトルート(``xitrum.Config.withBaseUrl("/")``)が設定されます。

ブラウザから送信されたクッキーを削除するには、"max-age"を0にセットした同じ名前のクッキーをサーバーから送信することで、
ブラウザは直ちにクッキーを消去します。

ブラウザがウィンドウを閉じた際にクッキーが消去されるようにするには、"max-age"に ``Long.MinValue`` をセットします:

::

  cookie.setMaxAge(Long.MinValue)

`Internet Explorer は "max-age" をサポートしていません <http://mrcoles.com/blog/cookies-max-age-vs-expires/>`_ 。
しかし、Nettyが適切に判断して "max-age" または "expires" を設定してくれるので心配する必要はありません！

ブラウザはクッキーの属性をサーバーに送信することはありません。
ブラウザは `name-value pairs <http://en.wikipedia.org/wiki/HTTP_cookie#Cookie_attributes>`_ のみを送信します。

署名付きクッキーを使用して、クッキーの改ざんを防ぐには、
``xitrum.util.SeriDeseri.toSecureUrlSafeBase64`` と ``xitrum.util.SeriDeseri.fromSecureUrlSafeBase64`` を使用します。
詳しくは :doc:`データの暗号化 </howto>` を参照してください。

クッキーに使用可能な文字
~~~~~~~~~~~~~~~~~~~~~~~~

クッキーには `任意の文字 <http://stackoverflow.com/questions/1969232/allowed-characters-in-cookies>`_ を使用することができます。
例えば、UTF-8の文字として使用する場合、UTF-8にエンコードする必要があります。
エンコーディング処理には ``xitrum.utill.UrlSafeBase64`` または ``xitrum.util.SeriDeseri`` を使用することができます。

クッキー書き込みの例:

::

  import io.netty.util.CharsetUtil
  import xitrum.util.UrlSafeBase64

  val value   = """{"identity":"example@gmail.com","first_name":"Alexander"}"""
  val encoded = UrlSafeBase64.noPaddingEncode(value.getBytes(CharsetUtil.UTF_8))
  val cookie  = new DefaultCookie("profile", encoded)
  responseCookies.append(cookie)

クッキー読み込みの例:

::

  requestCookies.get("profile").foreach { encoded =>
    UrlSafeBase64.autoPaddingDecode(encoded).foreach { bytes =>
      val value = new String(bytes, CharsetUtil.UTF_8)
      println("profile: " + value)
    }
  }

セッション
----------

セッションの保存、破棄、暗号化などはXitrumが自動的に行いますので、頭を悩ます必要はありません。

アクション内で、 ``session`` を使用することができます。 セッションは ``scala.collection.mutable.Map[String, Any]`` のインスタンスです。 ``session`` に保存されるものはシリアライズ可能である必要があります。

ログインユーザーに対してユーザー名をセッションに保存する例:

::

  session("userId") = userId

ユーザーがログインしているかどうかを判定するには、
セッションにユーザーネームが保存されているかをチェックするだけですみます:

::

  if (session.isDefinedAt("userId")) println("This user has logged in")

ユーザーIDをセッションに保存し、アクセス毎にデータベースからユーザー情報を取得するやり方は多くの場合推奨されます。
アクセス毎にユーザーが更新(権限や認証を含む)されているかを知ることができます。

session.clear()
~~~~~~~~~~~~~~~

1行のコードで `session fixation <http://guides.rubyonrails.org/security.html#session-fixation>`_ の脅威からアプリケーションを守ることができます。

session fixation については上記のリンクを参照してください。session fixation攻撃を防ぐには、
ユーザーログインを行うアクションにて、 ``session.clear()`` を呼び出します。

::

  @GET("login")
  class LoginAction extends Action {
    def execute() {
      ...
      session.clear()  // Reset first before doing anything else with the session
      session("userId") = userId
    }
  }

ログアウト処理においても同様に ``session.clear()`` を呼び出しましょう。

SessionVar
~~~~~~~~~~

``RequestVar`` と同じく、より型安全な実装を提供します。
例では、ログイン後にユーザー名をセッションに保存します。

SessionVarの定義:

::

  import xitrum.SessionVar

  object SVar {
    object username extends SessionVar[String]
  }

ログイン処理成功後:

::

  SVar.username.set(username)

ユーザー名の表示:

::

  if (SVar.username.isDefined)
    <em>{SVar.username.get}</em>
  else
    <a href={url[LoginAction]}>Login</a>

* SessionVarの削除方法: ``SVar.username.remove()``
* セッション全体のクリア方法: ``session.clear()``

セッションストア
~~~~~~~~~~~~~~~~

Xitrumはセッションストアを3種類提供しています。
`config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_ において、セッションストアを設定することができます。

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

クラスター環境で複数のサーバーを起動する場合、`Hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_ をクラスタ間で共有するセッションストアとして使用することができます。

CookieSessionStore やHazelcastを使用する場合、セッションに保存するデータはシリアライズ可能である必要があります。
シリアライズできないデータを保存しなければいけない場合、 LruSessionStore を使用してください。
LruSessionStore を使用して、クラスタ環境で複数のサーバーを起動する場合、
スティッキーセッションをサポートしたロードバランサーを使用する必要があります。

一般的に、上記のデフォルトセッションストアのいずれかで事足りることですが、
もし特殊なセッションストアを独自に実装する場合
`SessionStore <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/scope/session/SessionStore.scala>`_
または
`ServerSessionStore <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/scope/session/ServerSessionStore.scala>`_
を継承し、抽象メソッドを実装してください。

設定ファイルには、使用するセッションストアに応じて以下のように設定できます。

::

  store = my.session.StoreClassName

または:

::

  store {
    "my.session.StoreClassName" {
      option1 = value1
      option2 = value2
    }
  }

スケーラブルにする場合、できるだけセッションはクライアントサイドのクッキーに保存しましょう
（リアライズ可能かつ`4KB以下 <http://stackoverflow.com/questions/640938/what-is-the-maximum-size-of-a-web-browsers-cookies-key>`_）。
サーバーサイド（メモリ上やDB）には必要なときだけセッションを保存しましょう。

参考（英語）:
`Web Based Session Management - Best practices in managing HTTP-based client sessions <http://www.technicalinfo.net/papers/WebBasedSessionManagement.html>`_.

object vs. val
--------------

``val`` の代わりに ``object`` を使用してください。

**以下のような実装は推奨されません**:

::

  object RVar {
    val title    = new RequestVar[String]
    val category = new RequestVar[String]
  }

  object SVar {
    val username = new SessionVar[String]
    val isAdmin  = new SessionVar[Boolean]
  }

上記のコードはコンパイルには成功しますが、正しく動作しません。
なぜなら valは内部ではルックアップ時にクラス名が使用されます。
``title`` と ``category`` が ``val`` を使用して宣言された場合、いずれもクラス名は "xitrum.RequestVar" となります。
同じことは ``username`` と ``isAdmin`` にも当てはまります。
