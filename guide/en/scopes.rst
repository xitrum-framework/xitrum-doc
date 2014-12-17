Scopes
======

Request
-------

Kinds of params
~~~~~~~~~~~~~~~

There are 2 kinds of request params: textual params and file upload params (binary).

There are 3 kinds of textual params, of type ``scala.collection.mutable.Map[String, Seq[String]]``:

1. ``queryParams``: params after the ? mark in the URL, example: http://example.com/blah?x=1&y=2
2. ``bodyTextParams``: params in POST request body
3. ``pathParams``: params embedded in the URL, example: ``GET("articles/:id/:title")``

These params are merged in the above order as ``textParams``
(from 1 to 3, the latter will override the former).

``bodyFileParams`` is of type scala.collection.mutable.Map[String, Seq[`FileUpload <http://netty.io/4.0/api/io/netty/handler/codec/http/multipart/FileUpload.html>`_]].

Accesing params
~~~~~~~~~~~~~~~

From an action, you can access the above params directly, or you can use
accessor methods.

To access ``textParams``:

* ``param("x")``: returns ``String``, throws exception if x does not exist
* ``paramo("x")``: returns ``Option[String]``
* ``params("x")``: returns ``Seq[String]``, Seq.empty if x does not exist

You can convert text params to other types (Int, Long, Fload, Double) automatically
by using ``param[Int]("x")``, ``params[Int]("x")`` etc. To convert text params to more types,
override `convertTextParam <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala-2.11/xitrum/scope/request/ParamAccess.scala>`_.

For file upload: ``param[FileUpload]("x")``, ``params[FileUpload]("x")`` etc.
For more details, see :doc:`Upload chapter </upload>`.

"at"
~~~~

To pass things around when processing a request (e.g. from action to view or layout)
you can use ``at``. ``at`` type is ``scala.collection.mutable.HashMap[String, Any]``.
If you know Rails, you'll see ``at`` is a clone of ``@`` of Rails.

Articles.scala

::

  @GET("articles/:id")
  class ArticlesShow extends AppAction {
    def execute() {
      val (title, body) = ...  // Get from DB
      at("title") = title
      respondInlineView(body)
    }
  }

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
          <title>{if (at.isDefinedAt("title")) "My Site - " + at("title") else "My Site"}</title>
        </head>
        <body>
          {renderedView}
          {jsForView}
        </body>
      </html>
    )
  }

"atJson"
~~~~~~~~

``atJson`` helper method automatically converts ``at("key")`` to JSON.
It is useful when you need to pass model from Scala to JavaScript.

``atJson("key")`` is equivalent to ``xitrum.util.SeriDeseri.toJson(at("key"))``:

Action.scala

::

  case class User(login: String, name: String)

  ...

  def execute() {
    at("user") = User("admin", "Admin")
    respondView()
  }

Action.ssp

::

  <script type="text/javascript">
    var user = ${atJson("user")};
    alert(user.login);
    alert(user.name);
  </script>

RequestVar
~~~~~~~~~~

``at`` in the above section is not typesafe because you can set anything to the
map. To be more typesafe, you should use RequestVar, which is a wrapper arround
``at``.

RVar.scala

::

  import xitrum.RequestVar

  object RVar {
    object title extends RequestVar[String]
  }

Articles.scala

::

  @GET("articles/:id")
  class ArticlesShow extends AppAction {
    def execute() {
      val (title, body) = ...  // Get from DB
      RVar.title.set(title)
      respondInlineView(body)
    }
  }

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
          <title>{if (RVar.title.isDefined) "My Site - " + RVar.title.get else "My Site"}</title>
        </head>
        <body>
          {renderedView}
          {jsForView}
        </body>
      </html>
    )
  }

Cookie
------

Read Wikipedia about `cookies <http://en.wikipedia.org/wiki/HTTP_cookie>`_.

Inside an action, use ``requestCookies``, a ``Map[String, String]``, to read cookies sent by browser.

::

  requestCookies.get("myCookie") match {
    case None         => ...
    case Some(string) => ...
  }

To send cookie to browser, create an instance of `DefaultCookie <http://netty.io/4.0/api/io/netty/handler/codec/http/DefaultCookie.html>`_
and append it to ``responseCookies``, an ``ArrayBuffer`` that contains `Cookie <http://netty.io/4.0/api/io/netty/handler/codec/http/Cookie.html>`_.

::

  val cookie = new DefaultCookie("name", "value")
  cookie.setHttpOnly(true)  // true: JavaScript cannot access this cookie
  responseCookies.append(cookie)

If you don't set cookie's path by calling ``cookie.setPath(cookiePath)``, its
path will be set to the site's root path (``xitrum.Config.withBaseUrl("/")``).
This avoids accidental duplicate cookies.

To delete a cookie sent by browser, send a cookie with the same name and set
its max age to 0. The browser will expire it immediately. To tell browser to
delete cookie when the browser closes windows, set max age to ``Long.MinValue``:

::

  cookie.setMaxAge(Long.MinValue)

`Internet Explorer does not support "max-age" <http://mrcoles.com/blog/cookies-max-age-vs-expires/>`_,
but Netty detects and outputs either "max-age" or "expires" properly. Don't worry!

Browsers will not send cookie attributes back to the server. They will
`only send the cookie name-value pairs <http://en.wikipedia.org/wiki/HTTP_cookie#Cookie_attributes>`_.

If you want to sign your cookie value to prevent user from tampering, use
``xitrum.util.SeriDeseri.toSecureUrlSafeBase64`` and ``xitrum.util.SeriDeseri.fromSecureUrlSafeBase64``.
For more information, see :doc:`How to encrypt data </howto>`.

