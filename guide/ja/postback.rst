ポストバック
============

Webアプリケーションには主に以下の2つのユースケースが考えられます。

* 機械向けのサーバー機能: スマートフォンや他のWebサイトのためのWebサービスとしてRESTfulなAPIを作成する必要があるケース

* 人間向けのサーバー機能: インタラクティブなWebページを作成する必要があるケース

WebフレームワークとしてXitrumはこれら2つのユースケースを簡単に解決することを目指しています。
1つ目のユースケースには、:doc:`RESTful actions </restful>` を適用することで対応し、
2つ目のユースケースには、Ajaxフォームポストバックを適用することで対応します。
ポストバックのアイデアについては以下のリンク（英語）を参照することを推奨します。

* http://en.wikipedia.org/wiki/Postback
* http://nitrogenproject.com/doc/tutorial.html

Xitrumのポストバック機能は `Nitrogen <http://nitrogenproject.com/>`_ を参考にしています。

レイアウト
----------

AppAction.scala

::

  import xitrum.Action
  import xitrum.view.DocType

  trait AppAction extends Action {
    override def layout = DocType.html5(
      <html>
        <head>
          {antiCsrfMeta}
          {xitrumCss}
          {jsDefaults}
          <title>Welcome to Xitrum</title>
        </head>
        <body>
          {renderedView}
          {jsForView}
        </body>
      </html>
    )
  }

フォーム
--------

Articles.scala

::

  import xitrum.annotation.{GET, POST, First}
  import xitrum.validator._

  @GET("articles/:id")
  class ArticlesShow extends AppAction {
    def execute() {
      val id      = param("id")
      val article = Article.find(id)
      respondInlineView(
        <h1>{article.title}</h1>
        <div>{article.body}</div>
      )
    }
  }

  @First  // Force this route to be matched before "show"
  @GET("articles/new")
  class ArticlesNew extends AppAction {
    def execute() {
      respondInlineView(
        <form data-postback="submit" action={url[ArticlesCreate]}>
          <label>Title</label>
          <input type="text" name="title" class="required" /><br />

          <label>Body</label>
          <textarea name="body" class="required"></textarea><br />

          <input type="submit" value="Save" />
        </form>
      )
    }
  }

  @POST("articles")
  class ArticlesCreate extends AppAction {
    def execute() {
      val title   = param("title")
      val body    = param("body")
      val article = Article.save(title, body)

      flash("Article has been saved.")
      jsRedirectTo(show, "id" -> article.id)
    }
  }

``submit`` イベントがJavaScript上で実行された時、フォームの内容は ``ArticlesCreate`` へポストバックされます。
``<form>`` の ``action`` 属性は暗号化され、暗号化されたURLはCSRF対策トークンとして機能します。


formエレメント以外への適用
--------------------------

ポストバックはform以外のHTMLエレメントにも適用することができます。

リンク要素への適用例:

::

  <a href="#" data-postback="click" action={postbackUrl[LogoutAction]}>Logout</a>

リンク要素をクリックした場合LogoutActionへポストバックが行われます。

コンファームダイアログ
----------------------

コンファームダイアログを表する場合:

::

  <a href="#" data-postback="click"
              action={postbackUrl[LogoutAction]}
              data-confirm="Do you want to logout?">Logout</a>

"キャンセル"がクリックされた場合、ポストバックの送信は行われません。

パラメーターの追加
--------------------

formエレメントに対して  ``<input type="hidden"...`` を追加することで追加パラメーターをポストバックリクエストに付与することができます。

formエレメント以外に対しては、以下のように指定します:

::

  <a href="#"
     data-postback="click"
     action={postbackUrl[ArticlesDestroy]("id" -> item.id)}
     data-extra="_method=delete"
     data-confirm={"Do you want to delete %s?".format(item.name)}>Delete</a>

または以下のように別のエレメントに指定することも可能です:

::

  <form id="myform" data-postback="submit" action={postbackUrl[SiteSearch]}>
    Search:
    <input type="text" name="keyword" />

    <a class="pagination"
       href="#"
       data-postback="click"
       data-extra="#myform"
       action={postbackUrl[SiteSearch]("page" -> page)}>{page}</a>
  </form>

``#myform`` はJQueryのセレクタ形式で追加パラメーターを含むエレメントを指定します。

ローディングイメージの表示
----------------------------

以下の様なローディングイメージをAjax通信中に表示する場合、

.. Use ajax_loading.png for PDF (make latexpdf) because it can't include animation GIF

.. image:: ../img/ajax_loading.gif

テンプレート内で、``jsDefault`` (これは `xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_ をインクルードするための関数です) の後に次の1行を追加します。

::

  xitrum.ajaxLoadingImg = 'path/to/your/image';
