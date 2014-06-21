AkkaとHazelcastでサーバーをクラスタリングする
=============================================

Xitrumがプロキシサーバーやロードバランサーの後ろでクラスタ構成で動けるように設計されています。

::

                                  / Xitrumインスタンス1
  プロキシサーバー・ロードバランサー ---- Xitrumインスタンス2
                                  \ Xitrumインスタンス3

`Akka <http://akka.io/>`_ と `Hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_
のクラスタリング機能を使ってキャッシュ、セッション、SockJSセッションをクラスタリングできます。

Hazelcastを使えばXitrumインスタンスがプロセス内メモリキャッシュサーバーとなります。
Memcacheのような追加サーバーは不要です。

AkkaとHazelcastクラスタリングを設定するには ``config/akka.conf`` 、 `Akka ドキュメント <http://akka.io/docs/>`_、
`Hazelcast ドキュメント <http://hazelcast.org/documentation/>`_ を参考にしてください。

メモ: セッションは :doc:`クライアント側のクッキーへ保存</scopes>` することができます。
