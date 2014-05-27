Nettyハンドラ
==============

この章はXitrumを普通に使用するには読まなくても良いです。理解するには`Netty <http://netty.io/>`_
の経験が必要です。

`Rack <http://en.wikipedia.org/wiki/Rack_(Web_server_interface)>`_、
`WSGI <http://en.wikipedia.org/wiki/Web_Server_Gateway_Interface>`_、
`PSGI <http://en.wikipedia.org/wiki/PSGI>`_はミドルウェア構成があります。
`Netty <http://netty.io/>`_が同じようなハンドラ構成があります。
XitrumがNettyの上で構築され、ハンドラ追加作成やハンドラのパイプライン変更などができ、
特定のユースケースにサーバーのパフォーマンスを最大化することができます。

この章では次の内容を説明します:

* Nettyハンドラ構成
* Xitrumが提供するハンドラ一覧とそのデフォルト順番
* ハンドラ一の追加作成と使用方法

Nettyハンドラ構成
--------------------------

ーつのコネクションには入出力データを処理するハンドラのパイプラインがーつあります。
ハンドラが2種類あります:

* 入力方向: リクエスト方向クライアント -> サーバー
* 出力方向: リスポンス方向サーバー -> クライアント

`ChannelPipeline <http://netty.io/4.0/api/io/netty/channel/ChannelPipeline.html>`_
の資料を参考にしてください。

::

                                                 I/O Request
                                            via Channel or
                                        ChannelHandlerContext
                                                      |
  +---------------------------------------------------+---------------+
  |                           ChannelPipeline         |               |
  |                                                  \|/              |
  |    +---------------------+            +-----------+----------+    |
  |    | Inbound Handler  N  |            | Outbound Handler  1  |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  |               |
  |               |                                  \|/              |
  |    +----------+----------+            +-----------+----------+    |
  |    | Inbound Handler N-1 |            | Outbound Handler  2  |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  .               |
  |               .                                   .               |
  | ChannelHandlerContext.fireIN_EVT() ChannelHandlerContext.OUT_EVT()|
  |        [ method call]                       [method call]         |
  |               .                                   .               |
  |               .                                  \|/              |
  |    +----------+----------+            +-----------+----------+    |
  |    | Inbound Handler  2  |            | Outbound Handler M-1 |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  |               |
  |               |                                  \|/              |
  |    +----------+----------+            +-----------+----------+    |
  |    | Inbound Handler  1  |            | Outbound Handler  M  |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  |               |
  +---------------+-----------------------------------+---------------+
                  |                                  \|/
  +---------------+-----------------------------------+---------------+
  |               |                                   |               |
  |       [ Socket.read() ]                    [ Socket.write() ]     |
  |                                                                   |
  |  Netty Internal I/O Threads (Transport Implementation)            |
  +-------------------------------------------------------------------+

ハンドラ追加作成
---------------

Xitrumを立ち上げる際に自分の
`ChannelInitializer <http://netty.io/4.0/api/io/netty/channel/ChannelInitializer.html>`_
が設定できます:

::

  import xitrum.Server

  object Boot {
    def main(args: Array[String]) {
      Server.start(myChannelInitializer)
    }
  }

HTTPSサーバーの場合、Xitrumが自動でパイプラインの先頭にSSLハンドラを追加します。
Xitrumが提供するハンドラを自分のパイプラインに利用できます。

Xitrumが提供するハンドラ
-----------------------

`xitrum.handler.DefaultHttpChannelInitializer <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/handler/ChannelInitializer.scala>`_
をご覧ください。

共有できるハンドラ（同じハンドラインスタンスを複数コネクションに共有できる。）は上記
``DefaultHttpChannelInitializer``オブジェクトに置かれてあります。使いたいXitrumハンドラを
選択し自分のパイプラインに簡単に設定できます。

例えば、Xitrumのrouting/dispatcherでなく自分のものと静的ファイルのハンドラを使いたい場合、
以下のハンドラのみ設定して良い:

入力方向:

* ``HttpRequestDecoder``
* ``PublicFileServer``
* 自分のrouting/dispatcher

出力方向:

* ``HttpResponseEncoder``
* ``ChunkedWriteHandler``
* ``XSendFile``
