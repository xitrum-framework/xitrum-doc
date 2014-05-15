チュートリアル
==============

本章ではXitrumプロジェクトを作成して実行するところまでをやってみます。
**このチュートリアルではJavaがインストールされたLinux環境を想定しています。**

Xitrumプロジェクトの作成
--------------------------

新規のプロジェクトを作成するには
`xitrum-new.zip <https://github.com/xitrum-framework/xitrum-new/archive/master.zip>`_ をダウンロードしましょう。

::

  wget -O xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

または、

::

  curl -L -o xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

起動
----

Scalaのビルドツールとしてデファクトスタンダードである `SBT <https://github.com/harrah/xsbt/wiki/Setup>`_ を使用します。
先ほどダウンロードしたプロジェクトには既に SBT 0.13.1 が ``sbt`` ディレクトリに梱包されています。
SBTを自分でインストールするには、SBTの `セットアップガイド <https://github.com/harrah/xsbt/wiki/Setup>`_ を参照してください。

作成したプロジェクトのルートディレクトリで ``sbt/sbt run`` を実行することでXitrumが起動します。

::

  unzip xitrum-new.zip
  cd xitrum-new
  sbt/sbt run


このコマンドでは依存ライブラリ( :doc:`dependencies </deps>` )のダウンロード, およびプロジェクトのコンパイルを実施後に、
``quickstart.Boot`` クラスが実行され、WEBサーバーが起動します。
コンソールには以下の様なルーティング情報が表示されます。

::

  [INFO] Routes:
  GET  /                  quickstart.action.SiteIndex
  GET  /xitrum/routes.js  xitrum.routing.JSRoutesAction
  [INFO] HTTP server started on port 8000
  [INFO] HTTPS server started on port 4430
  [INFO] Xitrum started in development mode

初回起動時には、全てのルーティングが収集されログに出力されます。
この情報はアプリケーションのRESTful APIについてドキュメントを書く場合この情報はとても役立つことでしょう。

ブラウザで `http://localhost:8000 <http://localhost:8000/>`_ もしくは `https://localhost:4430 <http://localhost:4430/>`_ にアクセスしてみましょう。
次のようなリクエスト情報がコンソールから確認できます。

::

  [DEBUG] GET quickstart.action.SiteIndex, 1 [ms]
