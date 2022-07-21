# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `notiffany` gem.
# Please instead update this file by running `bin/tapioca gem notiffany`.

# TODO: this probably deserves a gem of it's own
module Notiffany
  class << self
    # The notifier handles sending messages to different notifiers. Currently the
    # following libraries are supported:
    #
    # * Ruby GNTP
    # * Growl
    # * Libnotify
    # * rb-notifu
    # * emacs
    # * Terminal Notifier
    # * Terminal Title
    # * Tmux
    #
    # Please see the documentation of each notifier for more information about
    # the requirements
    # and configuration possibilities.
    #
    # Notiffany knows four different notification types:
    #
    # * success
    # * pending
    # * failed
    # * notify
    #
    # The notification type selection is based on the image option that is
    # sent to {#notify}. Each image type has its own notification type, and
    # notifications with custom images goes all sent as type `notify`. The
    # `gntp` notifier is able to register these types
    # at Growl and allows customization of each notification type.
    #
    # Notiffany can be configured to make use of more than one notifier at once.
    def connect(options = T.unsafe(nil)); end
  end
end

class Notiffany::Notifier
  # @return [Notifier] a new instance of Notifier
  def initialize(opts); end

  # Test if notifiers are currently turned on
  #
  # @return [Boolean]
  def active?; end

  def available; end

  # Returns the value of attribute config.
  def config; end

  def disconnect; end

  # Test if the notifications can be enabled based on ENV['GUARD_NOTIFY']
  #
  # @return [Boolean]
  def enabled?; end

  # Show a system notification with all configured notifiers.
  #
  # @option opts
  # @option opts
  # @param message [String] the message to show
  # @param opts [Hash] a customizable set of options
  def notify(message, message_opts = T.unsafe(nil)); end

  # Turn notifications off.
  def turn_off; end

  # Turn notifications on.
  #
  # @option options
  # @param options [Hash] the turn_on options
  def turn_on(options = T.unsafe(nil)); end

  private

  def _activate; end
  def _check_server!; end

  # @return [Boolean]
  def _client?; end

  def _detect_or_add_notifiers; end
  def _env; end

  # @return [Boolean]
  def _notification_wanted?; end

  def _turn_on_notifiers(options); end
end

class Notiffany::Notifier::Base
  # @return [Base] a new instance of Base
  def initialize(opts = T.unsafe(nil)); end

  def _image_path(image); end
  def name; end
  def notify(message, opts = T.unsafe(nil)); end

  # Returns the value of attribute options.
  def options; end

  def title; end

  private

  # Override
  def _check_available(_options); end

  def _check_host_supported; end

  # Override if necessary
  def _gem_name; end

  def _notification_type(image); end
  def _notify_options(overrides = T.unsafe(nil)); end

  # Override
  def _perform_notify(_message, _opts); end

  def _require_gem; end

  # Override if necessary
  def _supported_hosts; end
end

Notiffany::Notifier::Base::ERROR_ADD_GEM_AND_RUN_BUNDLE = T.let(T.unsafe(nil), String)
Notiffany::Notifier::Base::HOSTS = T.let(T.unsafe(nil), Hash)

class Notiffany::Notifier::Base::RequireFailed < ::Notiffany::Notifier::Base::UnavailableError
  # @return [RequireFailed] a new instance of RequireFailed
  def initialize(gem_name); end
end

class Notiffany::Notifier::Base::UnavailableError < ::RuntimeError
  # @return [UnavailableError] a new instance of UnavailableError
  def initialize(reason); end

  def message; end
end

class Notiffany::Notifier::Base::UnsupportedPlatform < ::Notiffany::Notifier::Base::UnavailableError
  # @return [UnsupportedPlatform] a new instance of UnsupportedPlatform
  def initialize; end
end

# Configuration class for Notifier
class Notiffany::Notifier::Config
  # @return [Config] a new instance of Config
  def initialize(opts); end

  # Returns the value of attribute env_namespace.
  def env_namespace; end

  # Returns the value of attribute logger.
  def logger; end

  # Returns the value of attribute notifiers.
  def notifiers; end

  # @return [Boolean]
  def notify?; end

  private

  def _setup_logger(opts); end
end

Notiffany::Notifier::Config::DEFAULTS = T.let(T.unsafe(nil), Hash)

# @private api
class Notiffany::Notifier::Detected
  # @return [Detected] a new instance of Detected
  def initialize(supported, env_namespace, logger); end

  # Called when user has notifier-specific config.
  # Honor the config by warning if something is wrong
  def add(name, opts); end

  def available; end
  def detect; end
  def reset; end

  private

  def _add(name, opts); end
  def _notifiers; end
  def _to_module(name); end
end

