ActionActor
===========

If you want your action to be an actor, instead of extending xitrum.Action,
extend xitrum.Action.Actor:

::

  import scala.concurrent.duration._

  import xitrum.ActionActor
  import xitrum.annotation.GET

  @GET("actor")
  class ActionActorDemo extends ActionActor with AppAction {
    def execute() {
      // See Akka doc about scheduler
      import context.dispatcher
      context.system.scheduler.scheduleOnce(3 seconds, self, System.currentTimeMillis)

      // See Akka doc about "become"
      context.become {
        case pastTime =>
          respondInlineView("It's " + pastTime + " Unix ms 3s ago.")
      }
    }
  }

An actor will be created when there's request. It will be stopped when the
connection is closed or when the response has been sent by respondText,
respondView etc. methods. For chunked response, it is not stopped right away.
It is stopped when the last chunk is sent.
