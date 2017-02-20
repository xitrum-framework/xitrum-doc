Các tập tin tĩnh
================

Phục vụ các tập tin tĩnh trên ổ đĩa
------------------------------------

Thư mục của dự án:

::

  config
  public
    favicon.ico
    robots.txt
    404.html
    500.html
    img
      myimage.png
    css
      mystyle.css
    js
      myscript.js
  src
  build.sbt

Xitrum tự động phục vụ các tập tin tĩnh trong thư mực ``public``.
URLs đến các tập tin này:

::

  /img/myimage.png
  /css/mystyle.css
  /css/mystyle.min.css

Để dẫn đến chúng thì:

::

  <img src={publicUrl("img/myimage.png")} />

Để phục vụ các tập tin bình thường trong môi trường phát triển cũng như bản rút gọn của nó trong
môi trường sản phẩm (là mystyle.css và mystyle.min.css như trên) thì:

::

  <img src={publicUrl("css", "mystyle.css", "mystyle.min.css")} />

Để gửi các tập tin tĩnh trên ổ đĩa từ action, sử dụng hàm ``respondFile``.

::

  respondFile("/absolute/path")
  respondFile("path/relative/to/the/current/working/directory")

Để tối ưu hóa tốc độ phục vụ các tập tin tĩnh, bạn có thể bỏ qua các tập tin không
cần thiết với bộ lọc regex. Nếu request url không khớp với pathRegex, Xitrum
sẽ respond lỗi 404 cho request đó.

Xem ``pathRegex`` trong ``config/xitrum.conf``.

index.html fallback
-------------------

Nếu không có route (không có action) cho URL ``/foo/bar`` (hoặc
``/foo/bar/``), Xitrum sẽ tìm các tập tin tĩnh ``public/foo/bar/index.html`` (nằm
trong thư mục ``public``). Nếu tìm thấy tập tin, Xitrum sẽ respond nó về cho phía
client.

404 và 500
----------

404.html và 500.html trong thư mục ``public`` được sử dụng khi không có route
nào phù hợp hoặc có một lỗi trong quá trình thực thi. Nếu bạn muốn tự kiểm soát
lỗi thì:

::

  import xitrum.Action
  import xitrum.annotation.{Error404, Error500}

  @Error404
  class My404ErrorHandlerAction extends Action {
    def execute() {
      if (isAjax)
        jsRespond("alert(" + jsEscape("Not Found") + ")")
      else
        renderInlineView("Not Found")
    }
  }

  @Error500
  class My500ErrorHandlerAction extends Action {
    def execute() {
      if (isAjax)
        jsRespond("alert(" + jsEscape("Internal Server Error") + ")")
      else
        renderInlineView("Internal Server Error")
    }
  }

Response status được đặt thành 404 hoặc 500 trước khi action được thực thi, vì
vậy bạn không cần phải đặt chúng một các thủ công.

Cung cấp các tập tin tài nguyên trong classpath với WebJars convention
----------------------------------------------------------------------

WebJars
~~~~~~~

`WebJars <http://www.webjars.org/>`_ cung cấp rất nhiều các thư viện web mà bạn
có thể sử dụng trong project.

Ví dụ, nếu bạn muốn sử dụng `Underscore.js <http://underscorejs.org/>`_, hãy khai
báo trong tập tin ``build.sbt`` của project như sau:

::

  libraryDependencies += "org.webjars" % "underscorejs" % "1.6.0-3"

Sau đó trong tập tin giao diện .jade:

::

  script(src={webJarsUrl("underscorejs/1.6.0", "underscore.js", "underscore-min.js")})

Xitrum sẽ tự động sử dụng ``underscore.js`` cho môi trường phát triển và
``underscore-min.js`` cho môi trường sản phẩm.

Kết quả như sau:

::

  /webjars/underscorejs/1.6.0/underscore.js?XOKgP8_KIpqz9yUqZ1aVzw

Nếu bạn muốn sử dụng cũng một tập tin trong cả 2 môi trường:

::

  script(src={webJarsUrl("underscorejs/1.6.0/underscore.js")})

