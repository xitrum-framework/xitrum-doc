파일 업로드
========

:doc:`스코프 </scopes>` 를 참고하세요.

업로드 폼에서 ``enctype`` 를 ``multipart/form-data`` 으로 설정합니다.

MyUpload.scalate:

::

  form(method="post" action={url[MyUpload]} enctype="multipart/form-data")
    != antiCsrfInput

    label Please select a file:
    input(type="file" name="myFile")

    button(type="submit") Upload

``MyUpload`` 액션:

::

  import io.netty.handler.codec.http.multipart.FileUpload

  val myFile = param[FileUpload]("myFile")

``myFile``  `FileUpload <http://netty.io/4.0/api/io/netty/handler/codec/http/multipart/FileUpload.html>`_
의 인스턴스 입니다. 이 메소드를 이용하여 파일이름을 가져오거나, 파일의 이동등을 할 수 있습니다.

작은파일 (16KB이하)는 메모리에 저장됩니다. 대용량 파일은 시스템의 임시 폴더에 저장됩니다(혹은 xitrum.conf에 정의된 ``xitrum.request.tmpUploadDir``).
그리고 나서, 커넥션이 닫히거나 응답이 전송되면 자동으로 삭제됩니다.

Ajax 스타일 업로드
--------------
 
많은 자바스크립트 라이브러리는 Ajax 스타일의 업로드를 지원합니다. 숨겨진 iframe이나 플래시등으로 ``multipart/form-data`` 를 서버로 전송합니다.
폼의 요청 파라미터가 전송될때, 어떤 라이브러리를 사용했는지는 Xitrum 억세스 로그를 확인하면 알 수 있습니다.
