Scopes
======

Request
-------

Kinds of params
~~~~~~~~~~~~~~~

There are 2 kinds of request params: textual params and file upload params (binary).

There are 3 kinds of textual params, of type ``scala.collection.mutable.Map[String, List[String]]``:

1. ``uriParams``: params after the ? mark in the URL, example: http://example.com/blah?x=1&y=2
2. ``bodyParams``: params in POST request body
3. ``pathParams``: params embedded in the URL, example: ``GET("articles/:id/:title")``

These params are merged in the above order as ``textParams``
(from 1 to 3, the latter will override the former).

``fileUploadParams`` is of type scala.collection.mutable.Map[String, List[`FileUpload <http://static.netty.io/3.5/api/org/jboss/netty/handler/codec/http/multipart/FileUpload.html>`_]].

Accesing params
~~~~~~~~~~~~~~~

From an action, you can access the above params directly, or you can use
accessor methods.

To access ``textParams``:

* ``param("x")``: returns ``String``, throws exception if x does not exist
* ``params("x")``: returns ``List[String]``, throws exception if x does not exist
* ``paramo("x")``: returns ``Option[String]``
* ``paramso("x")``: returns ``Option[List[String]]``

You can convert text params to other types (Int, Long, Fload, Double) automatically
by using ``param[Int]("x")``, ``params[Int]("x")`` etc. To convert text params to more types,
override `convertText <https://github.com/ngocdaothanh/xitrum/blob/master/src/main/scala/xitrum/scope/request/ParamAccess.scala>`_.

For file upload: ``param[FileUpload]("x")``, ``params[FileUpload]("x")`` etc.
For more details, see :doc:`Upload chapter </upload>`.

RequestVar
~~~~~~~~~~

To pass things around when processing a request (e.g. from action to view or layout)
in the typesafe way, you should use RequestVar.

RVar.scala

::

  import xitrum.RequestVar

  object RVar {
    object title extends RequestVar[String]
  }

AppController.scala

::

  import xitrum.Controller
  import xitrum.view.DocType

  trait AppController extends Controller {
    override def layout = DocType.html5(
      <html>
        <head>
          {antiCSRFMeta}
          {xitrumCSS}
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

Articles.scala

::

  class Articles extends AppController {
    def show = GET(":id") {
      val (title, body) = ...  // Get from DB
      RVar.title.set(title)
      respondInlineView(body)
    }
  }

Cookie
------

Inside an action, you can use ``cookies``. It is a subclass of Java's `TreeSet <http://download.oracle.com/javase/6/docs/api/java/util/TreeSet.html>`_
that contains `Cookie <http://static.netty.io/3.5/api/org/jboss/netty/handler/codec/http/Cookie.html>`_.
It is basically a normal TreeSet with an additional ``get`` method to lookup a cookie:

::

  cookies.get("myCookie") match {
    case None         => ...
    case Some(cookie) => ...
  }

To add a cookie, create an instance of `DefaultCookie <http://static.netty.io/3.5/api/org/jboss/netty/handler/codec/http/DefaultCookie.html>`_
and add it to ``cookies``:

::

  val cookie = new DefaultCookie("myCookie", "String value")
  cookies.add(cookie)

Remember that there's no way for the server to directly delete a cookie on browsers.
Instead, to delete immediately set max age to 0. To delete when the browser closes windows,
set max age to Integer.MIN_VALUE.

::

  cookie.setMaxAge(Integer.MIN_VALUE)

Note that `Internet Explorer does not support "max-age" <http://mrcoles.com/blog/cookies-max-age-vs-expires/>`_,
but Netty detects and outputs either "max-age" or "expires" properly. Don't worry!

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

resetSession
~~~~~~~~~~~~

`One line of code will protect you from session fixation <http://guides.rubyonrails.org/security.html#session-fixation>`_.

Read the link above to know about session fixation. To prevent session fixation
attack, in the action that lets users login, call ``resetSession``.

::

  class LoginController extends Controller {
    def login = GET("login") {
      ...
      resetSession()  // Reset first before doing anything else with the session
      session("userId") = userId
    }
  }

To log users out, also call ``resetSession``.

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
    <a href={urlFor[LoginAction]}>Login</a>

* To delete the session var: ``SVar.username.delete``
* To reset the whole session: ``resetSession``

Session store
~~~~~~~~~~~~~

In config/xitrum.json (`example <https://github.com/ngocdaothanh/xitrum/blob/master/plugin/src/main/resources/xitrum_resources/config/xitrum.json>`_),
you can config the session store:

::

  ...
  "session": {
    // To store sessions on client side: xitrum.scope.session.CookieSessionStore
    // To store sessions on server side: xitrum.scope.session.HazelcastSessionStore
    // "store": "xitrum.scope.session.CookieSessionStore",
    "store": "xitrum.scope.session.HazelcastSessionStore",

    // If you run multiple sites on the same domain, make sure that there's no
    // cookie name conflict between sites
    "cookieName": "_session",

    // Key to encrypt session cookie etc.
    // Do not use the example below! Use your own!
    // If you deploy your application to several instances be sure to use the same key!
    "secureKey": "ajconghoaofuxahoi92chunghiaujivietnamlasdoclapjfltudoil98hanhphucup8"
  }
  ...

If you run a cluster of Xitrum web servers and store sessions on server side,
setup session replication by :doc:`configuring Hazelcast </cluster>`.

The two default session stores are enough for normal cases.
But if you have a special case and want to implement your own session store,
extend
`SessionStore <https://github.com/ngocdaothanh/xitrum/blob/master/src/main/scala/xitrum/scope/session/SessionStore.scala>`_
and implement the two methods.

Then to tell Xitrum to use your session store, set its class name to xitrum.json.

Good read:
`Web Based Session Management - Best practices in managing HTTP-based client sessions <http://www.technicalinfo.net/papers/WebBasedSessionManagement.html>`_.

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
