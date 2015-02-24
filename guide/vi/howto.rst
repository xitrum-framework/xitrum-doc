HOWTO
=====

Chương này bao gồm một số thủ thuật nhỏ.

Basic authentication
--------------------

Bạn có thể bảo vệ toàn bộ site hoặc chỉ action nào đó với
`basic authentication <http://en.wikipedia.org/wiki/Basic_access_authentication>`_.

Ghi nhớ rằng Xitrum không hỗ trợ
`digest authentication <http://en.wikipedia.org/wiki/Digest_access_authentication>`_
vì nó cung cấp một cái nhìn sai về bảo mật. Từ đó làm cho digest authentication dễ bị tấn công man-in-the-middle.
Để bảo mật tốt hơn, bạn nên sử dụng HTTPS
(không cần sử dụng Apache hay Nginx như reverse proxy chỉ cần sử dụng HTTPS).

Cấu hình basic authentication cho toàn bộ site
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trong tệp ``config/xitrum.conf``:

::

  "basicAuth": {
    "realm":    "xitrum",
    "username": "xitrum",
    "password": "xitrum"
  }

Thêm basic authentication vào một action
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  import xitrum.Action

  class MyAction extends Action {
    beforeFilter {
      basicAuth("Realm") { (username, password) =>
        username == "username" && password == "password"
      }
    }
  }

Load các tệp config
-------------------

Tệp JSON
~~~~~~~~

JSON thuận tiện cho việc sử dụng làm các tệp cấu hình với cấu trúc lồng nhau.

Lưu tệp cấu hình của bạn trong thư mục "config". Thư mục này được đặt trong
classpath ở chế độ phát triển bởi build.sbt và trong chế độ sản phẩm bởi  script/runner (và script/runner.bat).

myconfig.json:

::

  {
    "username": "God",
    "password": "Does God need a password?",
    "children": ["Adam", "Eva"]
  }

Load:

::

  import xitrum.util.Loader

  case class MyConfig(username: String, password: String, children: Seq[String])
  val myConfig = Loader.jsonFromClasspath[MyConfig]("myconfig.json")

Ghi chú:

* Các Key and string phải được dùng dấu nháy kép ``"``.
* Hiện tại, bạn không thể viết comment trong tệp JSON

Tệp properties
~~~~~~~~~~~~~~

Bạn cũng có thể các tệp property, nhưng bạn nên sử dụng JSON. Tệp property không phải typesafe, không hỗ trợ UTF-8 và các cấu trúc lồng nhau v.v.

myconfig.properties:

::

  username = God
  password = Does God need a password?
  children = Adam, Eva

Load:

::

  import xitrum.util.Loader

  // Here you get an instance of java.util.Properties
  val properties = Loader.propertiesFromClasspath("myconfig.properties")

Typesafe tệp cấu hình
~~~~~~~~~~~~~~~~~~~~~

Xitrum cũng bao gồm Akka mà Akka sử dụng
`thư viện cấu hình <https://github.com/typesafehub/config>`_ tạp bởi
`company called Typesafe <http://typesafe.com/company>`_.
Chúng có thẻ tốt hơn tải các tệp cấu hình.

myconfig.conf:

::

  username = God
  password = Does God need a password?
  children = ["Adam", "Eva"]

Load:

::

  import com.typesafe.config.{Config, ConfigFactory}

  val config   = ConfigFactory.load("myconfig.conf")
  val username = config.getString("username")
  val password = config.getString("password")
  val children = config.getStringList("children")

Serialize và deserialize
-------------------------

Để serialize thành ``Array[Byte]``:

::

  import xitrum.util.SeriDeseri
  val bytes = SeriDeseri.toBytes("my serializable object")

Để deserialize các byte ngược trở lại:

::

  val option = SeriDeseri.fromBytes[MyType](bytes)  // Option[MyType]

Nếu bạn muốn lưu tệp:

::

  import xitrum.util.Loader
  Loader.bytesToFile(bytes, "myObject.bin")

To load from the file:

::

  val bytes = Loader.bytesFromFile("myObject.bin")

Mã hóa dữ liệu
--------------

Để mã hóa dữ liệu mà bạn không cần giải mã sau đó (mã hóa một chiều), bạn có thể
sử dụng MD5 hoặc những thuật toán tương tư.

Nếu bạn muốn giải mã về sau, bạn có thể sử dụng tiện ích mà Xitrum cung cấp:

::

  import xitrum.util.Secure

  // Array[Byte]
  val encrypted = Secure.encrypt("my data".getBytes)

  // Option[Array[Byte]]
  val decrypted = Secure.decrypt(encrypted)

Bạn có thể sử dụng ``xitrum.util.UrlSafeBase64`` để mã hóa và giải mã các dữ liệu nhị phân
thanh chuỗi thông thường (nhúng vào HTML để response chẳng hạn).

