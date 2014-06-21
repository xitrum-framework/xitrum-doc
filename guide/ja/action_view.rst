Action と view
===============

Xitrumは3種類のActionを提供しています。
通常のAction、FutureAction、そしてActorActionです。

Action
------

アプリケーションから外部に非同期処理を呼び出さない場合に使用します。

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("hello")
  class HelloAction extends Action {
    def execute() {
      respondText("Hello")
    }
  }

通常のActionではリクエストは直ちに処理されます。
しかし、同時接続数が高くなり過ぎないように注意する必要があります。
リクエスト -> レスポンスの処理中にプロセスをブロックする処理を含めてはいけません。

FutureAction
------------

xitrum.Actionを継承した場合、そのActionはNettyのIOスレッド上で実行されます。
これはActionが軽量でノンブロッキングな場合に有効です。（例：直ぐにreturnするような処理の場合）
そうでなければxitrum.FutureActionを継承することで簡単に別のスレッド（スレッドプール）上でActionを実行することができます。

::

  import xitrum.FutureAction

  @GET("hi")
  class MyAction extends FutureAction {
    def execute() {
      respondText("hi")
    }
  }

ActorAction
-----------

Actionの外側へ非同期呼び出しを行いたい場合に使用します。
Actionをactorとして定義したい場合、xitrum.Actionの代わりにxitrum.ActorActionを継承します。
ActorActionを使用することでシステムはより多くの同時接続を実現することができます。
ただしリクエストは直ちに処理されるわけではありません。ここでは非同期指向となります。

actorインスタンスはリクエストが発生時に生成されます。このactorインスタンスはコネクションが切断された時、
またはrespondText,respondView等を使用してレスポンスが返された時に停止されます。
チャンクレスポンスの場合すぐには停止されず、最後のチャンクが送信された時点で停止されます。

::

  import scala.concurrent.duration._

  import xitrum.ActorAction
  import xitrum.annotation.GET

  @GET("actor")
  class ActorDemo extends ActorAction with AppAction {
    // This is just a normal Akka actor

    def execute() {
      // See Akka doc about scheduler
      import context.dispatcher
      context.system.scheduler.scheduleOnce(3 seconds, self, System.currentTimeMillis)

      // See Akka doc about "become"
      context.become {
        case pastTime =>
          respondInlineView("It's " + pastTime + " Unix ms 3s ago.")
      }
    }
  }

クライアントへのレスポンス送信
--------------------------------

Actionからクライアントへレスポンスを返すには以下のメソッドを使用します

* ``respondView``: レイアウトファイルを使用または使用せずに、Viewテンプレートファイルを送信します
* ``respondInlineView``: レイアウトファイルを使用または使用せずに、インライン記述されたテンプレートを送信します
* ``respondText("hello")``: レイアウトファイルを使用せずに文字列を送信します
* ``respondHtml("<html>...</html>")``: contentTypeを"text/html"として文字列を送信します
* ``respondJson(List(1, 2, 3))``: ScalaオブジェクトをJSONに変換し、contentTypeを"application/json"として送信します
* ``respondJs("myFunction([1, 2, 3])")`` contentTypeを"application/javascript"として文字列を送信します
* ``respondJsonP(List(1, 2, 3), "myFunction")``: 上記2つの組み合わせをJSONPとして送信します
* ``respondJsonText("[1, 2, 3]")``: contentTypeを"application/javascript"として文字列として送信します
* ``respondJsonPText("[1, 2, 3]", "myFunction")``: `respondJs` 、 `respondJsonText` の2つの組み合わせをJSONPとして送信します
* ``respondBinary``: バイト配列を送信します
* ``respondFile``: ディスクからファイルを直接送信します。 `zero-copy <http://www.ibm.com/developerworks/library/j-zerocopy/>`_ を使用するため非常に高速です。
* ``respondEventSource("data", "event")``: チャンクレスポンスを送信します

テンプレートViewファイルのレスポンス
---------------------------------------------------------

全てのActionは `Scalate <http://scalate.fusesource.org/>`_ のテンプレートViewファイルと関連付ける事ができます。
上記のレスポンスメソッドを使用して直接レスポンスを送信する代わりに独立したViewファイルを使用することができます。

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

* ``xitrumCss`` XitrumのデフォルトCSSファイルです。削除しても問題ありません。
* ``jsDefaults`` jQuery, jQuery Validate plugin等を含みます。<head>内に記載する必要があります。
* ``jsForView`` ``jsAddToView`` によって追加されたjavascriptが出力されます。レイアウトの末尾に記載する必要があります。

テンプレートファイル内では `xitrum.Action <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/Action.scala>`_ クラスの全てのメソッドを使用することができます。
また、`unescape` のようなScalateのユーティリティも使用することができます。Scalateのユーティリティについては `Scalate doc <http://scalate.fusesource.org/documentation/index.html>`_　を参照してください。

Scalateテンプレートのデフォルトタイプは `Jade <http://scalate.fusesource.org/documentation/jade.html>`_ を使用しています。
ほかには `Mustache <http://scalate.fusesource.org/documentation/mustache.html>`_ 、
`Scaml <http://scalate.fusesource.org/documentation/scaml-reference.html>`_ 、
`Ssp <http://scalate.fusesource.org/documentation/ssp-reference.html>`_ を選択することもできます。
テンプレートのデフォルトタイプを指定は、アプリケーションのconfigディレクトリ内の`xitrum.conf`で設定することができます。