Notiffany::Notifier::Detected::NO_SUPPORTED_NOTIFIERS = T.let(T.unsafe(nil), String)
class Notiffany::Notifier::Detected::NoneAvailableError < ::RuntimeError; end

class Notiffany::Notifier::Detected::UnknownNotifier < ::RuntimeError
  # @return [UnknownNotifier] a new instance of UnknownNotifier
  def initialize(name); end

  def message; end

  # Returns the value of attribute name.
  def name; end
end

# Send a notification to Emacs with emacsclient
# (http://www.emacswiki.org/emacs/EmacsClient).
class Notiffany::Notifier::Emacs < ::Notiffany::Notifier::Base
  private

  # @raise [UnavailableError]
  def _check_available(options); end

  # Get the Emacs color for the notification type.
  # You can configure your own color by overwrite the defaults.
  #
  # notifications (default is 'ForestGreen')
  #
  # notifications (default is 'Firebrick')
  #
  # notifications
  #
  # 'Black')
  #
  # @option options
  # @option options
  # @option options
  # @option options
  # @param type [String] the notification type
  # @param options [Hash] aditional notification options
  # @return [String] the name of the emacs color
  def _emacs_color(type, options = T.unsafe(nil)); end

  def _erb_for(filename); end
  def _gem_name; end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param type [String] the notification type. Either 'success',
  #   'pending', 'failed' or 'notify'
  # @param title [String] the notification title
  # @param message [String] the notification message body
  # @param image [String] the path to the notification image
  # @param opts [Hash] additional notification library options
  def _perform_notify(message, opts = T.unsafe(nil)); end
end

# Handles evaluating ELISP code in Emacs via Erb
class Notiffany::Notifier::Emacs::Client
  # @raise [ArgumentError]
  # @return [Client] a new instance of Client
  def initialize(options); end

  # @return [Boolean]
  def available?; end

  # Returns the value of attribute elisp_erb.
  def elisp_erb; end

  def notify(color, bgcolor, message = T.unsafe(nil)); end

  private

  def _emacs_eval(env, code); end
end

# Creates a safe binding with local variables for ERB
class Notiffany::Notifier::Emacs::Client::Elisp < ::ERB
  # @return [Elisp] a new instance of Elisp
  def initialize(code, color, bgcolor, message); end

  # Returns the value of attribute bgcolor.
  def bgcolor; end

  # Returns the value of attribute color.
  def color; end

  # Returns the value of attribute message.
  def message; end

  def result; end
end

Notiffany::Notifier::Emacs::DEFAULTS = T.let(T.unsafe(nil), Hash)
Notiffany::Notifier::Emacs::DEFAULT_ELISP_ERB = T.let(T.unsafe(nil), String)

# Writes notifications to a file.
class Notiffany::Notifier::File < ::Notiffany::Notifier::Base
  private

  # @option opts
  # @param opts [Hash] some options
  def _check_available(opts = T.unsafe(nil)); end

  def _gem_name; end

  # Writes the notification to a file. By default it writes type, title,
  # and message separated by newlines.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  def _perform_notify(message, opts = T.unsafe(nil)); end
end

Notiffany::Notifier::File::DEFAULTS = T.let(T.unsafe(nil), Hash)

# System notifications using the
# [ruby_gntp](https://github.com/snaka/ruby_gntp) gem.
#
# This gem is available for OS X, Linux and Windows and sends system
# notifications to the following system notification frameworks through the
#
# [Growl Network Transport
# Protocol](http://www.growlforwindows.com/gfw/help/gntp.aspx):
#
# * [Growl](http://growl.info)
# * [Growl for Windows](http://www.growlforwindows.com)
# * [Growl for Linux](http://mattn.github.com/growl-for-linux)
# * [Snarl](https://sites.google.com/site/snarlapp)
class Notiffany::Notifier::GNTP < ::Notiffany::Notifier::Base
  def _check_available(_opts); end
  def _gem_name; end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  def _perform_notify(message, opts = T.unsafe(nil)); end

  def _supported_hosts; end

  private

  def _gntp_client(opts = T.unsafe(nil)); end
end

# Default options for the ruby gtnp client.
Notiffany::Notifier::GNTP::CLIENT_DEFAULTS = T.let(T.unsafe(nil), Hash)

Notiffany::Notifier::GNTP::DEFAULTS = T.let(T.unsafe(nil), Hash)