::

  // String that can be included in URL, cookie etc.
  val string = UrlSafeBase64.noPaddingEncode(encrypted)

  // Option[Array[Byte]]
  val encrypted2 = UrlSafeBase64.autoPaddingDecode(string)

Nếu bạn có thể phối hợp các quá trình bên trên trong một bước:

::

  import xitrum.util.SeriDeseri

  val mySerializableObject = new MySerializableClass

  // String
  val encrypted = SeriDeseri.toSecureUrlSafeBase64(mySerializableObject)

  // Option[MySerializableClass]
  val decrypted = SeriDeseri.fromSecureUrlSafeBase64[MySerializableClass](encrypted)

``SeriDeseri`` sử dụng `Twitter Chill <https://github.com/twitter/chill>`_
để serialize và deserialize. Dữ liệu của bạn phải là serializable.

Bạn có thể chỉ rõ khóa (key) để mã hóa.

::

  val encrypted = Secure.encrypt("my data".getBytes, "my key")
  val decrypted = Secure.decrypt(encrypted, "my key")

::

  val encrypted = SeriDeseri.toSecureUrlSafeBase64(mySerializableObject, "my key")
  val decrypted = SeriDeseri.fromSecureUrlSafeBase64[MySerializableClass](encrypted, "my key")

Nếu bạn không chỉ rõ key nào, ``secureKey`` trong tệp ``xitrum.conf`` trong thư mục config
sẽ được sử dụng.

Nhiều site với cùng một tên miền
--------------------------------

Neus bạn muốn sử dụng một reverse proxy như Nginx để chạy nhiều site khác nhau
tại cùng một tên miền:

::

  http://example.com/site1/...
  http://example.com/site2/...

Bạn có thể cấu hình baseUrl trong ``config/xitrum.conf``.

Trong mã JS, để có chính xác URL cho Ajax request, sử dụng ``withBaseUrl``
trong `xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_.

::

  # If the current site's baseUrl is "site1", the result will be:
  # /site1/path/to/my/action
  xitrum.withBaseUrl('/path/to/my/action')

Convert Markdown sang HTML
--------------------------

Nếu bạn đã configured project để sử dụng :doc:`Scalate template engine </template_engines>`,
Bạn chỉ cần phải làm như sau:

::

  import org.fusesource.scalamd.Markdown
  val html = Markdown("input")

Ngoài ra, bạn cần thêm thành phần phụ thuộc này vào tệp ``build.sbt`` của project.

::

  libraryDependencies += "org.fusesource.scalamd" %% "scalamd" % "1.6"

Theo dõi sự thay đổi của tệp
----------------------------

Bạn cần thiết lập callback cho
`StandardWatchEventKinds <http://docs.oracle.com/javase/7/docs/api/java/nio/file/StandardWatchEventKinds.html>`_
trên tệp và thư mục.

::

  import java.nio.file.Paths
  import xitrum.util.FileMonitor

  val target = Paths.get("absolute_path_or_path_relative_to_application_directory").toAbsolutePath
  FileMonitor.monitor(FileMonitor.MODIFY, target, { path =>
    // Do some callback with path
    println(s"File modified: $path")

    // And stop monitoring if necessary
    FileMonitor.unmonitor(FileMonitor.MODIFY, target)
  })

``FileMonitor`` sử dụng
`Schwatcher <https://github.com/lloydmeta/schwatcher>`_.

Thư mục tạm thời
----------------

Mặc định Xitrum project (xem ``tmpDir`` trong xitrum.conf) sử dụng thư mục ``tmp``
trong thư mục hoạt động hiện thời để lưu các tệp .scala generate bởi Scalate, các tệp
lớn sẽ được tải lên v.v.

Để lấy đường dẫn đến thư mục đó:

::

  xitrum.Config.xitrum.tmpDir.getAbsolutePath

Tạo một tệp mới hoặc thư mục trong thư mục đó:

::

  val file = new java.io.File(xitrum.Config.xitrum.tmpDir, "myfile")

  val dir = new java.io.File(xitrum.Config.xitrum.tmpDir, "mydir")
  dir.mkdirs()

Stream video
------------

Có nhiều cách để steam video. Cách đơn giản nhất:

* Cung cấp tệp video .mp4 theo từng đoạn, người dùng có thể xem video trong khi
  tải về.
* Và sử dụng một HTTP server như Xitrum có hỗ trợ
  `range requests <http://en.wikipedia.org/wiki/Byte_serving>`_, để người dùng có
  thể nhảy đến đoạn phim mà chưa được tải về.

Bạn có thể sử dụng `MP4Box <http://gpac.wp.mines-telecom.fr/mp4box/>`_ để  tải nội dụng
của tệp phim một các xen kẽ mỗi 0.5 giây:

::

  MP4Box -inter 500 movie.mp4
