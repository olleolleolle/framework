# typed: strict

require_relative "action_wrapper"
require_relative "action_creator"

module Mayu
  module State
    class Store
      extend T::Sig

      State = T.type_alias { T.untyped }
      Reducer =
        T.type_alias do
          T.proc.params(arg0: State, arg1: ActionWrapper).returns(State)
        end
      Thunk = T.type_alias { T.proc.params(arg0: Store).void }

      sig { returns(State) }
      attr_reader :state

      sig do
        params(initial_state: State, reducers: T::Hash[Symbol, Reducer]).void
      end
      def initialize(initial_state, reducers:)
        @state = T.let(initial_state, State)
        @reducer = T.let(combine_reducers(reducers), Reducer)
        @semaphore = T.let(Async::Semaphore.new, Async::Semaphore)
      end

      ActionHash = T.type_alias { T::Hash[Symbol, T.untyped] }

      sig do
        params(
          action: T.any(ActionHash, ActionCreator::Base, Thunk),
          args: T.untyped,
          kwargs: T.untyped
        ).void
      end
      def dispatch(action, *args, **kwargs)
        if action.is_a?(ActionCreator::Base)
          return dispatch(T.unsafe(action).call(*args, **kwargs))
        end

        return action.call(self) if action.is_a?(Proc)

        @semaphore.async do
          new_state = @reducer.call(@state.dup, T.unsafe(ActionWrapper).new(**action))
          @state = new_state
        rescue => e
          Console.logger.error(self) { "Reducer crashed" }
        end

        nil
      end

      private

      sig { params(reducers: T::Hash[Symbol, Reducer]).returns(Reducer) }
      def combine_reducers(reducers)
        ->(state, action) do
          reducers.reduce(state) do |new_state, (name, reducer)|
            new_state.merge(name => reducer.call(state[name], action))
          end
        end
      end
    end
  end
end