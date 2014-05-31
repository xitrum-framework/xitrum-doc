XML
===

ScalaではXMLリテラルを記述することが可能です。Xitrumではこの機能をテンプレートエンジンとして利用しています。

* ScalaコンパイラによるXMLシンタックスチェックは、Viewの型安全につながります。
* ScalaによるXMLの自動的なエスケープは、`XSS <http://en.wikipedia.org/wiki/Cross-site_scripting>`_　攻撃を防ぎます。

いくつかのTipsを示します。

XMLのアンエスケープ
-------------------

``scala.xml.Unparsed`` を使用する場合:

::

  import scala.xml.Unparsed

  <script>
    {Unparsed("if (1 < 2) alert('Xitrum rocks');")}
  </script>

``<xml:unparsed>`` を使用する場合:

::

  <script>
    <xml:unparsed>
      if (1 < 2) alert('Xitrum rocks');
    </xml:unparsed>
  </script>

``<xml:unparsed>`` は実際の出力には含まれません:

::

  <script>
    if (1 < 2) alert('Xitrum rocks');
  </script>

XMLエレメントのグループ化
-------------------------

::

  <div id="header">
    {if (loggedIn)
      <xml:group>
        <b>{username}</b>
        <a href={url[LogoutAction]}>Logout</a>
      </xml:group>
    else
      <xml:group>
        <a href={url[LoginAction]}>Login</a>
        <a href={url[RegisterAction]}>Register</a>
      </xml:group>}
  </div>

``<xml:group>`` は実際の出力には含まれません。ユーザーがログイン状態の場合、以下のように出力されます:

::

  <div id="header">
    <b>My username</b>
    <a href="/login">Logout</a>
  </div>


XHTMLの描画
-----------

XitrumはviewとレイアウトはXHTMLとして出力します。
レアケースではありますが、もしあなたが直接、出力内容を定義する場合、以下のコードが示す内容に注意してください。

::

  import scala.xml.Xhtml

  val br = <br />
  br.toString            // => <br></br>, この場合ブラウザによってはbrタグが2つあると認識されることがあります。
  Xhtml.toXhtml(<br />)  // => "<br />"
