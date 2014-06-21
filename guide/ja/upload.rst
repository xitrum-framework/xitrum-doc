ファイルアップロード
====================

:doc:`スコープ </scopes>` についてもご覧ください。

ファイルアップロードformで ``enctype`` を ``multipart/form-data`` に設定します。

MyUpload.scalate:

::

  form(method="post" action={url[MyUpload]} enctype="multipart/form-data")
    != antiCsrfInput

    label ファイルを選択してください:
    input(type="file" name="myFile")

    button(type="submit") アップロード

``MyUpload`` アクション:

::

  import io.netty.handler.codec.http.multipart.FileUpload

  val myFile = param[FileUpload]("myFile")

``myFile`` が `FileUpload <http://netty.io/4.0/api/io/netty/handler/codec/http/multipart/FileUpload.html>`_
のインスタンスとなります。そのメソッドを使ってファイル名の取得やファイル移動などができます。

小さいファイル (16KB未満)はメモリへ保存されます。大きいファイルはシステムのテンポラリ・ディレクトリ
または xitrum.conf の ``xitrum.request.tmpUploadDir`` に設定したディレクトリへ一時的に保存されます。
一時ファイルはコネクション切断やレスポンス送信のあとに削除されます。

Ajax風ファイルアップロード
--------------------------

世の中にはAjax風ファイルアップロードJavaScriptライブラリがいっぱいあります。その動作としては
隠しiframeやFlashなどで上記の ``multipart/form-data`` をサーバー側へ送ります。
ファイルが具体的にどんなパラメータで送信されるかはXitrumアクセスログで確認できます。
