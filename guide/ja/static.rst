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

プログラムからそのURLを参照するには以下のように指定します:

::

  <img src={publicUrl("img/myimage.png")} />

ディスク上の静的ファイルをアクションでレスポンスするには ``respondFile`` を使用します。

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

クラスパス上のリソースファイルの配信
------------------------------------

もしあなたがライブラリ開発者で、クラスパス上の.jarファイル内に存在するmyimage.pngというファイルを使用したい場合、
.jarファイルを ``public`` ディレクトリに配置します。

::

  public/my_lib/img/myimage.png

プログラムから参照する場合:

::

  <img src={resourceUrl("my_lib/img/myimage.png")} />

と記述することで、以下のように展開されます:

::

  <img src="/resources/public/my_lib/img/myimage.png" />

クラスパス上の静的ファイルをレスポンスする場合:

::

  respondResource("path/relative/to/the/element")

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
