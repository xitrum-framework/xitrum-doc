Development flow with SBT, Eclipse, and JRebel
==============================================

This chapter assumes that you have installed Eclipse and
`Scala plugin for Eclipse <http://www.scala-ide.org/>`_.

Create a new Xitrum project
---------------------------

Create a new project as described at the :doc:`tutorial </tutorial>`.
These should be `ignored <https://github.com/ngocdaothanh/xitrum-new/blob/master/.gitignore>`_:

::

  .*
  log
  project
  routes.sclasner
  target

If you're using git you can clone the
`xitrum-new <https://github.com/ngocdaothanh/xitrum-new>`_
project from GitHub:

::

  git clone –depth 1 https://github.com/ngocdaothanh/xitrum-new.git my_project
  cd my_project
  rm -rf .git
  git init
  git add -f .gitignore

Alternatively:

::

  wget -O xitrum-new.zip https://github.com/ngocdaothanh/xitrum-new/zipball/master

Or:

::

  curl -L -o xitrum-new.zip https://github.com/ngocdaothanh/xitrum-new/zipball/master

Install Eclipse plugin for SBT
------------------------------

Install Eclipse plugin for SBT by adding to file ``~/.sbt/plugins/build.sbt``
the content as described at https://github.com/typesafehub/sbteclipse.

To create the ``.project`` file for Eclipse from ``build.sbt``, from the
project directory, run:

::

  sbt/sbt eclipse

Now open Eclipse, and import the project.

Install JRebel
--------------

In development mode, you start the web server with ``sbt/sbt run``. Normally, when
you change your source code, you have to press CTRL+C to stop, then run ``sbt/sbt run``
again. This may take tens of seconds everytime.

With `JRebel <http://www.zeroturnaround.com/jrebel/>`_ you can avoid that. JRebel
provides free license for Scala developers!

Install:

1. Apply for a `free license for Scala <http://sales.zeroturnaround.com/>`_
2. Download and install JRebel using the license above
3. Add ``-noverify -javaagent:/path/to/jrebel/jrebel.jar`` to the ``sbt/sbt`` command line

Example:

::

  java -noverify -javaagent:"$HOME/opt/jrebel/jrebel.jar" \
       -Xmx1024m -XX:MaxPermSize=128m -Dsbt.boot.directory="$HOME/.sbt/boot" \
       -jar `dirname $0`/sbt-launch.jar "$@"

Use JRebel
----------

1. Run ``sbt/sbt run``
2. In Eclipse, try editing a Scala file, then save it

The Scala plugin for Eclipse will automatically recompile the file. And JRebel will
automatically reload the generated .class files.

If you use a plain text editor, not Eclipse:

1. Run ``sbt/sbt run``
2. Run ``sbt/sbt ~compile`` in another console to compile in continuous/incremental mode
3. In the editor, try editing a Scala file, and save

The ``sbt/sbt ~compile`` process will automatically recompile the file, and JRebel will
automatically reload the generated .class files.

``sbt/sbt ~compile`` works fine in bash and sh shell. In zsh shell, you need to use
``sbt/sbt "~compile"``, or it will complain "no such user or named directory: compile".

Currently routes are not reloaded, even in development mode with JRebel.