`respondView` メソッドにtypeパラメータとして"jade"、 "mustache"、"scamal"、"ssp"のいずれか指定することでデフォルトテンプレートタイプをオーバーライドすることも可能です。

::

  respondView(Map("type" ->"mustache"))

currentActionのキャスト
~~~~~~~~~~~~~~~~~~~~~~~

現在のActionのインスタンスを正確に指定したい場合、``currentAction`` を指定したActionにキャストします。

::

  p= currentAction.asInstanceOf[MyAction].hello("World")

複数行で使用する場合、キャスト処理は1度だけ呼び出します。

::

  - val myAction = currentAction.asInstanceOf[MyAction]; import myAction._

  p= hello("World")
  p= hello("Scala")
  p= hello("Xitrum")

Mustache
~~~~~~~~

Mustacheについての参考資料:

* `Mustache syntax <http://mustache.github.com/mustache.5.html>`_
* `Scalate implementation <http://scalate.fusesource.org/documentation/mustache.html>`_

Mustachのシンタックスは堅牢なため、Jadeで可能な処理の一部は使用できません。

Actionから何か値を渡す場合、``at`` メソッドを使用します。

Action:

::

  at("name") = "Jack"
  at("xitrumCss") = xitrumCss

Mustache template:

::

  My name is {{name}}
  {{xitrumCss}}

注意:以下のキーは予約語のため、 ``at`` メソッドでScalateテンプレートに渡すことはできません。

* "context": ``unescape`` 等のメソッドを含むScalateのユーティリティオブジェクト
* "helper": 現在のActionオブジェクト

CoffeeScript
~~~~~~~~~~~~

`:coffeescript filter <http://scalate.fusesource.org/documentation/jade-syntax.html#filters>`_ を使用して
CoffeeScriptをテンプレート内に展開することができます。

::

  body
    :coffeescript
      alert "Hello, Coffee!"

出力結果:

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

注意: ただしこの処理は `低速 <http://groups.google.com/group/xitrum-framework/browse_thread/thread/6667a7608f0dc9c7>`_ です。

::

  jade+javascript+1thread: 1-2ms for page
  jade+coffesscript+1thread: 40-70ms for page
  jade+javascript+100threads: ~40ms for page
  jade+coffesscript+100threads: 400-700ms for page

高速で動作させるにはあらかじめCoffeeScriptからJavaScriptを生成しておく必要があります。

レイアウト
----------

``respondView`` または ``respondInlineView`` を使用してViewを送信した場合、
Xitrumはその結果の文字列を、``renderedView`` の変数としてセットします。
そして現在のActionの ``layout`` メソッドが実行されます。
ブラウザーに送信されるデータは最終的にこのメソッドの結果となります。

デフォルトでは、``layout`` メソッドは単に ``renderedView`` を呼び出します。
もし、この処理に追加で何かを加えたい場合、オーバーライドします。もし、 ``renderedView`` をメソッド内にインクルードした場合、
そのViewはレイアウトの一部としてインクルードされます。

ポイントは ``layout`` は現在のActionのViewが実行された後に呼ばれるということです。
そしてそこで返却される値がブラウザーに送信される値となります。

このメカニズムはとてもシンプルで魔法ではありません。便宜上Xitrumにはレイアウトが存在しないと考えることができます。
そこにはただ ``layout`` メソッドがあるだけで、全てをこのメソッドで賄うことができます。


典型的な例として、共通レイアウトを親クラスとして使用するパターンを示します。

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


独立したレイアウトファイルを使用しないパターン
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

respondViewにレイアウトを直接指定するパターン
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

respondInlineView
-----------------

通常ViewはScalateファイルに記載しますが、直接Actionに記載することもできます。

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

renderFragment
--------------

フラグメントを返す場合

scr/main/scalate/mypackage/MyAction/_myfragment.jade:

::

  renderFragment[MyAction]("myfragment")

現在のActionがMyActionの場合、キャストは省略できます。

::

  renderFragment("myfragment")

別のアクションに紐付けられたViewをレスポンスする場合
--------------------------------------------------------------------------------

次のシンタックスを使用します ``respondView[ClassName]()``:

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

ひとつのアクションに複数のViweを紐付ける方法
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

上記のようにルーティングとは関係ないアクションを記述することは一見して面倒ですが、
この方法はプログラムをタイプセーフに保つことができます。

Component
---------

複数のViewに対して組み込むことができる再利用可能なコンポーネントを作成することもできます。
コンポーネントのコンセプトはアクションに非常に似ています。
以下のような特徴があります。

* コンポーネントはルートを持ちません。すなわち ``execute`` メソッドは不要となります。
* コンポーネントは全レスポンスを返すわけではありません。 断片的なviewを "render" するのみとなります。
  そのため、コンポーネント内部では ``respondXXX`` の代わりに ``renderXXX`` を呼び出す必要があります。
* アクションのように、コンポーネントは単一のまたは複数のViewと紐付けるたり、あるいは紐付けないで使用することも可能です。


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
