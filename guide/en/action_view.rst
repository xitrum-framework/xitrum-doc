Action and view
===============

To be flexible, Xitrum provides 3 kinds of actions:
normal ``Action``, ``FutureAction``, and ``ActorAction``.

Normal action
-------------

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("hello")
  class HelloAction extends Action {
    def execute() {
      respondText("Hello")
    }
  }

Because the action will run on directly Netty's IO thread, it should not do blocking
processing that may take a long time, otherwise Netty can't accept new connections
or send response back to clients.

FutureAction
------------

::

  import xitrum.FutureAction
  import xitrum.annotation.GET

  @GET("hello")
  class HelloAction extends FutureAction {
    def execute() {
      respondText("hi")
    }
  }

The action will run on the same thread pool for ``ActorAction`` (see below),
separated from the thread pool of Netty.

Actor action
------------

If you want your action to be an Akka actor, extend ``ActorAction``:

::

  import scala.concurrent.duration._

  import xitrum.ActorAction
  import xitrum.annotation.GET

  @GET("actor")
  class HelloAction extends ActorAction {
    def execute() {
      // See Akka doc about scheduler
      import context.dispatcher
      context.system.scheduler.scheduleOnce(3 seconds, self, System.currentTimeMillis())

      // See Akka doc about "become"
      context.become {
        case pastTime =>
          respondInlineView(s"It's $pastTime Unix ms 3s ago.")
      }
    }
  }

An actor instance will be created when there's request. It will be stopped when the
connection is closed or when the response has been sent by ``respondText``,
``respondView`` etc. methods. For chunked response, it is not stopped right away.
It is stopped when the last chunk is sent.

The actor will run on the thread pool of the Akka actor system named "xitrum".

Respond to client
-----------------

From an action, to respond something to client, use:

* ``respondView``: responds view template file, with or without layout
* ``respondInlineView``: responds embedded template (not separate template file), with or without layout
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
* ``respondEventSource("data", "event")``

Respond template view file
--------------------------

Each action may have an associated `Scalate <http://scalate.fusesource.org/>`_
template view file. Instead of responding directly in the action with the above
methods, you can use a separate view file.

scr/main/scala/mypackage/MyAction.scala:

::

  package mypackage

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("myAction")
  class MyAction extends Action {
    def execute() {
      respondView()
    }

    def hello(what: String) = "Hello %s".format(what)
  }

scr/main/scalate/mypackage/MyAction.jade:

::

  - import mypackage.MyAction

  !!! 5
  html
    head
      != antiCsrfMeta
      != xitrumCss
      != jsDefaults
      title Welcome to Xitrum

    body
      a(href={url}) Path to the current action
      p= currentAction.asInstanceOf[MyAction].hello("World")

      != jsForView

* ``xitrumCss`` includes the default CSS for Xitrum. You may remove it if you
  don't like.xitrum-framework
* ``jsDefaults`` includes jQuery, jQuery Validate plugin etc.
  should be put at layout's <head>.
* ``jsForView`` contains JS fragments added by ``jsAddToView``,
  should be put at layout's bottom.

In templates you can use all methods of the class `xitrum.Action <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/Action.scala>`_.
Also, you can use utility methods provided by Scalate like ``unescape``.
See the `Scalate doc <http://scalate.fusesource.org/documentation/index.html>`_.

The default Scalate template type is `Jade <http://scalate.fusesource.org/documentation/jade.html>`_.
You can also use `Mustache <http://scalate.fusesource.org/documentation/mustache.html>`_,
`Scaml <http://scalate.fusesource.org/documentation/scaml-reference.html>`_, or
`Ssp <http://scalate.fusesource.org/documentation/ssp-reference.html>`_.
To config the default template type, see xitrum.conf file in the config directory
of your Xitrum application.

You can override the default template type by passing "jade", "mustache", "scaml",
or "ssp" to `respondView`.

::

  val options = Map("type" ->"mustache")
  respondView(options)

Type casting currentAction
~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to have exactly instance of the current action, cast ``currentAction`` to
the action you wish.

::

  p= currentAction.asInstanceOf[MyAction].hello("World")

If you have multiple lines like above, you can cast only one time:

::

  - val myAction = currentAction.asInstanceOf[MyAction]; import myAction._

  p= hello("World")
  p= hello("Scala")
  p= hello("Xitrum")

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
  at("xitrumCss") = xitrumCss

Mustache template:

::

  My name is {{name}}
  {{xitrumCss}}

Note that you can't use the below keys for ``at`` map to pass things to Scalate
template, because they're already used:

* "context": for Sclate utility object, which contains methods like ``unescape``
* "helper": for the current action object

CoffeeScript
~~~~~~~~~~~~

You can embed CoffeeScript in Scalate template using
`:coffeescript filter <http://scalate.fusesource.org/documentation/jade-syntax.html#filters>`_:

::

  body
    :coffeescript
      alert "Hello, Coffee!"

Output:

::

  <body>
    <script type='text/javascript'>
      //<![CDATA[
        (function() {
          alert("Hello, Coffee!");
        }).call(this);
      //]]>
    </script>
  </body>

But note that it is `slow <http://groups.google.com/group/xitrum-framework/browse_thread/thread/6667a7608f0dc9c7>`_:

::

  jade+javascript+1thread: 1-2ms for page
  jade+coffesscript+1thread: 40-70ms for page
  jade+javascript+100threads: ~40ms for page
  jade+coffesscript+100threads: 400-700ms for page

