HOWTO
=====

この章ではいくつかの小さなtipsを紹介します。

アクションへのリンク
--------------------

Xitrumは型安全指向です。URLは直截記載せずにいかのように参照します:

::

  <a href={url[ArticlesShow]("id" -> myArticle.id)}>{myArticle.title}</a>

他のアクションへのリダイレクト
------------------------------

``redirectTo[AnotherAction]()`` を使用します。
リダイレクトについては `こちら（英語） <http://en.wikipedia.org/wiki/URL_redirection>`_ を参照してください。

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

また、``redirecToThis()`` を使用して現在のアクションへリダイレクトさせることも可能です。

他のアクションへのフォワード
----------------------------

``forwardTo[AnotherAction]()`` を使用します。前述の ``redirectTo`` ではブラウザは別のリクエストを送信しますが、
``forwardTo`` ではリクエストは引き継がれます。

Ajaxリクエストの判定
--------------------

``isAjax`` を使用します。

::

  // In an action
  val msg = "A message"
  if (isAjax)
    jsRender("alert(" + jsEscape(msg) + ")")
  else
    respondText(msg)


ルーティングの操作
------------------

Xitrumは起動時に自動でルーティングを収集します。
収集されたルーティングにアクセスするには、`xitrum.Config.routes <http://xitrum-framework.github.io/api/3.17/index.html#xitrum.routing.RouteCollection>`_ を使用します。

例:

::

  import xitrum.{Config, Server}

  object Boot {
    def main(args: Array[String]) {
      // サーバーをスタートさせる前にルーティングを操作します。
      val routes = Config.routes

      // クラスを指定してルートを削除する場合
      routes.removeByClass[MyClass]()

      if (demoVersion) {
        // prefixを指定してルートを削除する場合
        routes.removeByPrefix("premium/features")

        // '/'が先頭にある場合も同じ効果が得られます
        routes.removeByPrefix("/premium/features")
      }

      ...

      Server.start()
    }
  }

ベーシック認証
--------------

サイト全体や特定のアクションに `ベーシック認証 <http://ja.wikipedia.org/wiki/Basic%E8%AA%8D%E8%A8%BC>`_ を適用することができます。

`ダイジェスト認証 <http://ja.wikipedia.org/wiki/Digest%E8%AA%8D%E8%A8%BC>`_ についてはman-in-the-middle攻撃に対して脆弱であることから、
Xitrumではサポートしていません。

よりセキュアなアプリケーションとするには、HTTPSを使用することを推奨します。（XitrumはApacheやNginxをリバースプロキシとして使用することなく、単独でHTTPSサーバを構築する事ができます。）

サイト全体のベーシック認証設定
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``config/xitrum.conf`` に以下を記載:

::

  "basicAuth": {
    "realm":    "xitrum",
    "username": "xitrum",
    "password": "xitrum"
  }

特定のアクションのベーシック認証設定
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  import xitrum.Action

  class MyAction extends Action {
    beforeFilter {
      basicAuth("Realm") { (username, password) =>
        username == "username" && password == "password"
      }
    }
  }

ログ
----

xitrum.Logオブジェクトを直接使用する
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

xitrum.Logはどこからでも直接使用することができます:

::

  xitrum.Log.debug("My debug msg")
  xitrum.Log.info("My info msg")
  ...

xitrum.Logトレイトを直接使用する
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ログが生成された場所(クラス)を明確に知りたい場合、
xitrum.Logトレイトを継承します。

::

  package my_package

  object MyModel extends xitrum.Log {
    xitrum.Log.debug("My debug msg")
    xitrum.Log.info("My info msg")
    ...
  }

``log/xitrum.log`` にはメッセージが ``MyModel`` から出力されていることがわかります。

Xitrumのアクションはxitrum.Logトレイトを継承し、 ``log`` メソッドを提供しています。
つまり、どのactionからでも以下のようにログを出力することができます:

::

  log.debug("Hello World")

ログレベルをチェックする必要はありません
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``xitrum.Log`` は `SLF4S <http://slf4s.org/>`_ (`API <http://slf4s.org/api/1.7.7/>`_) を使用しており、
SLF4Sは `SLF4J <http://www.slf4j.org/>`_ の上に構築されています。

