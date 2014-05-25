静的ファイル
============

ディスク上の静的ファイルの配信
------------------------------

プロジェクトディレクトリーレイアウト:

::

  config
  public
    favicon.ico
    robots.txt
    404.html
    500.html
    img
      myimage.png
    css
      mystyle.css
    js
      myscript.js
  src
  build.sbt

``public`` ディレクトリ内に配置された静的ファイルはXitrumにより自動的に配信されます。
配信されるファイルのURLは以下のようになります。

::

  /img/myimage.png
  /css/mystyle.css
  /css/mystyle.min.css

プログラムからそのURLを参照するには以下のように指定します:

::

  <img src={publicUrl("img/myimage.png")} />

開発環境で非圧縮ファイルをレスポンスし、本番環境でその圧縮ファイルをレスポンスするには(例: 上記の
mystyle.cssとmystyle.min.css):

::

  <img src={publicUrl("css", "mystyle.css", "mystyle.min.css")} />

ディスク上の静的ファイルをアクションからレスポンスするには ``respondFile`` を使用します。

::

  respondFile("/absolute/path")
  respondFile("path/relative/to/the/current/working/directory")

静的ファイルの配信速度を最適化するため、
ファイル存在チェックを正規表現を使用して回避することができます。
リクエストされたURLが ``pathRegex`` にマッチしない場合、Xitrumはそのリクエストに対して404エラーを返します。

詳しくは ``config/xitrum.conf`` の ``pathRegex`` の設定を参照してください。

index.htmlへのフォールバック
----------------------------

``/foo/bar`` (または ``/foo/bar/`` )へのルートが存在しない場合、
Xitrumは ``public`` ディレクトリ内に、``public/foo/bar/index.html`` が存在するかチェックします。
もしindex.htmlファイルが存在した場合、Xitrumはクライアントからのリクエストに対してindex.htmlを返します。


404 と 500
-----------

``public`` ディレクトリ内の404.htmlと500.htmlはそれぞれ、
マッチするルートが存在しない場合、リクエスト処理中にエラーが発生した場合に使用されます。
独自のエラーハンドラーを使用する場合、以下の様に記述します。

::

  import xitrum.Action
  import xitrum.annotation.{Error404, Error500}

  @Error404
  class My404ErrorHandlerAction extends Action {
    def execute() {
      if (isAjax)
        jsRespond("alert(" + jsEscape("Not Found") + ")")
      else
        renderInlineView("Not Found")
    }
  }

  @Error500
  class My500ErrorHandlerAction extends Action {
    def execute() {
      if (isAjax)
        jsRespond("alert(" + jsEscape("Internal Server Error") + ")")
      else
        renderInlineView("Internal Server Error")
    }
  }

HTTPレスポンスステータスは、アノテーションにより自動的に404または500がセットされるため、
あなたのプログラム上でセットする必要はありません。

WebJarによるクラスパス上のリソースファイルの配信
------------------------------------------------------------------------

WebJars
~~~~~~~

`WebJars <http://www.webjars.org/>`_ はフロントエンドに関わるのライブラリを多く提供しています。
Xitrumプロジェクトではそれらを依存ライブラリとして利用することができます。

例えば `Underscore.js <http://underscorejs.org/>`_ を使用する場合、
プロジェクトの ``build.sbt`` に以下のように記述します。

::

  libraryDependencies += "org.webjars" % "underscorejs" % "1.6.0-3"

そして.jadeファイルからは以下のように参照します:

::

  script(src={webJarsUrl("underscorejs/1.6.0", "underscore.js", "underscore-min.js")})

開発環境では  ``underscore.js`` が、 本番環境では　``underscore-min.js`` が、
Xitrumによって自動的に選択されます。

コンパイル結果は以下のようになります:

::

  /webjars/underscorejs/1.6.0/underscore.js?XOKgP8_KIpqz9yUqZ1aVzw

いずれの環境でも同じファイルを使用したい場合:

::

  script(src={webJarsUrl("underscorejs/1.6.0/underscore.js")})

WebJars形式によるリソースの保存
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

もしあなたがライブラリ開発者で、ライブラリ内のmyimage.pngというファイルを配信したい場合、
`WebJars <http://www.webjars.org/>`_ 形式で.jarファイルを作成し
クラスパス上に配置します。 .jarは以下の様な形式となります。

::

  META-INF/resources/webjars/mylib/1.0/myimage.png

プログラムから参照する場合:

::

  <img src={webJarsUrl("mylib/1.0/myimage.png")} />

開発環境、本番環境ともに以下のようにコンパイルされます:

::

  /webjars/mylib/1.0/myimage.png?xyz123

クラスパス上の要素をレスポンスする場合
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`WebJars <http://www.webjars.org/>`_ 形式で保存されていない
クラスパス上の静的ファイル(.jarファイルやディレクトリ)をレスポンスする場合

::

  respondResource("path/relative/to/the/classpath/element")

例:

::

  respondResource("akka/actor/Actor.class")
  respondResource("META-INF/resources/webjars/underscorejs/1.6.0/underscore.js")
  respondResource("META-INF/resources/webjars/underscorejs/1.6.0/underscore-min.js")


ETagとmax-ageによるクライアントサイドキャッシュ
------------------------------------------------

ディスクとクラスパス上にある静的ファイルに対して、Xitrumは自動的に `Etag <http://ja.wikipedia.org/wiki/HTTP_ETag>`_ を付加します。

小さなファイルはMD5化してキャッシュされます。
キャッシュエントリーのキーには ``(ファイルパス, 更新日時)`` が使用されます。
ファイルの変更時刻はサーバによって異なる可能性があるため
クラスタ上の各サーバはそれぞれETagキャッシュを保持することになります。

大きなファイルに対しては、更新日時のみがETagに使用されます。
これはサーバ間で異なるETagを保持してしまう可能性があるため完全ではありませんが、
ETagを全く使用しないよりはいくらかマシといえます。

``publicUrl`` と ``resourceUrl`` メソッドは自動的にETagをURLに付加します。:

::

  resourceUrl("xitrum/jquery-1.6.4.js")
  => /resources/public/xitrum/jquery-1.6.4.js?xndGJVH0zA8q8ZJJe1Dz9Q


またXitrumは、``max-age`` と ``Expires`` を `一年 <http://code.google.com/intl/en/speed/page-speed/docs/caching.html>`_ としてヘッダに設定します。.
ブラウザが最新ファイルを参照しなくなるのではないかと心配する必要はありません。
なぜなら、あなたがディスク上のファイルを変更した場合、その ``更新時刻`` は変化します。
これによって、``publicUrl`` と ``resourceUrl`` が生成するURLも変わります。
ETagキャッシュもまた、キーが変わったため更新される事になります。

GZIP
----

ヘッダーの ``Content-Type`` 属性を元にレスポンスがテキストかどうかを判定し、
``text/html``, ``xml/application`` などテキスト形式のレスポンスの場合、Xitrumは自動でgzip圧縮を適用します。

静的なテキストファイルは常にgzipの対象となりますが、動的に生成されたテキストコンテンツに対しては、
パフォーマンス最適化のため1KB以下のものはgzipの対象となりません。

サーバーサイドキャッシュ
------------------------

ディスクからのファイル読み込みを避けるため、Xitrumは小さな静的ファイルは（テキストファイル以外も）、
LRU(Least Recently Used)キャッシュとしてメモリ上に保持します。

詳しくは ``config/xitrum.conf`` の ``small_static_file_size_in_kb`` と ``max_cached_small_static_files`` の設定を参照してください。