Allowed characters in cookie
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You cannot use `arbitrary characters in cookie <http://stackoverflow.com/questions/1969232/allowed-characters-in-cookies>`_.
For example, if you need to use UTF-8 characters, you need to encode them.
You can use ``xitrum.utill.UrlSafeBase64`` or ``xitrum.util.SeriDeseri``.

Write cookie example:

::

  import io.netty.util.CharsetUtil
  import xitrum.util.UrlSafeBase64

  val value   = """{"identity":"example@gmail.com","first_name":"Alexander"}"""
  val encoded = UrlSafeBase64.noPaddingEncode(value.getBytes(CharsetUtil.UTF_8))
  val cookie  = new DefaultCookie("profile", encoded)
  responseCookies.append(cookie)

Read cookie example:

::

  requestCookies.get("profile").foreach { encoded =>
    UrlSafeBase64.autoPaddingDecode(encoded).foreach { bytes =>
      val value = new String(bytes, CharsetUtil.UTF_8)
      println("profile: " + value)
    }
  }

Session
-------

Session storing, restoring, encrypting etc. is done automatically by Xitrum.
You don't have to mess with them.

In your actions, you can use ``session``. It is an instance of
``scala.collection.mutable.Map[String, Any]``. Things in ``session`` must be
serializable.

For example, to mark that a user has logged in, you can set his username into the
session:

::

  session("userId") = userId

Later, if you want to check if a user has logged in or not, just check if
there's a username in his session:

::

  if (session.isDefinedAt("userId")) println("This user has logged in")

Storing user ID and pull the user from database on each access is usually a good
practice. That way changes to the user are updated on each access (including
changes to user roles/authorizations).

session.clear()
~~~~~~~~~~~~~~~

`One line of code will protect you from session fixation <http://guides.rubyonrails.org/security.html#session-fixation>`_.

Read the link above to know about session fixation. To prevent session fixation
attack, in the action that lets users login, call ``session.clear()``.

::

  @GET("login")
  class LoginAction extends Action {
    def execute() {
      ...
      session.clear()  // Reset first before doing anything else with the session
      session("userId") = userId
    }
  }

To log users out, also call ``session.clear()``.

SessionVar
~~~~~~~~~~

SessionVar, like RequestVar, is a way to make your session more typesafe.

For example, you want save username to session after the user has logged in:

Declare the session var:

::

  import xitrum.SessionVar

  object SVar {
    object username extends SessionVar[String]
  }

After login success:

::

  SVar.username.set(username)

Display the username:

::

  if (SVar.username.isDefined)
    <em>{SVar.username.get}</em>
  else
    <a href={url[LoginAction]}>Login</a>

* To remove the session var: ``SVar.username.remove()``
* To reset the whole session: ``session.clear()``

Session stores
~~~~~~~~~~~~~~

Xitrum provides 3 session stores.
In `config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_
you can config the session store you want:

CookieSessionStore:

::

  # Store sessions on client side
  store = xitrum.scope.session.CookieSessionStore

LruSessionStore:

::

  # Simple in-memory server side session store
  store {
    "xitrum.local.LruSessionStore" {
      maxElems = 10000
    }
  }

If you run multiple servers in a cluster, you can
`use Hazelcast to store cluster-aware sessions <https://github.com/xitrum-framework/xitrum-hazelcast>`_,

Note that when you use CookieSessionStore or Hazelcast, your session data must be
serializable. If you must store unserializable things, use LruSessionStore.
If you use LruSessionStore and still want to run a cluster of multiple servers,
you must use a load balancer that supports sticky sessions.

The three default session stores above are enough for normal cases.
If you have a special case and want to implement your own session store,
extend
`SessionStore <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/scope/session/SessionStore.scala>`_
or
`ServerSessionStore <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/scope/session/ServerSessionStore.scala>`_
and implement the abstract methods.

The config can be in one of the following 2 forms:

::

  store = my.session.StoreClassName

Or:

::

  store {
    "my.session.StoreClassName" {
      option1 = value1
      option2 = value2
    }
  }

Store sessions at client side cookie when you can (serializable and
`smaller than 4KB <http://stackoverflow.com/questions/640938/what-is-the-maximum-size-of-a-web-browsers-cookies-key>`_),
because it's more scalable.
Store sessions at server side (memory or DB) when you must.

Good read:
`Web Based Session Management - Best practices in managing HTTP-based client sessions <http://www.technicalinfo.net/papers/WebBasedSessionManagement.html>`_.

Client side session store vs Server side session store
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are 2 kinds of session stores:

* Client side only
* Client side + server side combination

Client side only:

* Session data is stored in encrypted cookie at client.
* The server doesn't need to store anything.
* When a request comes in, the server will decrypt the data.

Client side + server side combination:

* A session has 2 parts: session ID and session data.
* The server keeps the session store, which is like a lookup table: ID -> data.
* The ID is also stored in encrypted cookie at client.
* When a request comes in, the server will decrypt the ID, and use the ID to
  lookup the data.
* This is like your credit card. Your money is not stored in the credit card,
  only your ID.

In both cases the client must always keep something in the cookie
(encrypted data vs encrypted ID). "Store sessions at server side" only means
storing session data at server side.

object vs. val
--------------

Please use ``object`` instead of ``val``.

**Do not do like this**:

::

  object RVar {
    val title    = new RequestVar[String]
    val category = new RequestVar[String]
  }

  object SVar {
    val username = new SessionVar[String]
    val isAdmin  = new SessionVar[Boolean]
  }

The above code compiles but does not work correctly, because the Vars internally
use class names to do look up. When using ``val``, ``title`` and ``category``
will have the same class name "xitrum.RequestVar". The same for ``username``
and ``isAdmin``.