ログに出力時の計算によるCPU負荷を減らす目的で、ログ出力前にログレベルをチェックする伝統的な手法がありますが、
`SLF4Sが自動でチェックしてくれる <https://github.com/mattroberts297/slf4s/blob/master/src/main/scala/org/slf4s/Logger.scala>`_ ため、
あなたが気にする必要はありません。


これまで (このコードは Xitrum 3.13 以降では動作しません):

::

  if (log.isTraceEnabled) {
    val result = heavyCalculation()
    log.trace("Output: {}", result)
  }

現行:

::

  log.trace(s"Output: #{heavyCalculation()}")

ログレベル、ログファイル等の設定
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

build.sbtに以下の1行があります:

::

  libraryDependencies += "ch.qos.logback" % "logback-classic" % "1.1.2"

これはデフォルトで `Logback <http://logback.qos.ch/>`_ が使用されていることを意味します。
Logbackの設定ファイルは ``config/logback.xml`` になります。

Logback以外の `SLF4J <http://www.slf4j.org/>`_ 対応ライブラリに置き換えることも可能です。

設定ファイルのロード
--------------------

JSONファイル
~~~~~~~~~~~~

JSONはネストした設定を記載するのに適した構造をしています。

``config`` ディレクトリに設定ファイルを保存します。
このディレクトリは、デベロップメントモードではbuild.sbtによって、プロダクションモードでは、``script/runner`` (または ``script/runner.bat`` ) によって
自動的にクラスパスに含められます。

myconfig.json:

::

  {
    "username": "God",
    "password": "Does God need a password?",
    "children": ["Adam", "Eva"]
  }

ロード方法:

::

  import xitrum.util.Loader

  case class MyConfig(username: String, password: String, children: List[String])
  val myConfig = Loader.jsonFromClasspath[MyConfig]("myconfig.json")

備考:

* キーと文字列はダブルコーテーションで囲まれている必要があります。
* 現時点でJSONファイルにコメントを記載することはできません。

プロパティファイル
~~~~~~~~~~~~~~~~~~

プロパティファイルを使用することもできます。
プロパティファイルは型安全ではないこと、UTF-8をサポートしてないこと、ネスト構造をサポートしていないことから、
JSONファイルを使用することができるのであれば、JSONを使用することをお勧めします。

myconfig.properties:

::

  username = God
  password = Does God need a password?
  children = Adam, Eva

ロード方法:

::

  import xitrum.util.Loader

  // Here you get an instance of java.util.Properties
  val properties = Loader.propertiesFromClasspath("myconfig.properties")

型安全な設定ファイル
~~~~~~~~~~~~~~~~~~~~

XitrumはAkkaを内包しています。Akkaには `Typesafe社 <http://typesafe.com/company>`_ 製の `config <https://github.com/typesafehub/config>`_ というライブラリをが含まれており、設定ファイルロードについて、よりベターやり方を提供してくれます。

myconfig.conf:

::

  username = God
  password = Does God need a password?
  children = ["Adam", "Eva"]

ロード方法:

::

  import com.typesafe.config.{Config, ConfigFactory}

  val config   = ConfigFactory.load("myconfig.conf")
  val username = config.getString("username")
  val password = config.getString("password")
  val children = config.getStringList("children")

シリアライズとデシリアライズ
----------------------------

``xitrum.util.SeriDeseri`` を使用します。

``Array[Byte]`` へのシリアライズ:

::

  val bytes = SeriDeseri.toBytes("my serializable object")

バイト配列からのデシリアライズ:

::

  val option = SeriDeseri.fromBytes[MyType](bytes)  // Option[MyType]

データの暗号化
--------------

復号化する必要がないデータの暗号化にはMD5等を使用することができます。
復号化する必要があるデータを暗号化する場合、``xitrum.util.Secure`` を使用します。

::

  import xitrum.util.Secure

  // Array[Byte]
  val encrypted = Secure.encrypt("my data".getBytes)

  // Option[Array[Byte]]
  val decrypted = Secure.decrypt(encrypted)

