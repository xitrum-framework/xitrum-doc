Tải lên tệp
===========

Xem thêm :doc:`Scopes chapter </scopes>`.

Trong form tải lên (upload form), bạn cần đặt ``enctype`` thành ``multipart/form-data``.

MyUpload.scalate:

::

  form(method="post" action={url[MyUpload]} enctype="multipart/form-data")
    != antiCsrfInput

    label Please select a file:
    input(type="file" name="myFile")

    button(type="submit") Upload

Trong ``MyUpload`` action:

::

  import io.netty.handler.codec.http.multipart.FileUpload

  val myFile = param[FileUpload]("myFile")

``myFile`` là một instance của `FileUpload <http://netty.io/4.0/api/io/netty/handler/codec/http/multipart/FileUpload.html>`_.
Sử dụng các method của chúng để lấy tên tệp, di chuyển tệp vào một thư mục v.v.

Các tệp nhỏ (nhỏ hơn 16 KB) sẽ được lưu trong bộ nhớ. Các tệp lớn thường được lưu
trong hệ thống thư mục lưu trữ tạm (hoặc một thư mục xác định bởi ``xitrum.request.tmpUploadDir`` 
trong xitrum.conf), và sẽ được xóa tự động khi đóng kết nối hoặc một respond được 
gửi đi.

Ajax style upload
-----------------

Có rất nhiều thư viện JavaScript hỗ trợ tải lên Ajax style. Chúng sử dụng iframe 
ẩn hoặc Flash để gửi ``multipart/form-data`` ở bên trên đến server.
Nếu bạn không chắc chắn parameter nào của request trong thư viện sử dụng trong form 
để gửi tệp, hãy xem Xitrum access log.
