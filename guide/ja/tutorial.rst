チュートリアル
==============

本章ではXitrumプロジェクトを作成して実行するところまでを簡単に紹介します。

**このチュートリアルではJavaがインストールされたLinux環境を想定しています。**

Xitrumプロジェクトの作成
--------------------------

新規のプロジェクトを作成するには
`xitrum-new.zip <https://github.com/xitrum-framework/xitrum-new/archive/master.zip>`_ をダウンロードします。

::

  wget -O xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

または:

::

  curl -L -o xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

起動
----

Scalaのビルドツールとしてデファクトスタンダードである `SBT <https://github.com/harrah/xsbt/wiki/Setup>`_ を使用します。
先ほどダウンロードしたプロジェクトには既に SBT 0.13 が ``sbt`` ディレクトリに梱包されています。
SBTを自分でインストールするには、SBTの `セットアップガイド <https://github.com/harrah/xsbt/wiki/Setup>`_ を参照してください。

作成したプロジェクトのルートディレクトリで ``sbt/sbt run`` と実行することでXitrumが起動します:

::

  unzip xitrum-new.zip
  cd xitrum-new
  sbt/sbt run


このコマンドは依存ライブラリ( :doc:`dependencies </deps>` )のダウンロード, およびプロジェクトのコンパイルを実行後、
``quickstart.Boot`` クラスが実行され、WEBサーバーが起動します。
コンソールには以下の様なルーティング情報が表示されます。

::

  [INFO] Load routes.cache or recollect routes...
  [INFO] Normal routes:
  GET  /  quickstart.action.SiteIndex
  [INFO] SockJS routes:
  xitrum/metrics/channel  xitrum.metrics.XitrumMetricsChannel  websocket: true, cookie_needed: false
  [INFO] Error routes:
  404  quickstart.action.NotFoundError
  500  quickstart.action.ServerError
  [INFO] Xitrum routes:
  GET        /webjars/swagger-ui/2.0.17/index                            xitrum.routing.SwaggerUiVersioned
  GET        /xitrum/xitrum.js                                           xitrum.js
  GET        /xitrum/metrics/channel                                     xitrum.sockjs.Greeting
  GET        /xitrum/metrics/channel/:serverId/:sessionId/eventsource    xitrum.sockjs.EventSourceReceive
  GET        /xitrum/metrics/channel/:serverId/:sessionId/htmlfile       xitrum.sockjs.HtmlFileReceive
  GET        /xitrum/metrics/channel/:serverId/:sessionId/jsonp          xitrum.sockjs.JsonPPollingReceive
  POST       /xitrum/metrics/channel/:serverId/:sessionId/jsonp_send     xitrum.sockjs.JsonPPollingSend
  WEBSOCKET  /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocket
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr            xitrum.sockjs.XhrPollingReceive
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr_send       xitrum.sockjs.XhrSend
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr_streaming  xitrum.sockjs.XhrStreamingReceive
  GET        /xitrum/metrics/channel/info                                xitrum.sockjs.InfoGET
  WEBSOCKET  /xitrum/metrics/channel/websocket                           xitrum.sockjs.RawWebSocket
  GET        /xitrum/metrics/viewer                                      xitrum.metrics.XitrumMetricsViewer
  GET        /xitrum/metrics/channel/:iframe                             xitrum.sockjs.Iframe
  GET        /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocketGET
  POST       /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocketPOST
  [INFO] HTTP server started on port 8000
  [INFO] HTTPS server started on port 4430
  [INFO] Xitrum started in development mode

初回起動時には、全てのルーティングが収集されログに出力されます。
この情報はアプリケーションのRESTful APIについてドキュメントを書く場合この情報はとても役立つことでしょう。

ブラウザで `http://localhost:8000 <http://localhost:8000/>`_ もしくは `https://localhost:4430 <http://localhost:4430/>`_ にアクセスしてみましょう。
次のようなリクエスト情報がコンソールから確認できます。

::

  [INFO] GET quickstart.action.SiteIndex, 1 [ms]

Eclipseプロジェクトの作成
-------------------------

