# typed: strict

module Mayu
  module Component
    class Helpers
      extend T::Sig

      sig { params(vnode: VDOM::VNode).void }
      def initialize(vnode)
        @vnode = vnode
      end

      sig do
        params(
          url: String,
          method: Symbol,
          headers: T::Hash[String, String],
          body: T.nilable(String)
        ).returns(Fetch::Response)
      end
      def fetch(url, method: :GET, headers: {}, body: nil)
        @vnode.fetch(url, method:, headers:, body:)
      end

      sig { params(path: String).void }
      def navigate(path)
        @vnode.navigate(path)
      end

      sig { params(selector: String, options: String).void }
      def scroll_into_view(selector, **options)
        @vnode.action(:scroll_into_view, { selector:, options: })
      end

      sig { params(message: String).void }
      def alert(message)
        @vnode.action(:alert, message)
      end

      # sig { returns(Mayu::State::Store) }
      # def store
      #   @vnode.store
      # end
    end
  end
end
