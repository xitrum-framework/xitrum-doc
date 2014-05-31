JavaScript と JSON
===================

JavaScript
----------

XitrumはjQueryを内包しています。

またいくつかのjsXXXヘルパー関数を提供しています。

JavaScriptフラグメントをViewに追加する方法
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

アクション内では ``jsAddToView`` を呼び出します。（必要であれば何度でも呼び出すことができます）:

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

レイアウト内では ``jsForView`` を呼び出します:

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

JavaScriptを直接レスポンスする方法
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Javascriptをレスポンスする場合:

::

  jsRespond("$('#error').html(%s)".format(jsEscape(<p class="error">Could not login.</p>)))

Javascriptでリダイレクトさせる場合:

::

  jsRedirectTo("http://cntt.tv/")
  jsRedirectTo[LoginAction]()

JSON
----

Xitrumは `JSON4S <https://github.com/json4s/json4s>`_ を内包しています。
JSONのパースと生成についてはJSON4Sを一読することを推奨します。

ScalaのcaseオブジェクトをJSON文字列に変換する場合:

::

  import xitrum.util.SeriDeseri

  case class Person(name: String, age: Int, phone: Option[String])
  val person1 = Person("Jack", 20, None)
  val json    = SeriDeseri.toJson(person)
  val person2 = SeriDeseri.fromJson(json)

JSONをレスポンスする場合:

::

  val scalaData = List(1, 2, 3)  // An example
  respondJson(scalaData)

JSONはネストした構造が必要な設定ファイルを作成する場合に適しています。

参照 :doc:`設定ファイルの読み込み </howto>`

Knockout.jsプラグイン
---------------------

参照 `xitrum-ko <https://github.com/xitrum-framework/xitrum-ko>`_
