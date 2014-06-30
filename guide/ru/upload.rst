Загрузка файлов
===============

Смотри так же раздел :doc:`обработка запросов </scopes>`.

В вашей форме загрузки файла не забывайте устанавливать ``enctype`` в ``multipart/form-data``.

MyUpload.scalate:

::

  form(method="post" action={url[MyUpload]} enctype="multipart/form-data")
    != antiCsrfInput

    label Please select a file:
    input(type="file" name="myFile")

    button(type="submit") Upload

В контроллере ``MyUpload``:

::

  import io.netty.handler.codec.http.multipart.FileUpload

  val myFile = param[FileUpload]("myFile")

``myFile`` это экземпляр `FileUpload <http://netty.io/4.0/api/io/netty/handler/codec/http/multipart/FileUpload.html>`_.
Используйте его методы для получения имени файла, перемещения в директорию и пр.

Маленькие файлы (менее 16 Кб) сохраняются в памяти. Большие файлы сохраняются
в директорию для временных файлов (смотри конфигурацию ``xitrum.request.tmpUploadDir`` в xitrum.conf), 
и будут удалены автоматически после закрытия соединения или когда запрос будет отправлен.

Ajax загрузка файлов
--------------------

Доступно множество JavaScript библиотек осуществляющих Ajax загрузку файлов. 
Они используют скрытый iframe или flash для отправки ``multipart/form-data`` на сервер.
Если вы не уверены какой параметр использует библиотека в форме для отправки файла, смотрите
лог доступа Xitrum.
