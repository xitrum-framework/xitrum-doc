RESTful APIs
============

XitrumではiPhone、Androidなどのアプリケーション用のRESTful APIsを非常に簡単に記述することができます。

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("articles")
  class ArticlesIndex extends Action {
    def execute() {...}
  }

  @GET("articles/:id")
  class ArticlesShow extends Action {
    def execute() {...}
  }

POST、 PUT、 PATCH、 DELETEそしてOPTIONSと同様に
XitrumはHEADリクエストをボディが空のGETリクエストとして自動的に扱います。

通常のブラウザーのようにPUTとDELETEをサポートしていないHTTPクライアントにおいて、
PUTとDELETEを実現するには、リクエストボディに ``_method=put`` や、 ``_method=delete`` を含めることで
可能になります。

アプリケーションの起動時にXitrumはアプリケーションをスキャンし、ルーティングテーブルを作成し出力します。
以下の様なログからアプリケーションがどのようなAPIをサポートしているか知ることができます。

::

  [INFO] Routes:
  GET /articles     quickstart.action.ArticlesIndex
  GET /articles/:id quickstart.action.ArticlesShow

ルーティングはJAX-RSとRailsエンジンの思想に基づいて自動で収集されます。
全てのルートを１箇所に宣言する必要はありません。
この機能は分散ルーティングと捉えることができます。この機能のおかげでアプリケーションを他のアプリケーションに取り込むことが可能になります。
もしあなたがブログエンジンを作ったならそれをJARにして別のアプリケーションに取り込むだけですぐにブログ機能が使えるようになるでしょう。
ルーティングには更に2つの特徴があります。
ルートの作成（リバースルーティング）は型安全に実施され、
`Swagger Doc <http://swagger.wordnik.com/>`_ を使用したルーティングに関するドキュメント作成も可能となります。


ルートのキャッシング
--------------------

起動スピード改善のため、ルートは ``routes.cache`` ファイルにキャッシュされます。
開発時には ``target`` にあるクラスファイル内のルートはキャッシュされません。
もしルートを含む依存ライブラリを更新した場合、 ``routes.cache`` ファイルを削除してください。
また、このファイルはソースコードリポジトリにコミットしないよう気をつけましょう。

ルートの優先順位(first、last)
-----------------------------

以下の様なルートを作成した場合

::

  /articles/:id --> ArticlesShow
  /articles/new --> ArticlesNew

2番目のルートを優先させるには ``@First`` アノテーションを追加します。

::

  import xitrum.annotation.{GET, First}

  @GET("articles/:id")
  class ArticlesShow extends Action {
    def execute() {...}
  }

  @First  // This route has higher priority than "ArticlesShow" above
  @GET("articles/new")
  class ArticlesNew extends Action {
    def execute() {...}
  }

``Last`` も同じように使用できます。

Actionへの複数パスの関連付け
----------------------------
::

  @GET("image", "image/:format")
  class Image extends Action {
    def execute() {
      val format = paramo("format").getOrElse("png")
      // ...
    }
  }


ドットを含むルート
------------------

::

  @GET("articles/:id", "articles/:id.:format")
  class ArticlesShow extends Action {
    def execute() {
      val id     = param[Int]("id")
      val format = paramo("format").getOrElse("html")
      // ...
    }
  }

正規表現によるルーティング
--------------------------

ルーティングに正規表現を使用することも可能です。

::

  GET("articles/:id<[0-9]+>")

パスの残り部分の取得
----------------------

``/`` 文字が特別でパラメータ名に含まれられません。``/`` 文字を使いたい場合、以下のように書きます:

::

  GET("service/:id/proxy/:*")

以下のパスがマッチされます:

::

  /service/123/proxy/http://foo.com/bar

``:*`` を取得:

::

  val url = param("*")  // "http://foo.com/bar"となります

CSRF対策
--------

GET以外のリクエストに対して、Xitrumはデフォルトで `Cross-site request forgery <http://en.wikipedia.org/wiki/CSRF>`_ 対策を実施します。

``antiCsrfMeta`` Tagsをレイアウト内に記載した場合:

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

出力される ``<head>`` は以下のようになります:

::

  <!DOCTYPE html>
  <html>
    <head>
      ...
      <meta name="csrf-token" content="5402330e-9916-40d8-a3f4-16b271d583be" />
      ...
    </head>
    ...
  </html>

`xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_ をテンプレート内で使用した場合、
このトークンは ``X-CSRF-Token`` ヘッダーとしてGETを除く全てのjQueryによるAjaxリクエストに含まれます。
xitrum.jsは ``jsDefaults`` タグを使用することでロードされます。
もし ``jsDefaults`` を使用したくない場合、以下のようにテンプレートに記載することですることでxitrum.jsをロードすることができます。

::

  <script type="text/javascript" src={url[xitrum.js]}></script>

CSRF対策インプットとCSRF対策トークン
--------------------------------------

XitrumはCSRF対策トークンをリクエストヘッダーの ``X-CSRF-Token`` から取得します。
もしリクエストヘッダーが存在しない場合、Xitrumはリクエストボディの ``csrf-token`` から取得します。
（URLパラメータ内には含まれません。）

前述したメタタグとxitrum.jsを使用せずにformを作成する場合、``antiCsrfInput`` または
``antiCsrfToken`` を使用する必要があります。

::

  form(method="post" action={url[AdminAddGroup]})
    != antiCsrfInput

::

  form(method="post" action={url[AdminAddGroup]})
    input(type="hidden" name="csrf-token" value={antiCsrfToken})

CSRFチェックの省略
------------------

スマートフォン向けアプリケーションなどでCSRFチェックを省略したい場合、
``xitrum.SkipCsrfCheck`` を継承してActionを作成します。

::

  import xitrum.{Action, SkipCsrfCheck}
  import xitrum.annotation.POST

  trait Api extends Action with SkipCsrfCheck

  @POST("api/positions")
  class LogPositionAPI extends Api {
    def execute() {...}
  }

  @POST("api/todos")
  class CreateTodoAPI extends Api {
    def execute() {...}
  }

リクエストコンテンツの取得
--------------------------

通常リクエストコンテンツタイプが ``application/x-www-form-urlencoded`` 以外の場合、
以下のようにしてリクエストコンテンツを取得することができます。

文字列として取得:

::

  val body = requestContentString

文字列として取得し、JSONへのパース:

::

  val myMap = requestContentJson[Map[String, Int]]

より詳細にリクエストを扱う場合、 `request.getContent <http://netty.io/4.0/api/io/netty/handler/codec/http/FullHttpRequest.html>`_ を使用することで
`ByteBuf <http://netty.io/4.0/api/io/netty/buffer/ByteBuf.html>`_ としてリクエストを取得することができます。

SwaggerによるAPIドキュメンテーション
-----------------------------------

`Swagger <https://developers.helloreverb.com/swagger/>`_ を使用してAPIドキュメントを作成することができます。
``@Swagger`` アノテーションをドキュメント化したいActionに記述します。
Xitrumはアノテーション情報から `/xitrum/swagger.json <https://github.com/wordnik/swagger-core/wiki/API-Declaration>`_ を作成します。
このファイルを `Swagger UI <https://github.com/wordnik/swagger-ui>`_ で読み込むことでインタラクティブなAPIドキュメンテーションとなります。
XitrumはSwagger UI を内包しており、 ``/xitrum/swagger-ui`` というパスにルーティングします。
例: http://localhost:8000/xitrum/swagger-ui.

.. image:: ../img/swagger.png

`サンプル <https://github.com/xitrum-framework/xitrum-placeholder>`_ を見てみましょう。

::

  import xitrum.{Action, SkipCsrfCheck}
  import xitrum.annotation.{GET, Swagger}

  @Swagger(
    Swagger.Resource("image", "APIs to create images"),
    Swagger.Note("Dimensions should not be bigger than 2000 x 2000"),
    Swagger.OptStringQuery("text", "Text to render on the image, default: Placeholder"),
    Swagger.Produces("image/png"),
    Swagger.Response(200, "PNG image"),
    Swagger.Response(400, "Width or height is invalid or too big")
  )
  trait ImageApi extends Action with SkipCsrfCheck {
    lazy val text = paramo("text").getOrElse("Placeholder")
  }

  @GET("image/:width/:height")
  @Swagger(  // <-- Inherits other info from ImageApi
    Swagger.Nickname("rect"),
    Swagger.Summary("Generate rectangle image"),
    Swagger.IntPath("width"),
    Swagger.IntPath("height")
  )
  class RectImageApi extends Api {
    def execute {
      val width  = param[Int]("width")
      val height = param[Int]("height")
      // ...
    }
  }

  @GET("image/:width")
  @Swagger(  // <-- Inherits other info from ImageApi
    Swagger.Nickname("square"),
    Swagger.Summary("Generate square image"),
    Swagger.IntPath("width")
  )
  class SquareImageApi extends Api {
    def execute {
      val width  = param[Int]("width")
      // ...
    }
  }


``/xitrum/swagger`` にアクセスすると
`SwaggerのためのJSON <https://github.com/wordnik/swagger-spec/blob/master/versions/1.2.md>`_
が生成されます。

Swagger UIはこの情報をもとにインタラクティブなAPIドキュメンテーションを作成します。

ここででてきたSwagger.IntPath、Swagger.OptStringQuery以外にも、BytePath, IntQuery, OptStringFormなど
以下の形式でアノテーションを使用することができます。

* ``<Value type><Param type>`` (必須パラメータ)
* ``Opt<Value type><Param type>`` (オプションパラメータ)

Value type: Byte, Int, Int32, Int64, Long, Number, Float, Double, String, Boolean, Date, DateTime

Param type: Path, Query, Body, Header, Form


詳しくは `value type <https://github.com/wordnik/swagger-core/wiki/Datatypes>`_ 、
`param type <https://github.com/wordnik/swagger-core/wiki/Parameters>`_ を参照してください。
