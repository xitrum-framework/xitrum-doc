Xitrum ガイド日本語版
=====================

このドキュメントは `Xitrum Guide <http://xitrum-framework.github.io/xitrum/guide/>`_ の日本語翻訳版です。



はじめに
========

::

  +--------------------+
  |      Your app      |
  +--------------------+
  |    Xitrum fusion   |
  | +----------------+ |
  | | Web framework  | |  <-- Akka cluster --> Other instances
  | |----------------| |
  | | HTTP(S) Server | |
  | +----------------+ |
  +--------------------+
  |       Netty        |
  +--------------------+

Xitrumは `Netty <http://netty.io/>`_ と `Akka <http://akka.io/>`_ をベースに構築された非同期でスケーラブルなHTTP(S) WEBフレームワークです。

Xitrum `ユーザーの声 <https://groups.google.com/group/xitrum-framework/msg/d6de4865a8576d39>`_:

  これは本当に印象的な作品である。Liftを除いておそらく最も完全な（そしてとても簡単に使える）Scalaフレームワークです。

  XitrumはWebアプリケーションフレームワークの基本的な機能を全て満たしている本物のフルスタックのWebフレームワークである。
  とてもうれしいことにそこには、ETag、静的ファイルキャッシュ、自動gzip圧縮があり、
  組込みのJSONのコンバータ、インターセプタ、リクエスト/セッション/クッキー/フラッシュの各種スコープ、
  サーバー・クライアントにおける統合的バリデーション、内蔵キャッシュ(`Hazelcast <http://www.hazelcast.com/>`_)、i18N、そしてNettyが組み込まれている。
  これらの機能を直ぐに使うことができる。ワオ。


特徴
----

* Scalaの思想に基づく型安全。 全てのAPIは型安全であるべくデザインされています。
* Nettyの思想に基づく非同期。 リクエストを捌くアクションは直ぐにレスポンスを返す必要はありません。
  ロングポーリング、チャンクレスポンス（ストリーミング）、WebSocket、そしてSockJSをサポートしています。
* `Netty <http://netty.io/>`_ 上に構築された高速HTTP(S) サーバー。
  Xitrumの静的ファイル配信速度は `Nginxに匹敵 <https://gist.github.com/3293596>`_ します。
* 高速なレスポンスを実現する大規模なサーバサイドおよびクライアントサイド双方のキャッシュシステム。
  サーバーレイヤでは小さなファイルはメモリにキャッシュされ、大きなファイルはNIOのzero copyを使用して送信されます。
  ウェブフレームワークとしてpage、action、そしてobjectをRailsのスタイルでキャッシュすることができます。
  `All Google's best practices <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_ にあるように、
  条件付きGETに対してはクライアントサイドキャッシュが適用されます。
  もちろんブラウザにリクエストの再送信を強制させることもできます。
* JAX-RSとRailsエンジンの思想に基づく自動ルートコレクション。全てのルートを１箇所に宣言する必要はありません。
  この機能は分散ルーティングと捉えることができます。この機能のおかげでアプリケーションを他のアプリケーションに取り込むことが可能になります。
  もしあなたがブログエンジンを作ったならそれをJARにして別のアプリケーションに取り込むだけですぐにブログ機能が使えるようになるでしょう。
  ルーティングには更に2つの特徴があります。
  ルートの作成（リバースルーティング）は型安全に実施され、
  `Swagger Doc <http://swagger.wordnik.com/>`_ を使用したルーティングに関するドキュメント作成も可能となります。
* Viewは独立した `Scalate <http://scalate.fusesource.org/>`_ テンプレートとして、
  またはScalaによるインラインXMLとして、どちらも型安全に記述することが可能です。
* クッキーによる（よりスケーラブルな）、`Hazelcast <http://www.hazelcast.com/>`_ クラスターによる(よりセキュアな)セッション管理。
  Hazelcastは（とても早くて、簡単に）プロセス間分散キャッシュも提供してくれます。
  このため別のキャッシュサーバーを用意する必要はなくなります。これはAkkaのpubsub機能にも言えることです。
* `jQuery Validation <http://docs.jquery.com/Plugins/validation>`_ によるブラウザー、サーバーサイド双方でのバリデーション。
* `GNU gettext <http://en.wikipedia.org/wiki/GNU_gettext>`_ を使用した国際化対応。
  翻訳テキストの抽出は自動で行われるため、プロパティファイルに煩わされることはなくなるでしょう。
  翻訳とマージ作業には `Poedit <http://www.poedit.net/screenshots.php>`_ のようなパワフルなツールが使えます。
  gettextは、他のほとんどのソリューションとは異なり、単数系と複数系の両方の形式をサポートしています。

Xitrumは `Scalatra <https://github.com/scalatra/scalatra>`_ よりパワフルに、
`Lift <http://liftweb.net/>`_ より簡単であることで両者のスペクトルを満たすことを目的としています。
`Xitrum <http://xitrum-framework.github.com/xitrum>`_ はScalatraのようにcontroller-firstであり、Liftのような `view-first <http://www.assembla.com/wiki/show/liftweb/View_First>`_ ではありません。
多くの開発者にとって馴染み部会controller-firstスタイルです。

`Xitrum <http://xitrum-framework.github.com/xitrum>`_ は `オープンソース <https://github.com/xitrum-framework/xitrum>`_ プロジェクトです。
`Google group <http://groups.google.com/group/xitrum-framework>`_. のコミュニティに参加してみてください。

サンプル
--------

* `Xitrum Demos <https://github.com/xitrum-framework/xitrum-demos>`_
* `Xitrum Modularized Demo <https://github.com/xitrum-framework/xitrum-modularized-demo>`_
* `Placeholder <https://github.com/xitrum-framework/xitrum-placeholder>`_
* `Comy <https://github.com/xitrum-framework/comy>`_
