Netty handler
=============

Chương này sử dụng các kiến thức nâng cao, bạn không cần biết sử dụng Xitrum 
một cách thông thường. Để có thể hiểu, bạn cần có kiến thức về `Netty <http://netty.io/>`_.

`Rack <http://en.wikipedia.org/wiki/Rack_(Web_server_interface)>`_,
`WSGI <http://en.wikipedia.org/wiki/Web_Server_Gateway_Interface>`_, và
`PSGI <http://en.wikipedia.org/wiki/PSGI>`_ đều có kiến trúc middleware.
Xitrum dựa trên `Netty <http://netty.io/>`_ nên đều có handlers. 
Bạn có thể tạo thêm handler và cấu hình chúng các kênh pipeline của hander
You can create additional handlers and customize the channel pipeline. Việc 
làm này, bạn có thể tối ưu hiệu suất server cho một số use case cụ thể.


Chương này trình bày về:

* Kiến trúc của Netty handler
* Handlers cung cấp bởi Xitrum và thứ tự mặc định
* Cách tạo mới và cấu hình một handler

Kiến trúc của Netty handler
---------------------------

Với mỗi kết nối, sẽ có một kênh pipeline để handle dữ liệu IO.
Mỗi kênh pipeline là một chuối cac handler. Có 2 kiểu handler.

* Inbound: request từ client -> server
* Outbound: response từ server -> client

Hãy đọc thêm tài liệu về `ChannelPipeline <http://netty.io/4.0/api/io/netty/channel/ChannelPipeline.html>`_
để biết thêm thông tin.

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

Tùy chỉnh handler
-----------------

Khi khởi động server Xitrum, bạn có thể truyền vào
`ChannelInitializer <http://netty.io/4.0/api/io/netty/channel/ChannelInitializer.html>`_:

::

  import xitrum.Server

  object Boot {
    def main(args: Array[String]) {
      Server.start(myChannelInitializer)
    }
  }

Với server HTTTPS, Xitrum sẽ tự động thêm SSL handler vào trước pipeline.
Bạn có thể tái sử dụng các Xitrum handler trong pipeline.

Xitrum handler mặc định
-----------------------

Xem `xitrum.handler.DefaultHttpChannelInitializer <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/handler/DefaultHttpChannelInitializer.scala>`_.

Sharable handlers (một instances được sử dụng chung bởi nhiều kết nối) được đặt trong
object ``DefaultHttpChannelInitializer`` ở trên do đó chúng có thể được chọn bởi ứng dụng
muốn sử dụng pipeline tùy chỉnh. Những ứng dụng có thể chỉ muốn có một tập hợp con của các
handler mặc định.

Ví dụ, khi ứng dụng sử dụng dispatcher của chính nó (khong phải là routing/dispatcher của Xitrum) và chỉ cần tính năng xử lý tệp tĩnh nhanh của Xitrum, có thể chỉ cần sử dụng các
handler:

Inbound:

* ``HttpRequestDecoder``
* ``PublicFileServer``
* Its own dispatcher

Outbound:

* ``HttpResponseEncoder``
* ``ChunkedWriteHandler``
* ``XSendFile``