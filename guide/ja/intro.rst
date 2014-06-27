はじめに
========

::

  +--------------------+
  |      Clients       |
  +--------------------+
            |
  +--------------------+
  |       Netty        |
  +--------------------+
  |       Xitrum       |
  | +----------------+ |
  | | HTTP(S) Server | |
  | |----------------| |
  | | Web framework  | |  <- Akka, Hazelcast -> Other instances
  | +----------------+ |
  +--------------------+
  |      Your app      |
  +--------------------+

Xitrumは `Netty <http://netty.io/>`_ と `Akka <http://akka.io/>`_ をベースに構築された非同期でスケーラブルなHTTP(S) WEBフレームワークです。

Xitrum `ユーザーの声 <https://groups.google.com/group/xitrum-framework/msg/d6de4865a8576d39>`_:

  これは本当に印象的な作品である。Liftを除いておそらく最も完全な（そしてとても簡単に使える）Scalaフレームワークです。

  XitrumはWebアプリケーションフレームワークの基本的な機能を全て満たしている本物のフルスタックのWebフレームワークである。
  とてもうれしいことにそこには、ETag、静的ファイルキャッシュ、自動gzip圧縮があり、
  組込みのJSONのコンバータ、インターセプタ、リクエスト/セッション/クッキー/フラッシュの各種スコープ、
  サーバー・クライアントにおける統合的バリデーション、内蔵キャッシュ(`Hazelcast <http://www.hazelcast.org/>`_)、i18N、そしてNettyが組み込まれている。
  これらの機能を直ぐに使うことができる。ワオ。

特徴
----

* Scalaの思想に基づく型安全。 全てのAPIは型安全であるべくデザインされています。
* Nettyの思想に基づく非同期。 リクエストを捌くアクションは直ぐにレスポンスを返す必要はありません。
  ロングポーリング、チャンクレスポンス（ストリーミング）、WebSocket、そしてSockJSをサポートしています。
* `Netty <http://netty.io/>`_ 上に構築された高速HTTP(S) サーバー。
  (HTTPSはJavaエンジンとOpenSSLエンジン選択できます。)
  Xitrumの静的ファイル配信速度は `Nginxに匹敵 <https://gist.github.com/3293596>`_ します。
* 高速なレスポンスを実現する大規模なサーバサイドおよびクライアントサイド双方のキャッシュシステム。
  サーバーレイヤでは小さなファイルはメモリにキャッシュされ、大きなファイルはNIOのzero copyを使用して送信されます。
  ウェブフレームワークとしてpage、action、そしてobjectをRailsのスタイルでキャッシュすることができます。
  `All Google's best practices <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_ にあるように、
  条件付きGETに対してはクライアントサイドキャッシュが適用されます。
  もちろんブラウザにリクエストの再送信を強制させることもできます。
* 静的ファイルに対する `Range requests <http://en.wikipedia.org/wiki/Byte_serving>`_ サポート。
  この機能により、スマートフォンに対する動画配信や、全てのクライアントに対するファイルダウンロードの停止と再開を実現できます。
* `CORS <http://en.wikipedia.org/wiki/Cross-origin_resource_sharing>`_ 対応。
* JAX-RSとRailsエンジンの思想に基づく自動ルートコレクション。全てのルートを１箇所に宣言する必要はありません。
  この機能は分散ルーティングと捉えることができます。この機能のおかげでアプリケーションを他のアプリケーションに取り込むことが可能になります。
  もしあなたがブログエンジンを作ったならそれをJARにして別のアプリケーションに取り込むだけですぐにブログ機能が使えるようになるでしょう。
  ルーティングには更に2つの特徴があります。
  ルートの作成（リバースルーティング）は型安全に実施され、
  `Swagger Doc <http://swagger.wordnik.com/>`_ を使用したルーティングに関するドキュメント作成も可能となります。
* クラスファイルおよびルートは開発時にはXitrumによって自動的にリロードされます。
* Viewは独立した `Scalate <http://scalate.fusesource.org/>`_ テンプレートとして、
  またはScalaによるインラインXMLとして、どちらも型安全に記述することが可能です。
* クッキーによる（よりスケーラブルな）、`Hazelcast <http://www.hazelcast.org/>`_ クラスターによる(よりセキュアな)セッション管理。
  Hazelcastは（とても早くて、簡単に）プロセス間分散キャッシュも提供してくれます。
  このため別のキャッシュサーバーを用意する必要はなくなります。これはAkkaのpubsub機能にも言えることです。
* `jQuery Validation <http://docs.jquery.com/Plugins/validation>`_ によるブラウザー、サーバーサイド双方でのバリデーション。
* `GNU gettext <http://en.wikipedia.org/wiki/GNU_gettext>`_ を使用した国際化対応。
  翻訳テキストの抽出は自動で行われるため、プロパティファイルに煩わされることはなくなるでしょう。
  翻訳とマージ作業には `Poedit <http://www.poedit.net/screenshots.php>`_ のようなパワフルなツールが使えます。
  gettextは、他のほとんどのソリューションとは異なり、単数系と複数系の両方の形式をサポートしています。

Xitrumは `Scalatra <https://github.com/scalatra/scalatra>`_ よりパワフルに、
`Lift <http://liftweb.net/>`_ より簡単であることで両者のスペクトルを満たすことを目的としています。
`Xitrum <http://xitrum-framework.github.io/>`_ はScalatraのようにcontroller-firstであり、Liftのような `view-first <http://www.assembla.com/wiki/show/liftweb/View_First>`_ ではありません。
多くの開発者にとって馴染み部会controller-firstスタイルです。

:doc:`関係プロジェクト </deps>` サンプルやプラグインなどのプロジェクト一覧をご覧ください。

貢献者
------

`Xitrum <http://xitrum-framework.github.io/>`_ は `オープンソース <https://github.com/xitrum-framework/xitrum>`_ プロジェクトです。
`Google group <http://groups.google.com/group/xitrum-framework>`_. のコミュニティに参加してみてください。

貢献者の一覧が`最初の貢献 <https://github.com/xitrum-framework/xitrum/graphs/contributors>`_の順番で記載されています:

(*): 現在アクティブなコアメンバー

* `Ngoc Dao (*) <https://github.com/ngocdaothanh>`_
* `Linh Tran <https://github.com/alide>`_
* `James Earl Douglas <https://github.com/JamesEarlDouglas>`_
* `Aleksander Guryanov <https://github.com/caiiiycuk>`_
* `Takeharu Oshida (*) <https://github.com/georgeOsdDev>`_
* `Nguyen Kim Kha <https://github.com/kimkha>`_
* `Michael Murray <https://github.com/murz>`_
