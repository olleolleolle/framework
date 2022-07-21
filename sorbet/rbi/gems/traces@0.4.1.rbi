# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `traces` gem.
# Please instead update this file by running `bin/tapioca gem traces`.

module Traces
  class << self
    # Extend the specified class in order to emit traces.
    def Provider(klass, &block); end

    # Require a specific trace backend.
    def require_backend(env = T.unsafe(nil)); end
  end
end

# A module which contains tracing specific wrappers.
module Traces::Provider
  def traces_provider; end
end