開発環境に `Eclipse <http://scala-ide.org/>`_ を使用する場合

プロジェクトディレクトリで以下のコマンドを実行します:

::

  sbt/sbt eclipse

``build.sbt`` に記載されたプロジェクト設定に応じてEclipse用の ``.project`` ファイルが生成されます。
Eclipseを起動してインポートしてください。

IntelliJ IDEAプロジェクトの作成
-------------------------------

開発環境に `IntelliJ IDEA <http://www.jetbrains.com/idea/>`_ を仕様する場合

プロジェクトディレクトリで以下のコマンドを実行します:

::

  sbt/sbt gen-idea

``build.sbt`` に記載されたプロジェクト設定に応じてIntelliJ用の ``.idea`` ファイルが生成されます。
IntelliJを起動してインポートしてください。

自動リロード
------------

プログラムを再起動することなく .classファイルをリロード（ホットスワップ)することができます。
ただし、プログラムのパフォーマンスと安定性を維持するため、自動リロード機能は開発時のみ使用することを推奨します。

IDEを使用する場合
~~~~~~~~~~~~~~~~~~~

最新のEclipseやIntelliJのようなIDEを使用して開発、起動を行う場合、
デフォルトでIDEがソースコードの変更を監視して、変更があった場合に自動でコンパイルしてくれます。

SBTを使用する場合
~~~~~~~~~~~~~~~~~~~

SBTを使用する場合、2つのコンソールを用意する必要があります:

* 一つ目は ``sbt/sbt run`` を実行します。 このコマンドはプログラムを起動して、 .classファイルに変更があった場合にリロードを行います。
* もう一方は ``sbt/sbt ~compile`` を実行します。 このコマンドはソースコードの変更を監視して、変更があった場合に .classファイルにコンパイルします。

sbtディレクトリには `agent7.jar <https://github.com/xitrum-framework/agent7>`_ が含まれます。
このライブラリは、カレントディレクトリ（およびサブディレクトリ)の .classファイルのリロードを担当します。
``sbt/sbt`` スクリプトの中で ``-javaagent:agent7.jar`` として使用されています。

DCEVM
~~~~~

通常のJVMはクラスファイルがリロードされた際、メソッドのボディのみ変更が反映されます。
Java HotSpot VM のオープンソース実装である `DCEVM <https://github.com/dcevm/dcevm>`_ を使用することで、
ロードしたクラスの再定義をより柔軟に行うことができるようになります。

DCEVMは以下の2つの方法でインストールできます:

* インストール済みのJavaへ `Patch <https://github.com/dcevm/dcevm/releases>`_ を行う方法
* `prebuilt <http://dcevm.nentjes.com/>`_ バージョンのインストール (こちらのほうが簡単です)

パッチを使用してインストールを行う場合:

* DCEVMを常に有効にすることができます。
* もしくはDCEVMを"alternative" JVMとして適用することができます。
  この場合、``java`` コマンドに ``-XXaltjvm=dcevm`` オプションを指定することでDCEVMを使用することができます。
  例えば、 ``sbt/sbt`` スクリプトファイルに ``-XXaltjvm=dcevm`` を追記する必要があります。

EclipseやIntelliJのようなIDEを使用している場合、DCEVMをプロジェクトの実行JVMに指定する必要があります。

SBTを使用している場合は、 ``java`` コマンドがDCEVMのものを利用できるように ``PATH`` 環境変数を設定する必要があります。
DCEVM自体はクラスの変更をサポートしますが、リロードは行わないため、DCEVMを使用する場合も前述の ``javaagent`` は必要となります。

詳細は `DCEVM - A JRebel free alternative <http://javainformed.blogspot.jp/2014/01/jrebel-free-alternative.html>`_ を参照してください。

ignoreファイルの設定
--------------------

:doc:`チュートリアル </tutorial>` に沿ってプロジェクトを作成した場合 `ignored <https://github.com/xitrum-framework/xitrum-new/blob/master/.gitignore>`_ を参考にignoreファイルを作成してください。

::

  .*
  log
  project/project
  project/target
  target
  tmp
