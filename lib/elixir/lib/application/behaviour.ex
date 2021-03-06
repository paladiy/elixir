defmodule Application.Behaviour do
  @moduledoc """
  Default callbacks for applications.

  In Erlang/OTP, an application is a component that can be started
  and stopped as a unit, and which can be reused in other systems.

  The first step in creating an application is to define an application specification.
  For example, if your application is named `:my_app`, an app specification
  should exist at `ebin/my_app.app`. This file is usually defined by
  build tools like Mix.

  With the app specification in hand, we must define
  application module callbacks that control how to start and stop
  instances of the application. This module is about defining such callbacks.

  There are two callbacks which must be implemented:

  1. `start(type, args)` - must return `{ :ok, pid }` or
     `{ :ok, pid, state }`, where `pid` is the process identifier
     of the supervisor tree root and `state` is application defined 
     state information;

  2. `stop(state)` - receives the `state` returned by `start` and should
     do any necessary clean up. Notice that shutting down the supervisor
     is automatically handled by the VM;

  When using this module, it tags the module behaviour as
  `:application` and provides a default `stop/1` callback. The `start/2` callback
  still needs to be implemented by the user.

  You can learn more about the `:application` module, the application
  specification and the application module callbacks from these sources:

  * http://www.erlang.org/doc/man/application.html
  * http://www.erlang.org/doc/design_principles/applications.html
  * http://learnyousomeerlang.com/building-otp-applications

  ## Example

      defmodule MyApp do
        use Application.Behaviour

        def start(_type, args) do
          MyApp.Sup.start_link(args)
        end
      end

  """

  # Starts the given application and all of its dependencies that
  # have not been started yet recursively.
  #
  # ## Supported types
  #
  # When starting an application, a type can be given:
  #
  # * `:permanent` - If a permanent application terminates, all other
  #    applications and the runtime system are also terminated;
  # * `:transient` - If a transient application terminates with reason
  #    `:normal`, this is reported but no other applications are terminated.
  #    If a transient application terminates abnormally, all other
  #    applications and the runtime system are also terminated;
  # * `:temporary` -  If a temporary application terminates, this is reported
  #    but no other applications are terminated.
  #
  # The type only applies to the application being started. Its dependencies
  # are all started with default type (which is :temporary).
  #
  # Note that transient mode is of little practical use, since when a
  # supervision tree terminates, the reason is set to shutdown, not normal.
  #
  # ## Examples
  #
  #     Application.Behaviour.start(:my_app)
  #
  @doc false
  def start(app, type \\ :temporary) do
    case :application.start(app, type) do
      { :error, { :not_started, dep } } ->
        case start(dep) do
          :ok   -> start(app, type)
          other -> other
        end
      { :error, { :already_started, _ } } ->
        :ok
      other ->
        other
    end
  end

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour :application

      @doc false
      def stop(_state) do
        :ok
      end

      defoverridable [stop: 1]
    end
  end
end
