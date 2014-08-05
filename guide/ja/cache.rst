サーバーサイドキャッシュ
========================

:doc:`クラスタリング </cluster>` の章についても参照してください。

より高速なレスポンスの実現のために、Xitrumはクライアントサイドとサーバーサイドにおける広範なキャッシュ機能を提供します。

サーバーサイドレイヤーでは、小さなファイルはメモリ上にキャッシュされ、大きなファイルはNIOのゼロコピーを使用して送信されます。
Xitrumの静的ファイルの配信速度は `Nginxと同等 <https://gist.github.com/3293596>`_ です。

Webフレームワークのレイヤーでは、Railsのスタイルでページやアクション、オブジェクトをキャッシュすることができます。

`All Google's best practices（英語） <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_
にあるように、条件付きGETリクエストはクライアントサイドでキャッシュされます。

動的なコンテンツに対しては、もしファイルが作成されてから変更されない場合、クライアントに積極的にキャッシュするように
ヘッダーをセットする必要があります。
このケースでは、``setClientCacheAggressively()`` をアクションにて呼び出すことで実現できます。

クライアントにキャッシュさせたくない場合もあるでしょう、
そういったケースでは、 ``setNoClientCache()`` をアクションにて呼び出すことで実現できます。

サーバーサイドキャッシュについては以下のサンプルでより詳しく説明します。

ページまたはアクションのキャッシュ
----------------------------------

::

  import xitrum.Action
  import xitrum.annotation.{GET, CacheActionMinute, CachePageMinute}

  @GET("articles")
  @CachePageMinute(1)
  class ArticlesIndex extends Action {
    def execute() {
      ...
    }
  }

  @GET("articles/:id")
  @CacheActionMinute(1)
  class ArticlesShow extends Action {
    def execute() {
      ...
    }
  }

"page cache" と "acation cache" の期間設定は `Ruby on Rails <http://guides.rubyonrails.org/caching_with_rails.html>`_ を参考にしています。

リクエスト処理プロセスの順番は以下のようになります。

(1) リクエスト -> (2) Beforeフィルター -> (3) アクション execute method -> (4) レスポンス

初回のリクエスト時に、Xitrumはレスポンスを指定された期間だけキャッシュします。
``@CachePageMinute(1)`` や ``@CacheActionMinute(1)`` は1分間キャッシュすることを意味します。
Xitrumはレスポンスステータスが "200 OK" の場合のみキャッシュします。
そのため、レスポンスステータスが "500 Internal Server Error" や "302 Found" (リダイレクト) となるレスポンスはキャッシュされせん。

同じアクションに対する2回目以降のリクエストは、もし、キャッシュされたレスポンスが有効期間内の場合、
Xitrumはすぐにキャッシュされたレスポンスを返却します:

* ページキャッシュの場合、 処理プロセスは、　(1) -> (4) となります。
* アクションキャッシュの場合、 (1) -> (2) -> (4), またはBeforeフィルターが"false"を返した場合 (1) -> (2) となります。

すなわち、actionキャッシュとpageキャッシュとの違いは、Beforeフィルターを実施するか否かになります。

一般に、ページキャッシュは全てのユーザーに共通なレスポンスの場合に使用します。
アクションキャッシュは、Beforeフィルターを通じて、例えばユーザーのログイン状態チェックなどを行い、キャッシュされたレスポンスを "ガード" する場合に用います:

* ログインしている場合、キャッシュされたレスポンスにアクセス可能。
* ログインしていない場合、ログインページヘリダイレクト。

オブジェクトのキャッシュ
------------------------

`xitrum.Cache <http://xitrum-framework.github.io/api/3.17/index.html#xitrum.Cache>`_ のインスタンスである、
``xitrum.Config.xitrum.cache`` を使用することができます。

明示的な有効期限を設定しない場合:

* put(key, value)

有効期限を設定する場合:

* putSecond(key, value, seconds)
* putMinute(key, value, minutes)
* putHour(key, value, hours)
* putDay(key, value, days)

存在しない場合のみキャッシュする方法:

* putIfAbsent(key, value)
* putIfAbsentSecond(key, value, seconds)
* putIfAbsentMinute(key, value, minutes)
* putIfAbsentHour(key, value, hours)
* putIfAbsentDay(key, value, days)

キャッシュの削除
----------------

ページまたはアクションキャッシュの削除:

::

  removeAction[MyAction]

オブジェクトキャッシュの削除:

::

  remove(key)

指定したプレフィックスで始まるキー全てを削除:

::

  removePrefix(keyPrefix)

``removePrefix`` を使用することで、プレフィックスを使用した階層的なキャッシュを構築することができます。

例えば、記事に関連する要素をキャッシュしたい場合、記事が変更された時に関連するキャッシュは以下の方法で全てクリアできます。

::

  import xitrum.Config.xitrum.cache

  // prefixを使用してキャッシュします。
  val prefix = "articles/" + article.id
  cache.put(prefix + "/likes", likes)
  cache.put(prefix + "/comments", comments)

  // articleに関連する全てのキャッシュを削除したい場合は以下のようにします。
  cache.remove(prefix)

キャッシュエンジンの設定
------------------------

Xitrumのキャッシュ機能はキャッシュエンジンによって提供されます。
キャッシュエンジンはプロジェクトの必要に応じて選択することができます。
キャッシュエンジンの設定は、`config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_ において、使用するエンジンに応じて以下の2通りの記載方法で設定できます。

::

  cache = my.cache.EngineClassName

または:

::

  cache {
    "my.cache.EngineClassName" {
      option1 = value1
      option2 = value2
    }
  }

Xitrumは以下のエンジンを内包しています:

::

  cache {
    # Simple in-memory cache
    "xitrum.local.LruCache" {
      maxElems = 10000
    }
  }

もし、クラスタリングされたサーバーを使用する場合、キャッシュエンジンには、`Hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_ を使用することができます。

独自のキャッシュエンジンを使用する場合、``xitrum.Cache`` の `interface <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/Cache.scala>`_ を実装してください。

キャッシュ動作の仕組み
----------------------

入力方向（Inbound）:

::

                 アクションのレスポンスが
                 キャッシュ対象かつ
  request        キャッシュが存在している
  -------------------------+---------------NO--------------->
                           |
  <---------YES------------+
    キャッシュからレスポンス


出力方向（Outbound）:

::

                 アクションのレスポンスが
                 キャッシュ対象かつ
                 キャッシュがまだ存在していない 　          response
  <---------NO-------------+---------------------------------
                           |
  <---------YES------------+
    store response to cache

xitrum.util.LocalLruCache
-------------------------

上記で述べたキャッシュエンジンは、システム全体で共有されるキャッシュとなります。
もし小さくで簡易なキャッシュエンジンのみ必要な場合、``xitrum.util.LocalLruCache`` を使用します。

::

  import xitrum.util.LocalLruCache

  // LRU (Least Recently Used) キャッシュは1000要素まで保存できます
  // キーとバリューは両方String型となります
  val cache = LocalLruCache[String, String](1000)

使用できる ``cache`` は `java.util.LinkedHashMap <http://docs.oracle.com/javase/6/docs/api/java/util/LinkedHashMap.html>`_ のインスタンスであるため、
``LinkedHashMap`` のメソッドを使用して扱う事ができます。