Khi thư viện này phụ thuộc vào thư viện kia, SBT sẽ tự động tải các thư viện
liên quan về. Nếu thấy SBT không tải đúng phiên bản (có thể xác nhận bằng cách
chạy lệnh ``sbt xitrum-package`` rồi xem các tập tin trong thư mục ``target/xitrum/lib``
được tạo ra), bạn có thể ép SBT dùng đúng phiên bản bạn muốn bằng ``dependencyOverrides``
Ví dụ nếu bạn thấy SBT chọn thư viện jQuery phiên bản 2.x, mà bạn lại muốn
dùng phiên bản 1.x để có thể hỗ trợ Internet Explorer 6, 7, hoặc 8, thì có
thể khai báo như sau:

::

  dependencyOverrides += "org.webjars" % "jquery" % "1.11.3"

Lưu resource file trong tập tin .jar với WebJars convention
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu bạn là nhà phát triển thư viện và muốn phục vụ tập tin myimage.png từ trong thư
viện của bạn, vốn đã là một tập tin .jar trong classpath, sau đó lưu myimage.png trong tập tin
.jar với `WebJars <http://www.webjars.org/>`_ convention, ví dụ:

::

  META-INF/resources/webjars/mylib/1.0/myimage.png

Để cung cấp tập tin:

::

  <img src={webJarsUrl("mylib/1.0/myimage.png")} />

Trong cả môi trường, đường dẫn URL sẽ là:

::

  /webjars/mylib/1.0/myimage.png?xyz123

Respond một tập tin trong classpath
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để respond một tập tin trong một classpath element (một tập tin .jar hoặc một thư
mục), kể cả khi tập tin không được lưu với `WebJars <http://www.webjars.org/>`_
convention:

::

  respondResource("path/relative/to/the/classpath/element")

Ex:

::

  respondResource("akka/actor/Actor.class")
  respondResource("META-INF/resources/webjars/underscorejs/1.6.0/underscore.js")
  respondResource("META-INF/resources/webjars/underscorejs/1.6.0/underscore-min.js")

Cache ở phía client với ETag và max-age
---------------------------------------

Xitrum tự động thêm `Etag <http://en.wikipedia.org/wiki/HTTP_ETag>`_ cho các tập tin
tĩnh trên đĩa và classpath.

ETags sử dụng cho các tập tin nhỏ như mã MD5 của file content. Chúng sẽ được cache
để sử dụng sau. Key của cache entry là ``(file path, modified time)``. Bởi vì
modified time ở các server khác nhau thì khác nhau, nên mỗi web server trong
một cluster (nhóm) sẽ có riêng local ETag cache.

Với các tập tin lớn, chỉ khi sửa đổi tập tin mới sử dụng Etag. Có vẻ không thực sự
hoàn hảo bởi không thể đồng nhất các tập tin trên các server khác nhau vì chúng có
nhiều ETag khác nhau, nhưng nó vẫn tốt hơn là không sử dụng ETag.

``publicUrl`` và ``webJarsUrl`` tự động thêm ETag vào URL khi chúng được generate. Ví dụ:

::

  webJarsUrl("jquery/2.1.1/jquery.min.js")
  => /webjars/jquery/2.1.1/jquery.min.js?0CHJg71ucpG0OlzB-y6-mQ

Xitrum cũng đặt ``max-age`` và ``Exprires`` header thành 
`one year <https://developers.google.com/speed/docs/best-practices/caching>`_. Bạn không 
cần lo lắng rằng trình duyệt không chọn tập tin mới nhất khi bạn sửa đổi. Bởi vì khi một tập tin 
trên ổ đĩa được sửa, thuộc tính ``modified time`` của tập tin đó sẽ thay đổi, do đó URL tạo 
ra bởi ``publicUrl`` và ``webJarUrl`` cũng thay đổi theo. ETag cache của tập tin cũng sẽ thay 
đổi bởi cache key thay đổi.

GZIP
----

Xitrum thực hiện việc nén GZIP tự động. Thuộc tính ``Content-Type`` tại header sẽ cho biết 
định dạng của respond là ``text/html`` hay ``xml/application`` v.v.

Xitrum luôn tự động nén GZIP với các tập tin tĩnh, nhưng định dạng responses được tùy biến, để 
tối ưu hóa, Xitrum chỉ thực hiện GZIP với các response lớn hơn 1KB.

Cache ở phía Server
-------------------

Để hạn chế load tập tin từ đĩa, Xitrum cache các tập tin tĩnh nhỏ trong bộ nhớ với quy tắc LRU (Lần cuối 
sử dụng xa nhất). Xem ``small_static_file_size_in_kb`` và ``max_cached_small_static_files``
trong ``config/xitrum.conf``.
