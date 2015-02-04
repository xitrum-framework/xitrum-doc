Nettyハンドラ
=============

この章はXitrumを普通に使用する分には読む必要はありません。
理解するには `Netty <http://netty.io/>`_ の経験が必要です。

`Rack <http://en.wikipedia.org/wiki/Rack_(Web_server_interface)>`_ 、
`WSGI <http://en.wikipedia.org/wiki/Web_Server_Gateway_Interface>`_ 、
`PSGI <http://en.wikipedia.org/wiki/PSGI>`_ にはミドルウェア構成があります。
`Netty <http://netty.io/>`_ には同じようなハンドラ構成があります。
XitrumはNettyの上で構築され、ハンドラ追加作成やハンドラのパイプライン変更などができ、
特定のユースケースにサーバーのパフォーマンスを最大化することができます。

この章では次の内容を説明します:

* Nettyハンドラ構成
* Xitrumが提供するハンドラ一覧とそのデフォルト順番
* ハンドラ一の追加作成と使用方法

Nettyハンドラの構成
-------------------

それぞれのコネクションには、入出力データを処理するパイプラインがーつあります。
チャネルパイプラインは複数のハンドラによって構成され、ハンドラには以下の2種類あります:

* 入力方向(Inbound): リクエスト方向クライアント -> サーバー
* 出力方向(Inbound): レスポンス方向サーバー -> クライアント

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

ハンドラの追加作成
------------------

Xitrumを起動する際に自由に
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
Xitrumが提供するハンドラを自分のパイプラインに再利用することも可能です。

Xitrumが提供するハンドラ
------------------------

`xitrum.handler.DefaultHttpChannelInitializer <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/handler/DefaultHttpChannelInitializer.scala>`_
を参照してください。

共有可能なハンドラ（複数のコネクションで同じインスタンスを共有できるハンドラ）は上記
``DefaultHttpChannelInitializer`` オブジェクトに置かれてあります。
使いたいXitrumハンドラを選択し自分のパイプラインに簡単に設定できます。

例えば、Xitrumのrouting/dispatcherは使用せずに独自のディスパッチャを使用して、
Xitrumからは静的ファイルのハンドラのみを利用する場合

以下のハンドラのみ設定します:

入力方向(Inbound):

* ``HttpRequestDecoder``
* ``PublicFileServer``
* 独自のrouting/dispatcher

出力方向(Outbound):

* ``HttpResponseEncoder``
* ``ChunkedWriteHandler``
* ``XSendFile``
