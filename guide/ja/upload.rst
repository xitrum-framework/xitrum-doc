ファイルアップロード
================

:doc:`スコープ </scopes>`についてもご覧ください。

ファイルアップロードformで``enctype``を``multipart/form-data``に設定します。

MyUpload.scalate:

::

  form(method="post" action={url[MyUpload]} enctype="multipart/form-data")
    != antiCsrfInput

    label ファイルを選択してください:
    input(type="file" name="myFile")

    button(type="submit") アップロード

``MyUpload``アクションで:

::

  import io.netty.handler.codec.http.multipart.FileUpload

  val myFile = param[FileUpload]("myFile")

``myFile``が`FileUpload <http://netty.io/4.0/api/io/netty/handler/codec/http/multipart/FileUpload.html>`_
のインスタンスとなります。そのメソッドを使ってファイル名の取得やファイル移動などができます。

小さいファイル (16KB未満)がメモリへ保存されます。大きいファイルがシステムのテンポラリ・ディレクトリ
または xitrum.conf の``xitrum.request.tmpUploadDir``設定ディレクトリへ一時的に保存されます。
コネクション切断やリスポンス送信のあとに削除されませす。

Ajax風ファイルアップロード
----------------------

世の中Ajax風ファイルアップロードJavaScriptライブラリがいっぱいあります。その動作としては
隠しiframeやFlashなどで上記の``multipart/form-data``をサーバー側へ送ります。
ファイルが具体的にどんなパラメータで送信されるかはXitrumアクセスログで確認できます。
