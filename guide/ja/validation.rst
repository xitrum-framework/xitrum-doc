バリデーション
==============

Xitrumは、クライアントサイドでのバリデーション用に `jQuery Validation plugin <http://bassistance.de/jquery-plugins/jquery-plugin-validation/>`_ を内包し、サーバーサイドにおけるバリデーション用のいくつかのヘルパーを提供します。

デフォルトバリデーター
----------------------

``xitrum.validator`` パッケージには以下の3つのメソッドが含まれます:

::

  check(value): Boolean
  message(name, value): Option[String]
  exception(name, value)

もしバリデーション結果が ``false`` である場合、
``message`` は ``Some(error, message)`` を返却します。
``exception`` メソッドは ``xitrum.exception.InvalidInput(error message)`` をスローします。

バリデーターは何処ででも使用することができます。

Actionで使用する例:

::

  import xitrum.validator.Required

  @POST("articles")
  class CreateArticle {
    def execute() {
      val title = param("tite")
      val body  = param("body")
      Required.exception("Title", title)
      Required.exception("Body",  body)

      // Do with the valid title and body...
    }
  }

``try`` 、 ``catch`` ブロックを使用しない場合において、バリデーションエラーとなると、
xitrumは自動でエラーをキャッチし、クライアントに対してエラーメッセージを送信します。
これはクライアントサイドでバリデーションを正しく書いている場合や、webAPIを作成する場合において便利なやり方と言えます。


Modelで使用する例:

::

  import xitrum.validator.Required

  case class Article(id: Int = 0, title: String = "", body: String = "") {
    def isValid           = Required.check(title)   &&     Required.check(body)
    def validationMessage = Required.message(title) orElse Required.message(body)
  }


デフォルトバリデーターの一覧については　`xitrum.validator パッケージ <https://github.com/xitrum-framework/xitrum/tree/master/src/main/scala/xitrum/validator>`_ を参照してください。

カスタムバリデーターの作成
--------------------------

`xitrum.validator.Validator <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/validator/Validator.scala>`_ を継承し、
``check`` メソッドと、 ``message`` メソッドのみ実装することでカスタムバリデーターとして使用できます。

また、 `Commons Validator <http://commons.apache.org/proper/commons-validator/>`_ を使用することもできます。
