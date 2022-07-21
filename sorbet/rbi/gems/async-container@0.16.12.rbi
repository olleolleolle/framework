# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `async-container` gem.
# Please instead update this file by running `bin/tapioca gem async-container`.

module Async
  class << self
    def logger; end
  end
end

module Async::Container
  class << self
    # Determins the best container class based on the underlying Ruby implementation.
    # Some platforms, including JRuby, don't support fork. Applications which just want a reasonable default can use this method.
    def best_container_class; end

    # Whether the underlying process supports fork.
    #
    # @return [Boolean]
    def fork?; end

    # Create an instance of the best container class.
    def new(*arguments, **options); end

    # The processor count which may be used for the default number of container threads/processes. You can override the value provided by the system by specifying the `ASYNC_CONTAINER_PROCESSOR_COUNT` environment variable.
    def processor_count(env = T.unsafe(nil)); end
  end
end

# An environment variable key to override {.processor_count}.
Async::Container::ASYNC_CONTAINER_PROCESSOR_COUNT = T.let(T.unsafe(nil), String)

# Provides a basic multi-thread/multi-process uni-directional communication channel.
class Async::Container::Channel
  # Initialize the channel using a pipe.
  #
  # @return [Channel] a new instance of Channel
  def initialize; end

  # Close both ends of the pipe.
  def close; end

  # Close the input end of the pipe.
  def close_read; end

  # Close the output end of the pipe.
  def close_write; end

  # The input end of the pipe.
  def in; end

  # The output end of the pipe.
  def out; end

  # Receive an object from the pipe.
  # Internally, prefers to receive newline formatted JSON, otherwise returns a hash table with a single key `:line` which contains the line of data that could not be parsed as JSON.
  def receive; end
end

# Manages the life-cycle of one or more containers in order to support a persistent system.
# e.g. a web server, job server or some other long running system.
class Async::Container::Controller
  # Initialize the controller.
  #
  # @return [Controller] a new instance of Controller
  def initialize(notify: T.unsafe(nil)); end

  # The current container being managed by the controller.
  def container; end

  # Create a container for the controller.
  # Can be overridden by a sub-class.
  def create_container; end

  # Reload the existing container. Children instances will be reloaded using `SIGHUP`.
  def reload; end

  # Restart the container. A new container is created, and if successful, any old container is terminated gracefully.
  def restart; end

  # Enter the controller run loop, trapping `SIGINT` and `SIGTERM`.
  def run; end

  # Whether the controller has a running container.
  #
  # @return [Boolean]
  def running?; end

  # Spawn container instances into the given container.
  # Should be overridden by a sub-class.
  def setup(container); end

  # Start the container unless it's already running.
  def start; end

  # The state of the controller.
  def state_string; end

  # Stop the container if it's running.
  def stop(graceful = T.unsafe(nil)); end

  # A human readable representation of the controller.
  def to_s; end

  # Trap the specified signal.
  def trap(signal, &block); end

  # Wait for the underlying container to start.
  def wait; end
end

Async::Container::Controller::SIGHUP = T.let(T.unsafe(nil), Integer)
Async::Container::Controller::SIGINT = T.let(T.unsafe(nil), Integer)
Async::Container::Controller::SIGTERM = T.let(T.unsafe(nil), Integer)
Async::Container::Controller::SIGUSR1 = T.let(T.unsafe(nil), Integer)
Async::Container::Controller::SIGUSR2 = T.let(T.unsafe(nil), Integer)
class Async::Container::Error < ::StandardError; end

# A multi-process container which uses {Process.fork}.
class Async::Container::Forked < ::Async::Container::Generic
  # Start a named child process and execute the provided block in it.
  def start(name, &block); end

  class << self
    # Indicates that this is a multi-process container.
    #
    # @return [Boolean]
    def multiprocess?; end
  end
end

