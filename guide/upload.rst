Upload
======

See also :doc:`Scopes chapter </scopes>`.

Normal upload
-------------

In your upload form, remember to set ``enctype`` to ``multipart/form-data``.

my_upload.scalate:

::

  form(method="post" action={MyController.myAction.url} enctype="multipart/form-data")
    != antiCSRFInput

    label Please select a file:
    input(type="file" name="my_file")

    button(type="submit") Upload

myAction:

::

  val myFile = param[FileUpload]("my_file")

myFile is an instance of `FileUpload <http://static.netty.io/3.5/api/org/jboss/netty/handler/codec/http/multipart/FileUpload.html>`_.
Use its methods to get file name, move file to a directory etc.

Ajax upload
-----------

See xitrum.view.AjaxUpload.
