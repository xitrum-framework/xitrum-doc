XML
===

ScalaではXMLリテラルを記述することが可能です。Xitrumではこの機能をテンプレートエンジンとして利用しています。

* ScalaコンパイラによるXMLシンタックスチェックは、Viewの型安全につながります。
* ScalaによるXMLの自動的なエスケープは、`XSS <http://en.wikipedia.org/wiki/Cross-site_scripting>`_　攻撃を防ぎます。

いくつかのTipsを示します。

XMLのアンエスケープ
-------------------

``scala.xml.Unparsed`` を使用します。

::

  import scala.xml.Unparsed

  <script>
    {Unparsed("if (1 < 2) alert('Xitrum rocks');")}
  </script>

または ``<xml:unparsed>`` を使用します。

::

  <script>
    <xml:unparsed>
      if (1 < 2) alert('Xitrum rocks');
    </xml:unparsed>
  </script>

``<xml:unparsed>`` は出力されません。

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

``<xml:group>`` は出力されません。ユーザーがログイン状態の場合、出力は以下のようになります。

::

  <div id="header">
    <b>My username</b>
    <a href="/login">Logout</a>
  </div>


XHTMLの描画
-----------

XitrumはviewとレイアウトはXHTMLとして出力します。
レアケースではありますが、もしあなたが直接、出力を記述する場合以下のコードが示す内容に注意してください。

::

  import scala.xml.Xhtml

  val br = <br />
  br.toString            // => <br></br>, some browsers will render this as 2 <br />s
  Xhtml.toXhtml(<br />)  // => "<br />"