# A base class for implementing containers.
class Async::Container::Generic
  # @return [Generic] a new instance of Generic
  def initialize(**options); end

  # Look up a child process by key.
  # A key could be a symbol, a file path, or something else which the child instance represents.
  def [](key); end

  # @deprecated Please use {spawn} or {run} instead.
  def async(**options, &block); end

  # Whether any failures have occurred within the container.
  #
  # @return [Boolean]
  def failed?; end

  # Whether a child instance exists for the given key.
  #
  # @return [Boolean]
  def key?(key); end

  # Mark the container's keyed instance which ensures that it won't be discarded.
  #
  # @return [Boolean]
  def mark?(key); end

  # Reload the container's keyed instances.
  def reload; end

  # Run multiple instances of the same block in the container.
  def run(count: T.unsafe(nil), **options, &block); end

  # Whether the container has running children instances.
  #
  # @return [Boolean]
  def running?; end

  # Sleep until some state change occurs.
  def sleep(duration = T.unsafe(nil)); end

  # Spawn a child instance into the container.
  def spawn(name: T.unsafe(nil), restart: T.unsafe(nil), key: T.unsafe(nil), &block); end

  # Returns the value of attribute state.
  def state; end

  # Statistics relating to the behavior of children instances.
  def statistics; end

  # Returns true if all children instances have the specified status flag set.
  # e.g. `:ready`.
  # This state is updated by the process readiness protocol mechanism. See {Notify::Client} for more details.
  #
  # @return [Boolean]
  def status?(flag); end

  # Stop the children instances.
  def stop(timeout = T.unsafe(nil)); end

  # A human readable representation of the container.
  def to_s; end

  # Wait until all spawned tasks are completed.
  def wait; end

  # Wait until all the children instances have indicated that they are ready.
  def wait_until_ready; end

  protected

  # Clear the child (value) as running.
  def delete(key, child); end

  # Register the child (value) as running.
  def insert(key, child); end

  private

  def fiber(&block); end

  class << self
    def run(*arguments, **options, &block); end
  end
end

Async::Container::Generic::UNNAMED = T.let(T.unsafe(nil), String)

# Manages a group of running processes.
class Async::Container::Group
  # Initialize an empty group.
  #
  # @return [Group] a new instance of Group
  def initialize; end

  # Whether the group contains any running processes.
  #
  # @return [Boolean]
  def any?; end

  # Whether the group is empty.
  #
  # @return [Boolean]
  def empty?; end

  # Interrupt all running processes.
  # This resumes the controlling fiber with an instance of {Interrupt}.
  def interrupt; end

  # Returns the value of attribute running.
  def running; end

  # Whether the group contains any running processes.
  #
  # @return [Boolean]
  def running?; end

  # Sleep for at most the specified duration until some state change occurs.
  def sleep(duration); end

  # Stop all child processes using {#terminate}.
  def stop(timeout = T.unsafe(nil)); end

  # Terminate all running processes.
  # This resumes the controlling fiber with an instance of {Terminate}.
  def terminate; end

  # Begin any outstanding queued processes and wait for them indefinitely.
  def wait; end

  # Wait for a message in the specified {Channel}.
  def wait_for(channel); end

  protected

  def resume; end
  def suspend; end
  def wait_for_children(duration = T.unsafe(nil)); end
  def yield; end
end

class Async::Container::Hangup < ::SignalException
  # @return [Hangup] a new instance of Hangup
  def initialize; end
end

Async::Container::Hangup::SIGHUP = T.let(T.unsafe(nil), Integer)

# Provides a hybrid multi-process multi-thread container.
class Async::Container::Hybrid < ::Async::Container::Forked
  # Run multiple instances of the same block in the container.
  def run(count: T.unsafe(nil), forks: T.unsafe(nil), threads: T.unsafe(nil), **options, &block); end
end

Async::Container::Interrupt = Interrupt

# Tracks a key/value pair such that unmarked keys can be identified and cleaned up.
# This helps implement persistent processes that start up child processes per directory or configuration file. If those directories and/or configuration files are removed, the child process can then be cleaned up automatically, because those key/value pairs will not be marked when reloading the container.
class Async::Container::Keyed
  # @return [Keyed] a new instance of Keyed
  def initialize(key, value); end

  # Clear the instance. This is normally done before reloading a container.
  def clear!; end

  # The key. Normally a symbol or a file-system path.
  def key; end

  # Mark the instance. This will indiciate that the value is still in use/active.
  def mark!; end

  # Has the instance been marked?
  #
  # @return [Boolean]
  def marked?; end

  # Stop the instance if it was not marked.
  #
  # @return [Boolean]
  def stop?; end

  # The value. Normally a child instance of some sort.
  def value; end
