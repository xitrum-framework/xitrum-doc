テンプレートエンジン
====================

:doc:`renderViewやrenderFragment, respondView <./action_view>` 実行時には
設定ファイルで指定したテンプレートエンジンが使用されます。

テンプレートエンジンの設定
--------------------------

`config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_ において
テンプレートエンジンはその種類に応じて以下ように設定することができます。

::

  template = my.template.EngineClassName

または:

::

  template {
    "my.template.EngineClassName" {
      option1 = value1
      option2 = value2
    }
  }

デフォルトのテンプレートエンジンは `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_ です。

テンプレートエンジンの削除
--------------------------

一般にRESTfulなAPIのみを持つプロジェクトを作成した場合、renderView、renderFragment、あるいはrespondView
は不要となります。このようなケースではテンプレートエンジンを削除することでプロジェクトを軽量化することができます。
その場合 config/xitrum.conf から ``templateEngine`` の設定をコメントアウトします。

テンプレートエンジンの作成
--------------------------

独自のテンプレートエンジンを作成する場合、 `xitrum.view.TemplateEngine <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/view/TemplateEngine.scala>`_ を継承したクラスを作成します。
そして作成したクラスを config/xitrum.conf にて指定します。

参考例: `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_