レスポンスするHTMLに埋め込むなど、バイナリデータを文字列にエンコード/デコードする場合、
``xitrum.util.UrlSafeBase64`` を使用します。

::

  // cookieなどのURLに含まれるデータをエンコード
  val string = UrlSafeBase64.noPaddingEncode(encrypted)

  // Option[Array[Byte]]
  val encrypted2 = UrlSafeBase64.autoPaddingDecode(string)

上記の操作の組み合わせを1度に行う場合:

::

  import xitrum.util.SeriDeseri

  val mySerializableObject = new MySerializableClass

  // String
  val encrypted = SeriDeseri.toSecureUrlSafeBase64(mySerializableObject)

  // Option[MySerializableClass]
  val decrypted = SeriDeseri.fromSecureUrlSafeBase64[MySerializableClass](encrypted)

``SeriDeseri`` はシリアライズとデシリアライズに `Twitter Chill <https://github.com/twitter/chill>`_ を使用しています。
シリアライズ対象のデータはシリアライズ可能なものである必要があります。

暗号化キーの指定方法:

::

  val encrypted = Secure.encrypt("my data".getBytes, "my key")
  val decrypted = Secure.decrypt(encrypted, "my key")

::

  val encrypted = SeriDeseri.toSecureUrlSafeBase64(mySerializableObject, "my key")
  val decrypted = SeriDeseri.fromSecureUrlSafeBase64[MySerializableClass](encrypted, "my key")

キーが指定されない場合、``config/xitrum.conf`` に記載された ``secureKey`` が使用されます。

同一ドメイン配下における複数サイトの構成
----------------------------------------

同一ドメイン配下に、Nginx等のリバースプロキシを動かして、以下の様な複数のサイトを構成する場合、

::

  http://example.com/site1/...
  http://example.com/site2/...

``config/xitrum.conf`` にて、 ``baseUrl`` を設定することができます。

JavaScriptからAjaxリクエスを行う正しいURLを取得するには、`xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_ の、``withBaseUrl`` メソッドを使用します。

::

  # 現在のサイトのbaseUrlが "site1" の場合、
  # 結果は /site1/path/to/my/action になります。
  xitrum.withBaseUrl('/path/to/my/action')

MarkdownからHTMLへの変換
------------------------

テンプレートエンジンとして、:doc:`Scalate </template_engines>` を使用するプロジェクトの場合:

::

  import org.fusesource.scalamd.Markdown
  val html = Markdown("input")


Scalateを使用しない場合、
build.sbtに以下の依存ライブラリを追記する必要があります:

::

  libraryDependencies += "org.fusesource.scalamd" %% "scalamd" % "1.6"

ファイル監視
------------

ファイルやディレクトリの `StandardWatchEventKinds <http://docs.oracle.com/javase/7/docs/api/java/nio/file/StandardWatchEventKinds.html>`_ に対してコールバックを設定することができます。

::

  import java.nio.file.Paths
  import xitrum.util.FileMonitor

  val target = Paths.get("absolute_path_or_path_relative_to_application_directory").toAbsolutePath
  FileMonitor.monitor(FileMonitor.MODIFY, target, { path =>
    // コールバックでは path を使用することができます
    println(s"File modified: $path")

    // 監視が不要な場合
    FileMonitor.unmonitor(FileMonitor.MODIFY, target)
  })

``FileMonitor`` は `Schwatcher <https://github.com/lloydmeta/schwatcher>`_ を使用しています。

一時ディレクトリ
------------------

デフォルト( ``xitrum.conf`` の ``tmpDir`` の設定内容)では、カレントディレクトリ内の ``tmp`` というディレクトリが
一時ディレクトリとして、Scalateによってい生成された .scalaファイルや、大きなファイルのアップロードなどに使用されます。

プログラムから一時ディレクトリを使用する場合:

::

  xitrum.Config.xitrum.tmpDir.getAbsolutePath

新規ファイルやディレクトリを一時ディレクトリに作成する場合:

::

  val file = new java.io.File(xitrum.Config.xitrum.tmpDir, "myfile")

  val dir = new java.io.File(xitrum.Config.xitrum.tmpDir, "mydir")
  dir.mkdirs()