end

# Handles the details of several process readiness protocols.
module Async::Container::Notify
  class << self
    # Select the best available notification client.
    # We cache the client on a per-process basis. Because that's the relevant scope for process readiness protocols.
    def open!; end
  end
end

class Async::Container::Notify::Client
  # Notify the parent controller of an error condition.
  def error!(text, **message); end

  # Notify the parent controller that the child has become ready, with a brief status message.
  def ready!(**message); end

  # Notify the parent controller that the child is reloading.
  def reloading!(**message); end

  # Notify the parent controller that the child is restarting.
  def restarting!(**message); end

  # Notify the parent controller of a status change.
  def status!(text); end

  # Notify the parent controller that the child is stopping.
  def stopping!(**message); end
end

# Implements a general process readiness protocol with output to the local console.
class Async::Container::Notify::Console < ::Async::Container::Notify::Client
  # Initialize the notification client.
  #
  # @return [Console] a new instance of Console
  def initialize(logger); end

  # Send an error message to the console.
  def error!(text, **message); end

  # Send a message to the console.
  def send(level: T.unsafe(nil), **message); end

  class << self
    # Open a notification client attached to the current console.
    def open!(logger = T.unsafe(nil)); end
  end
end

# Implements a process readiness protocol using an inherited pipe file descriptor.
class Async::Container::Notify::Pipe < ::Async::Container::Notify::Client
  # Initialize the notification client.
  #
  # @return [Pipe] a new instance of Pipe
  def initialize(io); end

  # Inserts or duplicates the environment given an argument array.
  # Sets or clears it in a way that is suitable for {::Process.spawn}.
  def before_spawn(arguments, options); end

  # Formats the message using JSON and sends it to the parent controller.
  # This is suitable for use with {Channel}.
  def send(**message); end

  private

  def environment_for(arguments); end

  class << self
    # Open a notification client attached to the current {NOTIFY_PIPE} if possible.
    def open!(environment = T.unsafe(nil)); end
  end
end

# The environment variable key which contains the pipe file descriptor.
Async::Container::Notify::Pipe::NOTIFY_PIPE = T.let(T.unsafe(nil), String)

# Implements the systemd NOTIFY_SOCKET process readiness protocol.
# See <https://www.freedesktop.org/software/systemd/man/sd_notify.html> for more details of the underlying protocol.
class Async::Container::Notify::Socket < ::Async::Container::Notify::Client
  # Initialize the notification client.
  #
  # @return [Socket] a new instance of Socket
  def initialize(path); end

  # Dump a message in the format requied by `sd_notify`.
  def dump(message); end

  # Send the specified error.
  # `sd_notify` requires an `errno` key, which defaults to `-1` to indicate a generic error.
  def error!(text, **message); end

  # Send the given message.
  def send(**message); end

  class << self
    # Open a notification client attached to the current {NOTIFY_SOCKET} if possible.
    def open!(environment = T.unsafe(nil)); end
  end
end

# The maximum allowed size of the UDP message.
Async::Container::Notify::Socket::MAXIMUM_MESSAGE_SIZE = T.let(T.unsafe(nil), Integer)

# The name of the environment variable which contains the path to the notification socket.
Async::Container::Notify::Socket::NOTIFY_SOCKET = T.let(T.unsafe(nil), String)

# Represents a running child process from the point of view of the parent container.
class Async::Container::Process < ::Async::Container::Channel
  # Initialize the process.
  #
  # @return [Process] a new instance of Process
  def initialize(name: T.unsafe(nil)); end

  # Invoke {#terminate!} and then {#wait} for the child process to exit.
  def close; end

  # Send `SIGINT` to the child process.
  def interrupt!; end

  # The name of the process.
  def name; end

  # Set the name of the process.
  # Invokes {::Process.setproctitle} if invoked in the child process.
  def name=(value); end

  # Send `SIGTERM` to the child process.
  def terminate!; end

  # A human readable representation of the process.
  def to_s; end

  # Wait for the child process to exit.
  def wait; end

  class << self
    # Fork a child process appropriate for a container.
    def fork(**options); end
  end
end