You pre-generate CoffeeScript to JavaScript if you need speed.

Layout
------

When you respond a view with ``respondView`` or ``respondInlineView``, Xitrum
renders it to a String, and sets the String to ``renderedView`` variable. Xitrum
then calls ``layout`` method of the current action, finally Xitrum responds
the result of this method to the browser.

By default ``layout`` method just returns ``renderedView`` itself. If you want
to decorate your view with something, override this method. If you include
``renderedView`` in the method, the view will be included as part of your layout.

The point is ``layout`` is called after your action's view, and whatever returned
is what responded to the browser. This mechanism is simple and straight forward.
No magic. For convenience, you may think that there's no layout in Xitrum at all.
There's just the ``layout`` method and you do whatever you want with it.

Typically, you create a parent class which has a common layout for many views:

src/main/scala/mypackage/AppAction.scala

::

  package mypackage
  import xitrum.Action

  trait AppAction extends Action {
    override def layout = renderViewNoLayout[AppAction]()
  }

src/main/scalate/mypackage/AppAction.jade

::

  !!! 5
  html
    head
      != antiCsrfMeta
      != xitrumCss
      != jsDefaults
      title Welcome to Xitrum

    body
      != renderedView
      != jsForView

src/main/scala/mypackage/MyAction.scala

::

  package mypackage
  import xitrum.annotation.GET

  @GET("myAction")
  class MyAction extends AppAction {
    def execute() {
      respondView()
    }

    def hello(what: String) = "Hello %s".format(what)
  }

scr/main/scalate/mypackage/MyAction.jade:

::

  - import mypackage.MyAction

  a(href={url}) Path to the current action
  p= currentAction.asInstanceOf[MyAction].hello("World")

Layout without separate file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Pass layout directly to respondView
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  val specialLayout = () =>
    DocType.html5(
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

  respondView(specialLayout _)

Inline view
-----------

Normally, you write view in a Scalate file. You can also write it directly:

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("myAction")
  class MyAction extends Action {
    def execute() {
      val s = "World"  // Will be automatically HTML-escaped
      respondInlineView(
        <p>Hello <em>{s}</em>!</p>
      )
    }
  }

Render fragment
---------------

Suppose MyAction.jade is at:
scr/main/scalate/mypackage/MyAction.jade

If you want to render the fragment file in the same directory:
scr/main/scalate/mypackage/_MyFragment.jade

::

  renderFragment[MyAction]("MyFragment")

If ``MyAction`` is the current action, you can skip it:

::

  renderFragment("MyFragment")

Respond view of other action
----------------------------

Use the syntax ``respondView[ClassName]()``:

::

  package mypackage

  import xitrum.Action
  import xitrum.annotation.{GET, POST}

  @GET("login")
  class LoginFormAction extends Action {
    def execute() {
      // Respond scr/main/scalate/mypackage/LoginFormAction.jade
      respondView()
    }
  }

  @POST("login")
  class DoLoginAction extends Action {
    def execute() {
      val authenticated = ...
      if (authenticated)
        redirectTo[HomeAction]()
      else
        // Reuse the view of LoginFormAction
        respondView[LoginFormAction]()
    }
  }

One action - multiple views
~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to have multiple views for one:

::

  package mypackage

  import xitrum.Action
  import xitrum.annotation.GET

  // These are non-routed actions, for mapping to view template files:
  // scr/main/scalate/mypackage/HomeAction_NormalUser.jade
  // scr/main/scalate/mypackage/HomeAction_Moderator.jade
  // scr/main/scalate/mypackage/HomeAction_Admin.jade
  trait HomeAction_NormalUser extends Action
  trait HomeAction_Moderator  extends Action
  trait HomeAction_Admin      extends Action

  @GET("")
  class HomeAction extends Action {
    def execute() {
      val userType = ...
      userType match {
        case NormalUser => respondView[HomeAction_NormalUser]()
        case Moderator  => respondView[HomeAction_Moderator]()
        case Admin      => respondView[HomeAction_Admin]()
      }
    }
  }

Using addional non-routed actions like above seems to be tedious, but this way
your program will be typesafe.

You can also use ``String`` to specify template location:

::

  respondView("mypackage/HomeAction_NormalUser")
  respondView("mypackage/HomeAction_Moderator")
  respondView("mypackage/HomeAction_Admin")

Component
---------

You can create reusable view components that can be embedded to multiple views.
In concept, a component is similar to an action:

* But it does not have routes, thus ``execute`` method is not needed.
* It does not "responds" a full response, it just "renders" a view fragment.
  So inside a component, instead of calling ``respondXXX``, please call ``renderXXX``.
* Just like an action, a component can have none, one, or multiple associated view
  templates.

::

  package mypackage

  import xitrum.{FutureAction, Component}
  import xitrum.annotation.GET

  class CompoWithView extends Component {
    def render() = {
      // Render associated view template, e.g. CompoWithView.jade
      // Note that this is renderView, not respondView!
      renderView()
    }
  }

  class CompoWithoutView extends Component {
    def render() = {
      "Hello World"
    }
  }

  @GET("foo/bar")
  class MyAction extends FutureAction {
    def execute() {
      respondView()
    }
  }

MyAction.jade:

::

  - import mypackage._

  != newComponent[CompoWithView]().render()
  != newComponent[CompoWithoutView]().render()
