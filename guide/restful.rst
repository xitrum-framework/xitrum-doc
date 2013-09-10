RESTful APIs
============

You can write RESTful APIs for iPhone, Android applications etc. very easily.

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("articles")
  class ArticlesIndex extends Action {
    def execute() {...}
  }
  
  @GET("articles/:id")
  class ArticlesShow extends Action {
    def execute() {...}
  }

The same for POST, PUT, PATCH, DELETE, and OPTIONS.
HEAD is automatically handled by Xitrum as GET.

For HTTP clients that do not support PUT and DELETE (like normal browsers), to
simulate PUT and DELETE, send a POST with _method=put or _method=delete in the
request body.

On web application startup, Xitrum will scan all those annotations, build the
routing table and print it out for you so that you know what APIs your
application has, like this:

::

  [INFO] Routes:
  GET /articles     quickstart.action.ArticlesIndex
  GET /articles/:id quickstart.action.ArticlesShow

Routes are automatically collected in the spirit of JAX-RS
and Rails Engines. You don't have to declare all routes in a single place.
Think of this feature as distributed routes. You can plug an app into another app.
If you have a blog engine, you can package it as a JAR file, then you can put
that JAR file into another app and that app automatically has blog feature!
Routing is also two-way: you can recreate URLs (reverse routing) in a typesafe way.

Route cache
-----------

For better startup speed, routes are cached to file ``routes.cache``.
While developing, routes in .class files in the ``target`` directory are not
cached. If you change library dependencies that contain routes, you may need to
delete ``routes.cache``. This file should not be committed to your project
source code repository.

Route order with first and last
---------------------------------

When you want to route like this:

::

  /articles/:id --> ArticlesShow
  /articles/new --> ArticlesNew

You must make sure the second route be checked first. ``First`` is for this purpose:

::

  import xitrum.annotation.{GET, First}

  @First
  @GET("articles/:id")
  class ArticlesShow extends Action {
    def execute() {...}
  }
  
  @GET("articles/new")
  class ArticlesNew extends Action {
    def execute() {...}
  }

``Last`` is similar.

Regex in route
--------------

Regex can be used in routes to specify requirements:

::

  def show = GET("/articles/:id<[0-9]+>") { ... }

Anti-CSRF
---------

For non-GET requests, Xitrum protects your web application from
`Cross-site request forgery <http://en.wikipedia.org/wiki/CSRF>`_ by default.

When you include ``antiCSRFMeta`` in your layout:

::

  import xitrum.Action
  import xitrum.view.DocType

  trait AppAction extends Action {
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

The ``<head>`` part will include something like this:

::

  <!DOCTYPE html>
  <html>
    <head>
      ...
      <meta name="csrf-token" content="5402330e-9916-40d8-a3f4-16b271d583be" />
      ...
    </head>
    ...
  </html>

The token will be automatically included in all non-GET Ajax requests sent by
jQuery.

antiCSRFInput
-------------

If you manually write form in Scalate template, use ``antiCSRFInput``:

::

  form(method="post" action={url[AdminAddGroup]})
    != antiCSRFInput

    label Group name *
    input.required(type="text" name="name" placeholder="Required")
    br

    label Group description
    input(type="text" name="desc")
    br

    input(type="submit" value="Add")

SkipCSRFCheck
-------------

When you create APIs for machines, e.g. smartphones, you may want to skip this
automatic CSRF check. Add the trait xitrum.SkipCSRFCheck to you action:

::

  import xitrum.{Action, SkipCSRFCheck}
  import xitrum.annotatin.POST

  trait API extends Action with SkipCSRFCheck

  @POST("api/positions")
  class LogPositionAPI extends API {
    def execute() {...}
  }

  @POST("api/todos")
  class CreateTodoAPI extends API {
    def execute() {...}
  }

Read entire request body
------------------------

To get the entire request body, use `request.getContent <http://netty.io/3.6/api/org/jboss/netty/handler/codec/http/HttpRequest.html>`_.
It returns `ChannelBuffer <http://netty.io/3.6/api/org/jboss/netty/buffer/ChannelBuffer.html>`_,
which has ``toString(Charset)`` method.

::

  val body = request.getContent.toString(io.netty.util.CharsetUtil.UTF_8)

Documenting api
---------------

You can document your api with `Swagger <https://developers.helloreverb.com/swagger/>`_ out of the box. First of all you should add @SwaggerDoc annotation on xitrum.Actions that need to be documented. Xitrum will generate `/api-docs.json <https://github.com/wordnik/swagger-core/wiki/API-Declaration>`_ file when app starts. This file can be used with `swagger-ui <https://github.com/wordnik/swagger-ui>`_ to dynamically generate documentation.

Let's see example:

::

  import xitrum.Action
  import xitrum.SkipCSRFCheck
  import xitrum.annotation.GET
  import xitrum.swagger.SwaggerDoc
  import xitrum.swagger.SwaggerParameter
  import xitrum.swagger.SwaggerErrorResponse

  trait API extends Action with SkipCSRFCheck

  @GET("user")
  @SwaggerDoc(
    summary = "Get user by id",
    notes = "Find user in database",
    parameters = Array(
      new SwaggerParameter(name = "id", typename = "int", 
        description = "User id", required = true, allowMultiple = true),
      new SwaggerParameter(name = "respondType", typename = "string", 
        description = "Type of the document, can be {xml, json, jsonp}")),
    errorResponses = Array(
      new SwaggerErrorResponse(code = "404", reason = "User not found"))
  )

  class UserAPI extends API {

    def execute { /*...*/ }

  }

For this API /api-docs.json will look like:

::

  {
    "apiVersion":"1.0",
    "basePath":"/",
    "swaggerVersion":"1.2",
    "resourcePath":"api",
    "apis":[{
      "path":"/api-docs.json",
      "operations":[{
        "httpMethod":"GET",
        "summary":"Swagger api integration",
        "notes":" Use this route in swagger-ui to see the doc ",
        "nickname":"SwaggerDocAction",
        "parameters":[],
        "errorResponses":[]
      }]
    },{
      "path":"/user",
      "operations":[{
        "httpMethod":"GET",
        "summary":"Get user by id",
        "notes":" Find user in database ",
        "nickname":"UserAPI",
        "parameters":[{
          "name":"id",
          "type":"int",
          "dataType":"int",
          "description":"User id",
          "required":true,
          "allowMultiple":true
        },{
          "name":"respondType",
          "type":"string",
          "dataType":"string",
          "description":"Type of the document, can be {xml, json, jsonp}",
          "required":false,
          "allowMultiple":false
        }],
        "errorResponses":[{
          "code":"404",
          "reason":"User not found"
        }]
      }]
    }]
  }

If you want you can open this file with swagger-ui:

.. image:: swagger.png

SwaggerDoc annotation specification:

::

  SwaggerDoc
    |-summary - brief description of the operation
    |-notes - long description of the operation
    |-parameters - parameters of the operation
    |  |-name - parameter name
    |  |-typename - type of the parameter
    |  |-description - description of the parameter
    |  |-required - is parameter required
    |  |-allowMultiple - can pass more then one parameter
    |-errorResponses - errors of the operation
       |-code - error code
       |-reason - description of the error