# Represents a running child process from the point of view of the child process.
class Async::Container::Process::Instance < ::Async::Container::Notify::Pipe
  # @return [Instance] a new instance of Instance
  def initialize(io); end

  # Replace the current child process with a different one. Forwards arguments and options to {::Process.exec}.
  # This method replaces the child process with the new executable, thus this method never returns.
  def exec(*arguments, ready: T.unsafe(nil), **options); end

  # The name of the process.
  def name; end

  # Set the process title to the specified value.
  def name=(value); end

  class << self
    # Wrap an instance around the {Process} instance from within the forked child.
    def for(process); end
  end
end

# Represents the error which occured when a container failed to start up correctly.
class Async::Container::SetupError < ::Async::Container::Error
  # @return [SetupError] a new instance of SetupError
  def initialize(container); end

  # The container that failed.
  def container; end
end

# Tracks various statistics relating to child instances in a container.
class Async::Container::Statistics
  # @return [Statistics] a new instance of Statistics
  def initialize; end

  # Append another statistics instance into this one.
  def <<(other); end

  # Whether there have been any failures.
  #
  # @return [Boolean]
  def failed?; end

  # Increment the number of failures by 1.
  def failure!; end

  # How many child instances have failed.
  def failures; end

  # Increment the number of restarts by 1.
  def restart!; end

  # How many child instances have been restarted.
  def restarts; end

  # Increment the number of spawns by 1.
  def spawn!; end

  # How many child instances have been spawned.
  def spawns; end
end

# Similar to {Interrupt}, but represents `SIGTERM`.
class Async::Container::Terminate < ::SignalException
  # @return [Terminate] a new instance of Terminate
  def initialize; end
end

Async::Container::Terminate::SIGTERM = T.let(T.unsafe(nil), Integer)

# Represents a running child thread from the point of view of the parent container.
class Async::Container::Thread < ::Async::Container::Channel
  # Initialize the thread.
  #
  # @return [Thread] a new instance of Thread
  def initialize(name: T.unsafe(nil)); end

  # Invoke {#terminate!} and then {#wait} for the child thread to exit.
  def close; end

  # Raise {Interrupt} in the child thread.
  def interrupt!; end

  # Get the name of the thread.
  def name; end

  # Set the name of the thread.
  def name=(value); end

  # Raise {Terminate} in the child thread.
  def terminate!; end

  # A human readable representation of the thread.
  def to_s; end

  # Wait for the thread to exit and return he exit status.
  def wait; end

  protected

  # Invoked by the @waiter thread to indicate the outcome of the child thread.
  def finished(error = T.unsafe(nil)); end

  class << self
    def fork(**options); end
  end
end

# Used to propagate the exit status of a child process invoked by {Instance#exec}.
class Async::Container::Thread::Exit < ::Exception
  # Initialize the exit status.
  #
  # @return [Exit] a new instance of Exit
  def initialize(status); end

  # The process exit status if it was an error.
  def error; end

  # The process exit status.
  def status; end
end

# Represents a running child thread from the point of view of the child thread.
class Async::Container::Thread::Instance < ::Async::Container::Notify::Pipe
  # @return [Instance] a new instance of Instance
  def initialize(io); end

  # Execute a child process using {::Process.spawn}. In order to simulate {::Process.exec}, an {Exit} instance is raised to propagage exit status.
  # This creates the illusion that this method does not return (normally).
  def exec(*arguments, ready: T.unsafe(nil), **options); end

  # Get the name of the thread.
  def name; end

  # Set the name of the thread.
  def name=(value); end

  class << self
    # Wrap an instance around the {Thread} instance from within the threaded child.
    def for(thread); end
  end
end

# A pseudo exit-status wrapper.
class Async::Container::Thread::Status
  # Initialise the status.
  #
  # @return [Status] a new instance of Status
  def initialize(error = T.unsafe(nil)); end

  # Whether the status represents a successful outcome.
  #
  # @return [Boolean]
  def success?; end

  # A human readable representation of the status.
  def to_s; end
end

# A multi-thread container which uses {Thread.fork}.
class Async::Container::Threaded < ::Async::Container::Generic
  # Start a named child thread and execute the provided block in it.
  def start(name, &block); end

  class << self
    # Indicates that this is not a multi-process container.
    #
    # @return [Boolean]
    def multiprocess?; end
  end
end

Async::VERSION = T.let(T.unsafe(nil), String)
