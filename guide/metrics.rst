Metrics
=======

Xitrum collect metrics of your (clusterd) application and publish it as json data.
By Default, Xitrum collect JVM HeapMemory, CPU, and action's execution status from each nodes of cluster.

Collect metrics
---------------

HeapMemory and CPU
~~~~~~~~~~~~~~~~~~

JVM Heap Memory and CPU will be collected as `NodeMetrics <http://doc.akka.io/api/akka/snapshot/index.html#akka.cluster.NodeMetrics>`_ of akka actor system from each node.

HeapMemory:
You can see how much memory is used in JVM from Heap Memory NodeMetrics.

.. image:: metrics_heapmemory.png


CPU:
You can know about how many processor is working, and how much load average is reached from CPU NodeMetrics.

.. image:: metrics_cpu.png


Application Metrics
~~~~~~~~~~~~~~~~~~~

Xitrum includes `Coda Hale Metrics <http://metrics.codahale.com/>`_.
Xitrum measure action's execution status of each nodes as a `Histogram <http://metrics.codahale.com/getting-started/#histograms>`_.
You can know about how many action was executed, and how long it took to complete.

.. image:: metrics_action_count.png

You can also know about latest execution time for specified action.

.. image:: metrics_action_time.png


Collect your customized metrics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to default metrics, you can collect your customized metrics.
``xitrum.Metrics`` is shortcut for ``gauge``, ``counter``, ``meter``, ``timer`` and ``histogram``.
Please read about `Coda Hale Metrics <http://metrics.codahale.com/>`_ and `it's Scala implementation <https://github.com/erikvanoosten/metrics-scala>`_ to know how to use it.

Eexample about timer:

::

  private lazy val myTimer = xitrum.Metrics.timer("myTimer")

  class MyAction extends AppAction {
    def execute() {
      myTimer.time {
        HeavyTask()
      }
    }

    def HeavyTask {
      // something heavy task
    }
  }


Publish metrics
---------------

Xitrum publish latest value of metrics as JSON format with specified interval.
This is a volatile value and not be kept in persistently.

HeapMemory:

::

  {
    "TYPE"      : "heapMemory",
    "SYSTEM"    : akka.actor.Address.system,
    "HOST"      : akka.actor.Address.host,
    "PORT"      : akka.actor.Address.port,
    "HASH"      : akka.actor.Address.hashCode,
    "TIMESTAMP" : akka.cluster.NodeMetrics.timestamp,
    "USED"      : Number as byte,
    "COMMITTED" : Number as byte,
    "MAX"       : Number as byte
  }


CPU:

::

  {
    "TYPE"              : "cpu",
    "SYSTEM"            : akka.actor.Address.system,
    "HOST"              : akka.actor.Address.host,
    "PORT"              : akka.actor.Address.port,
    "HASH"              : akka.actor.Address.hashCode,
    "TIMESTAMP"         : akka.cluster.NodeMetrics.timestamp
    "SYSTEMLOADAVERAGE" : Number,
    "CPUCOMBINED"       : Number,
    "PROCESSORS"        : Number
  }

MetricsRegistry will be parsed with `metrics-json <http://metrics.codahale.com/manual/json/>`_.


Xitrum default viewr
~~~~~~~~~~~~~~~~~~~~

Xitrum provide default metrics viewer at ``/xitrum/metrics/viewer``.
This url show some dynamic glaphs created by `D3.js <http://d3js.org/>`_ like above.


Jconsole viewr
~~~~~~~~~~~~~~

You can see it with feature of `JVM Reporter <http://metrics.codahale.com/getting-started/#reporting-via-jmx>`_.

.. image:: metrics_jconsole.png

Start jmx reporter:

::

  import com.codahale.metrics.JmxReporter

  object Boot {
    def main(args: Array[String]) {
      Server.start()
      JmxReporter.forRegistry(xitrum.Metrics).build().start()
    }
  }

And then from terminal

::

  > jconsole


Display metrics with customized view
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
JSON values will be published at ``xitrum/metrics/channel`` as a SockJS url.
``jsAddMetricsNameSpace`` is a JavaScript snippet for create connection to this endpoint.
Implement your own json handler, and call ``initMetricsChannel`` with your handler.

Create connection to metrics channel:

::

  import xitrum.metrics.MetricsViewer

  class mySubscriber extends MetricsViewer {
    def execute() {
      jsAddMetricsNameSpace("window")
      jsAddToView("""
        function onValue(json){
          console.log(json);
        }
        function onClose(){
          console.log("channel closed");
        }
        window.initMetricsChannel(onValue, onClose);
      """)
      respondView()
    }
  }


Save metrics in persistently
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
If you want to save metrics in persistantly to the database or files,
Implement your customized subscriber.

Subscribe publisher:

::

  import xitrum.metrics.PublisherLookUp

  class mySubscriber extends Actor with PublisherLookUp {
    lookUpPublisher()

    def receive = {
      case _ =>
    }

    override def doWithPublisher(globalPublisher: ActorRef) = {
      context.become {
        case msg @ (first::rest) =>
          // case of clusterd NodeMetrics as Set
          // SaveDB or write to file.

        case nodeMetrics: NodeMetrics =>
          // case of single NodeMetrics
          // SaveDB or write to file.

        case Publish(registryAsJson) =>
          // case of metrics registory
          // SaveDB or write to file.

        case _ =>
      }
    }
  }