# System notifications using the
# [growl](https://github.com/visionmedia/growl) gem.
#
# This gem is available for OS X and sends system notifications to
# [Growl](http://growl.info) through the
# [GrowlNotify](http://growl.info/downloads) executable.
#
# The `growlnotify` executable must be installed manually or by using
# [Homebrew](http://mxcl.github.com/homebrew/).
#
# Sending notifications with this notifier will not show the different
# notifications in the Growl preferences. Use the :gntp notifier if you
# want to customize each notification type in Growl.
#
# your `Guardfile` notification :growl, sticky: true, host: '192.168.1.5',
# password: 'secret'
#
# @example Install `growlnotify` with Homebrew
#   brew install growlnotify
# @example Add the `growl` gem to your `Gemfile`
#   group :development
#   gem 'growl'
#   end
# @example Add the `:growl` notifier to your `Guardfile`
#   notification :growl
# @example Add the `:growl_notify` notifier with configuration options to
class Notiffany::Notifier::Growl < ::Notiffany::Notifier::Base
  def _check_available(_opts = T.unsafe(nil)); end

  # Shows a system notification.
  #
  # The documented options are for GrowlNotify 1.3, but the older options
  # are also supported. Please see `growlnotify --help`.
  #
  # Priority can be one of the following named keys: `Very Low`,
  # `Moderate`, `Normal`, `High`, `Emergency`. It can also be an integer
  # between -2 and 2.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  def _perform_notify(message, opts = T.unsafe(nil)); end

  def _supported_hosts; end
end

# Default options for the growl notifications.
Notiffany::Notifier::Growl::DEFAULTS = T.let(T.unsafe(nil), Hash)

Notiffany::Notifier::Growl::INSTALL_GROWLNOTIFY = T.let(T.unsafe(nil), String)

# System notifications using the
# [libnotify](https://github.com/splattael/libnotify) gem.
#
# This gem is available for Linux, FreeBSD, OpenBSD and Solaris and sends
# system notifications to
# Gnome [libnotify](http://developer.gnome.org/libnotify):
class Notiffany::Notifier::Libnotify < ::Notiffany::Notifier::Base
  private

  def _check_available(_opts = T.unsafe(nil)); end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  def _perform_notify(message, opts = T.unsafe(nil)); end

  def _supported_hosts; end
end

Notiffany::Notifier::Libnotify::DEFAULTS = T.let(T.unsafe(nil), Hash)
Notiffany::Notifier::NOTIFICATIONS_DISABLED = T.let(T.unsafe(nil), String)
class Notiffany::Notifier::NotServer < ::RuntimeError; end

# System notifications using the
# [rb-notifu](https://github.com/stereobooster/rb-notifu) gem.
#
# This gem is available for Windows and sends system notifications to
# [Notifu](http://www.paralint.com/projects/notifu/index.html):
#
# @example Add the `rb-notifu` gem to your `Gemfile`
#   group :development
#   gem 'rb-notifu'
#   end
class Notiffany::Notifier::Notifu < ::Notiffany::Notifier::Base
  private

  def _check_available(_opts = T.unsafe(nil)); end
  def _gem_name; end

  # Converts generic notification type to the best matching
  # Notifu type.
  #
  # @param type [String] the generic notification type
  # @return [Symbol] the Notify notification type
  def _notifu_type(type); end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  def _perform_notify(message, opts = T.unsafe(nil)); end

  def _supported_hosts; end
end

# Default options for the rb-notifu notifications.
Notiffany::Notifier::Notifu::DEFAULTS = T.let(T.unsafe(nil), Hash)

# System notifications using notify-send, a binary that ships with
# the libnotify-bin package on many Debian-based distributions.
#
# @example Add the `:notifysend` notifier to your `Guardfile`
#   notification :notifysend
class Notiffany::Notifier::NotifySend < ::Notiffany::Notifier::Base
  private

  def _check_available(_opts = T.unsafe(nil)); end

  # notify-send has no gem, just a binary to shell out
  def _gem_name; end

  # Converts Guards notification type to the best matching
  # notify-send urgency.
  #
  # @param type [String] the Guard notification type
  # @return [String] the notify-send urgency
  def _notifysend_urgency(type); end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  def _perform_notify(message, opts = T.unsafe(nil)); end

  def _supported_hosts; end

  # Builds a shell command out of a command string and option hash.
  #
  # shell command.
  #
  # @param command [String] the command execute
  # @param supported [Array] list of supported option flags
  # @param opts [Hash] additional command options
  # @return [Array<String>] the command and its options converted to a
  def _to_arguments(command, supported, opts = T.unsafe(nil)); end
end

# Default options for the notify-send notifications.
Notiffany::Notifier::NotifySend::DEFAULTS = T.let(T.unsafe(nil), Hash)

# Full list of options supported by notify-send.
Notiffany::Notifier::NotifySend::SUPPORTED = T.let(T.unsafe(nil), Array)

Notiffany::Notifier::ONLY_NOTIFY = T.let(T.unsafe(nil), String)

# List of available notifiers, grouped by functionality
Notiffany::Notifier::SUPPORTED = T.let(T.unsafe(nil), Array)

