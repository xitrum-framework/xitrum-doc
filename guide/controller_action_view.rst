Controller, action, and view
============================

What do you create web applications for? There are 2 main use cases:

* To serve machines: you need to create RESTful APIs for smartphones, web services
  for other web sites.
* To serve human users: you need to create interactive web pages.

As a web framework, Xitrum aims to support you to solve these use cases easily.
In Xitrum, there are 2 kinds of actions: :doc:`RESTful actions </restful>` and
:doc:`postback actions </postback>`.

Normally, you write view directly in its action.

::

  import xitrum.Controller

  class MyController extends Controller {
    def index = GET {
      val s = "World"  // Will be automatically escaped

      respondInlineView(
        <html>
          <body>
            <p>Hello <em>{s}</em>!</p>
          </body>
        </html>
      )
    }
  }

Of course you can refactor the view into a separate Scala file.

There are methods for responding things other than views:

* ``respondText("hello")``: responds a string without layout
* ``respondHtml("<html>...</html>")``: same as above, with content type set to "text/html"
* ``respondJson(List(1, 2, 3))``: converts Scala object to JSON object then responds
* ``respondJs("myFunction([1, 2, 3])")``
* ``respondJsonP(List(1, 2, 3), "myFunction")``: combination of the above two
* ``respondJsonText("[1, 2, 3]")``
* ``respondJsonPText("[1, 2, 3]", "myFunction")``
* ``respondBinary``: responds an array of bytes
* ``respondFile``: sends a file directly from disk, very fast
  because `zero-copy <http://www.ibm.com/developerworks/library/j-zerocopy/>`_
  (aka send-file) is used
* ``respondWebSocket``: responds a WebSocket text frame
* ``respondEventSource("data", "event")``

Layout
------

When you respond a view with ``respondView`` or ``respondInlineView``, Xitrum
renders it to a String, and sets the String to ``renderedView`` variable. Xitrum
then calls ``layout`` method of the current controller, finally Xitrum responds
the result of this method to the browser.

By default ``layout`` method just returns ``renderedView`` itself. If you want
to decorate your view with something, override this method. If you include
``renderedView`` in the method, the view will be included as part of your layout.

The point is ``layout`` is called after your action's view, and whatever returned
is what responded to the browser. This mechanism is simple and straight forward.
No magic. For convenience, you may think that there's no layout in Xitrum at all.
There's just the ``layout`` method and you do whatever you want with it.

Typically, you create a parent class which has a common layout for many views:

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
          <title>Welcome to Xitrum</title>
        </head>
        <body>
          {renderedView}
          {jsForView}
        </body>
      </html>
    )
  }

``xitrumCSS`` includes the default CSS for Xitrum. You may remove it if you
don't like.
``jsDefaults`` includes jQuery, jQuery Validate plugin etc.
should be put at layout's <head>.
``jsForView`` contains JS fragments added by ``jsAddToView``,
should be put at layout's bottom.

MyController.scala

::

  import xitrum.Controller

  class MyController extends AppController {
    def index = GET {
      val s = "World"
      respondInlineView(<p>Hello <em>{s}</em>!</p>)
    }
  }

You can pass the layout directly to ``respondInlineView``:

::

  val specialLayout = () =>
    <html>
      <body>
        {respondedView}
      </body>
    </html>

  val s = "World"
  respondInlineView(<p>Hello <em>{s}</em>!</p>, specialLayout _)

Scalate
-------

For small views you can use Scala XML for convenience, but for big views you
should use `Scalate <http://scalate.fusesource.org/>`_ templates.

scr/main/scala/quickstart/controller/AppController.scala:

::

  package quickstart.controller

  import xitrum.Controller

  trait AppController extends Controller {
    override def layout = renderViewNoLayout(classOf[AppAction])
  }

scr/main/scala/quickstart/action/MyController.scala:

::

  package quickstart.controller

  class MyController extends AppController {
    def index = GET {
      respondView()
    }

    def hello(what: String) = "Hello %s".format(what)
  }

scr/main/scalate/quickstart/controller/AppController.jade:

::

  !!! 5
  html
    head
      != antiCSRFMeta
      != xitrumCSS
      != jsDefaults
      title Welcome to Xitrum

    body
      != respondedView
      != jsForView

scr/main/scalate/quickstart/controller/MyController/index.jade:

::

  - import quickstart.controller.MyController

  a(href={currentAction.url}) Path to current action
  p= currentController.asInstanceOf[MyController].hello("World")

In templates you can use all methods of the class `xitrum.Controller <https://github.com/ngocdaothanh/xitrum/blob/master/src/main/scala/xitrum/Controller.scala>`_,
like ``xitrumCSS``. Also, you can use utility methods provided by Scalate like ``unescape``.
See the `Scalate doc <http://scalate.fusesource.org/documentation/index.html>`_.
Note that these methods are not available for Mustache templates (see the next
section).

If you want to have exactly instance of the current controller, cast ``currentController`` to
the controller you wish.

The default Scalate template type is `Jade <http://scalate.fusesource.org/documentation/jade.html>`_.
You can also use `Mustache <http://scalate.fusesource.org/documentation/mustache.html>`_,
`Scaml <http://scalate.fusesource.org/documentation/scaml-reference.html>`_, or
`Ssp <http://scalate.fusesource.org/documentation/ssp-reference.html>`_.
To config the default template type, see xitrum.conf file in the config directory
of your Xitrum application.

You can override the default template type by passing "jade", "mustache", "scamal",
or "ssp" to `respondView`.

::

  respondView(Map("type" ->"mustache"))

Mustache
~~~~~~~~

Must read:

* `Mustache syntax <http://mustache.github.com/mustache.5.html>`_
* `Scalate implementation <http://scalate.fusesource.org/documentation/mustache.html>`_

You can't do some things with Mustache like with Jade, because Mustache syntax
is stricter.

To pass things from action to Mustache template, you must use ``at``:

Action:

::

  at("name") = "Jack"
  at("xitrumCSS") = xitrumCSS

Mustache template:

::

  My name is {{name}}
  {{xitrumCSS}}

Note that you can't use the below keys for ``at`` map to pass things to Scalate
template, because they're already used:

* "context": for Sclate utility object, which contains methods like ``unescape``
* "helper": for the current controller object

Controller object
-----------------

From a controller, to refer to an action of another controller, use controller
object like this:

::

  import xitrum.Controller

  object LoginController extends LoginController
  class LoginController extends Controller {
    def login = GET("login") {...}

    def doLogin = POST("login") {
      ...
      // After login success
      redirectTo(AdminController.index)  // <-- HERE
    }
  }

  object AdminController extends AdminController
  class AdminController extends Controller {
    def index = GET("admin") {
      ...
      // Check if the user has not logged in, redirect him to the login page
      redirectTo(LoginController.login)  // <-- HERE
    }
  }

In short, you create controller object and call action methods on it.

Caveat
~~~~~~

From controller class, do not import everything in controller object like this:

::

  object LoginController extends LoginController
  class LoginController extends Controller {
    import LoginController._
    ...
  }

Doing that will cause many strange runtime error in the Xitrum framework, like this:

::

  java.lang.NullPointerException: null
    at xitrum.scope.request.RequestEnv.request(RequestEnv.scala:58) ~[xitrum_2.9.2.jar:1.9.8]
    at xitrum.scope.request.ExtEnv$class.cookies(ExtEnv.scala:26) ~[xitrum_2.9.2.jar:1.9.8]
    ...