# System notifications using the
#
# [terminal-notifier](https://github.com/Springest/terminal-notifier-guard)
#
# gem.
#
# This gem is available for OS X 10.8 Mountain Lion and sends notifications
# to the OS X notification center.
class Notiffany::Notifier::TerminalNotifier < ::Notiffany::Notifier::Base
  def _check_available(_opts = T.unsafe(nil)); end
  def _gem_name; end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  def _perform_notify(message, opts = T.unsafe(nil)); end

  def _supported_hosts; end
end

Notiffany::Notifier::TerminalNotifier::DEFAULTS = T.let(T.unsafe(nil), Hash)
Notiffany::Notifier::TerminalNotifier::ERROR_ONLY_OSX10 = T.let(T.unsafe(nil), String)

# Shows system notifications in the terminal title bar.
class Notiffany::Notifier::TerminalTitle < ::Notiffany::Notifier::Base
  # Clears the terminal title
  def turn_off; end

  private

  def _check_available(_options); end
  def _gem_name; end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @param opts [Hash] additional notification library options
  def _perform_notify(message, opts = T.unsafe(nil)); end
end

Notiffany::Notifier::TerminalTitle::DEFAULTS = T.let(T.unsafe(nil), Hash)

# Changes the color of the Tmux status bar and optionally
# shows messages in the status bar.
class Notiffany::Notifier::Tmux < ::Notiffany::Notifier::Base
  # Notification stopping. Restore the previous Tmux state
  # if available (existing options are restored, new options
  # are unset) and unquiet the Tmux output.
  def turn_off; end

  # Notification starting, save the current Tmux settings
  # and quiet the Tmux output.
  def turn_on; end

  private

  def _check_available(opts = T.unsafe(nil)); end
  def _gem_name; end

  # Shows a system notification.
  #
  # By default, the Tmux notifier only makes
  # use of a color based notification, changing the background color of the
  # `color_location` to the color defined in either the `success`,
  # `failed`, `pending` or `default`, depending on the notification type.
  #
  # You may enable an extra explicit message by setting `display_message`
  # to true, and may further disable the colorization by setting
  # `change_color` to false.
  #
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @param message [String] the notification message
  # @param options [Hash] additional notification library options
  def _perform_notify(message, options = T.unsafe(nil)); end

  class << self
    def _end_session; end
    def _session; end
    def _start_session; end
  end
end

# Class for actually calling TMux to run commands
class Notiffany::Notifier::Tmux::Client
  # @return [Client] a new instance of Client
  def initialize(client); end

  def clients; end
  def display_message(message); end
  def display_time=(time); end
  def message_bg=(color); end
  def message_fg=(color); end
  def parse_options; end
  def set(key, value); end
  def title=(string); end
  def unset(key, value); end

  private

  def _all_args_for(key, value, client); end
  def _capture(*args); end
  def _parse_option(line); end
  def _run(*args); end

  class << self
    def _capture(*args); end
    def _run(*args); end
    def version; end
  end
end

Notiffany::Notifier::Tmux::Client::CLIENT = T.let(T.unsafe(nil), String)
Notiffany::Notifier::Tmux::DEFAULTS = T.let(T.unsafe(nil), Hash)
Notiffany::Notifier::Tmux::ERROR_ANCIENT_TMUX = T.let(T.unsafe(nil), String)
Notiffany::Notifier::Tmux::ERROR_NOT_INSIDE_TMUX = T.let(T.unsafe(nil), String)
class Notiffany::Notifier::Tmux::Error < ::RuntimeError; end

# Wraps a notification with it's options
class Notiffany::Notifier::Tmux::Notification
  # @return [Notification] a new instance of Notification
  def initialize(type, options); end

  def colorize(locations); end
  def display_message(title, message); end
  def display_title(title, message); end

  private

  def _message_for(title, message); end
  def _value_for(field); end

  # Returns the value of attribute client.
  def client; end

  # Returns the value of attribute color.
  def color; end

  # Returns the value of attribute message_color.
  def message_color; end

  # Returns the value of attribute options.
  def options; end

  # Returns the value of attribute separator.
  def separator; end

  # Returns the value of attribute type.
  def type; end
end

# Preserves TMux settings for all tmux sessions
class Notiffany::Notifier::Tmux::Session
  # @return [Session] a new instance of Session
  def initialize; end

  def close; end
end

Notiffany::Notifier::USING_NOTIFIER = T.let(T.unsafe(nil), String)

# TODO: use a socket instead of passing env variables to child processes
# (currently probably only used by guard-cucumber anyway)
class Notiffany::Notifier::YamlEnvStorage < ::Nenv::Environment
  def notifiers; end
  def notifiers=(raw_value); end
end
