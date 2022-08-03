# typed: strict

require "async/queue"
require_relative "component"
require_relative "descriptor"
require_relative "dom"
require_relative "vnode"
require_relative "css_attributes"
require_relative "update_context"
require_relative "../event_emitter"
require "pry"

module Mayu
  module VDOM
    class VTree
      extend T::Sig

      class Indexes
        extend T::Sig

        sig { params(indexes: T::Array[Integer]).void }
        def initialize(indexes = [])
          @indexes = indexes
        end

        sig { params(id: Integer).void }
        def append(id)
          @indexes.delete(id)
          @indexes.push(id)
        end

        sig { params(index: Integer).returns(T.nilable(Integer)) }
        def [](index) = @indexes[index]

        sig { params(id: Integer).returns(T.nilable(Integer)) }
        def index(id) = @indexes.index(id)
        sig { params(id: Integer).returns(T.nilable(Integer)) }
        def rindex(id) = @indexes.rindex(id)


        sig { params(id: Integer, after: T.nilable(Integer)).void }
        def insert_after(id, after)
          insert_before(id, after && next_sibling(after))
        end

        sig { params(id: Integer, before: T.nilable(Integer)).void }
        def insert_before(id, before)
          @indexes.delete(id)
          index = before && @indexes.index(before)
          index ? @indexes.insert(index, id) : @indexes.push(id)
        end

        sig { params(id: Integer).returns(T.nilable(Integer)) }
        def next_sibling(id)
          if index = @indexes.index(id)
            @indexes[index.succ]
          end
        end

        sig { params(id: Integer).void }
        def remove(id) = @indexes.delete(id)

        sig { returns(T::Array[Integer]) }
        def to_a = @indexes
      end

      Id = T.type_alias { Integer }

      sig { returns(T::Array[T.untyped]) }
      attr_reader :patchsets
      sig { returns(Async::Condition) }
      attr_reader :on_update

      sig { params(task: Async::Barrier).void }
      def initialize(task: Async::Task.current)
        @root = T.let(nil, T.nilable(VNode))
        @id_counter = T.let(0, Id)

        @handlers = T.let({}, T::Hash[String, Component::HandlerRef])

        @patchsets = T.let([], T::Array[T.untyped])
        @update_queue = T.let(Async::Queue.new, Async::Queue)
        @on_update = T.let(Async::Condition.new, Async::Condition)

        @sent_stylesheets = T.let(Set.new, T::Set[String])

        @update_task =
          T.let(
            task.async(annotation: "VTree updater") do |task|
              loop do
                ctx = UpdateContext.new

                @update_queue.size.times do
                  vnode = @update_queue.dequeue
                  if vnode.component&.dirty?
                    patch_vnode(ctx, vnode, vnode.descriptor)
                  end
                end

                commit!(ctx.patches)

                sleep 0.05
              end
            rescue => e
              puts e
            end,
            Async::Task
          )
      end

      sig { void }
      def stop! = @update_task.stop
      sig { returns(T::Boolean) }
      def running? = @update_task.running?

      sig { params(descriptor: Descriptor).returns(T.nilable(VNode)) }
      def render(descriptor)
        ctx = UpdateContext.new
        @root = patch(ctx, @root, descriptor)
        commit!(ctx.patches)
        @root
      end

      sig { params(handler_id: String, payload: T.untyped).void }
      def handle_event(handler_id, payload = {})
        @handlers
          .fetch(handler_id) do
            raise KeyError, "Handler not found: #{handler_id}"
          end
          .call(payload)
      end

      sig { returns(String) }
      def to_html
        @root&.inspect_tree(exclude_components: true).to_s
      end

      sig { params(exclude_components: T::Boolean).returns(String) }
      def inspect_tree(exclude_components: false)
        @root&.inspect_tree(exclude_components:).to_s
      end

      sig { returns(T.untyped) }
      def id_tree
        @root&.id_tree
      end

      sig { returns(T::Hash[String, String]) }
      def stylesheets
        @root&.stylesheets || {}
      end

      sig { params(vnode: VNode).void }
      def enqueue_update!(vnode)
        component = vnode.component
        return unless component
        return if component.dirty?

        # puts "\e[33mEnqueueing\e[0m"

        component.dirty!
        @update_queue.enqueue(vnode)
      end

      sig { returns(Id) }
      def next_id!
        @id_counter.tap { @id_counter = @id_counter.succ }
      end

      private

      sig { params(patches: T.untyped).void }
      def commit!(patches)
        @on_update.signal([:patch, patches])
      end

      sig do
        params(
          ctx: UpdateContext,
          vnode: T.nilable(VNode),
          descriptor: T.nilable(Descriptor)
        ).returns(T.nilable(VNode))
      end
      def patch(ctx, vnode, descriptor)
        unless vnode
          return nil unless descriptor

          vnode = init_vnode(ctx, descriptor)
          ctx.insert(vnode)
          return vnode
        end

        return remove_vnode(ctx, vnode) unless descriptor

        if vnode.descriptor.same?(descriptor)
          patch_vnode(ctx, vnode, descriptor)
        else
          remove_vnode(ctx, vnode)
          vnode = init_vnode(ctx, descriptor)
          ctx.insert(vnode)
          return vnode
        end
      end

      sig do
        params(
          ctx: UpdateContext,
          vnode: VNode,
          descriptor: Descriptor
        ).returns(VNode)
      end
      def patch_vnode(ctx, vnode, descriptor)
        unless vnode.descriptor.same?(descriptor)
          raise "Can not patch different types!"
        end

        if component = vnode.component
          if component.should_update?(descriptor.props, component.next_state) ||
               component.dirty?
            vnode.descriptor = descriptor
            prev_props, prev_state = component.props, component.state
            component.props = descriptor.props
            component.state = component.next_state.clone
            descriptors =
              add_comments_between_texts(Array(component.render).compact)

            ctx.enter(vnode) do
              vnode.children =
                update_children(ctx, vnode.children.compact, descriptors)
            end

            component.did_update(prev_props, prev_state)
          end

          return vnode
        end

        type = descriptor.type

        if type.is_a?(Proc)
          vnode.descriptor = descriptor
          descriptors = Array(type.call(**descriptor.props)).compact

          ctx.enter(vnode) do
            vnode.children =
              update_children(ctx, vnode.children.compact, descriptors)
          end

          return vnode
        end

        return vnode if vnode.descriptor == descriptor

        if descriptor.text?
          unless vnode.descriptor.text == descriptor.text
            if append = append_part(vnode.descriptor.text, descriptor.text)
              ctx.text(vnode, append, append: true)
            else
              ctx.text(vnode, descriptor.text)
            end
            vnode.descriptor = descriptor
            return vnode
          end
        else
          if vnode.descriptor.children? && descriptor.children?
            if vnode.descriptor.children != descriptor.children
              ctx.enter(vnode) do
                vnode.children =
                  update_children(ctx, vnode.children, descriptor.children)
              end
            end
          elsif descriptor.children?
            check_duplicate_keys(descriptor.children)
            puts "adding new children"

            ctx.enter(vnode) do
              vnode.children =
                add_comments_between_texts(descriptor.children).map do
                  init_vnode(ctx, _1).tap { |child| ctx.insert(child) }
                end
            end
          elsif vnode.children.length > 0
            ctx.enter(vnode) { vnode.children.each { remove_vnode(ctx, _1) } }
            vnode.children = []
          elsif vnode.descriptor.text?
            ctx.text(vnode, "")
          else
            puts "got here"
          end
        end

        update_handlers(vnode.props, descriptor.props)
        update_attributes(ctx, vnode, vnode.props, descriptor.props)

        vnode.descriptor = descriptor

        vnode
      end

      sig do
        params(ctx: UpdateContext, vnodes: T::Array[VNode]).returns(NilClass)
      end
      def remove_vnodes(ctx, vnodes)
        vnodes.each { |vnode| remove_vnode(ctx, vnode) }
        nil
      end

      sig do
        params(
          ctx: UpdateContext,
          descriptor: Descriptor,
          nested: T::Boolean
        ).returns(VNode)
      end
      def init_vnode(ctx, descriptor, nested: false)
        vnode = VNode.new(self, ctx.dom_parent_id, descriptor)
        component = vnode.init_component

        children =
          if component
            Array(component.render).compact
          else
            descriptor.props[:children]
          end

        ctx.enter(vnode) do
          vnode.children =
            add_comments_between_texts(children).map do
              init_vnode(ctx, _1, nested: true)
            end
        end

        vnode.component&.mount
        update_handlers({}, vnode.props)

        if ss = component&.stylesheet
          unless @sent_stylesheets.include?(ss.path)
            ctx.stylesheet(ss.path)
            @sent_stylesheets.add(ss.path)
          end
        end

        vnode
      end

      sig do
        params(ctx: UpdateContext, vnode: VNode, patch: T::Boolean).returns(
          NilClass
        )
      end
      def remove_vnode(ctx, vnode, patch: true)
        vnode.component&.unmount
        if patch
          ctx.remove(vnode)
        end
        vnode.children.map { remove_vnode(ctx, _1, patch: false) }
        update_handlers(vnode.props, {})
        nil
      end

      sig { params(descriptors: T::Array[Descriptor]).void }
      def check_duplicate_keys(descriptors)
        keys = descriptors.map(&:key).compact
        duplicates = keys.reject { keys.rindex(_1) == keys.index(_1) }.uniq
        duplicates.each do |key|
          puts "\e[31mDuplicate keys detected: '#{key}'. This may cause an update error.\e[0m"
        end
      end

      sig { params(vnode: VNode, descriptor: Descriptor).returns(T::Boolean) }
      def same?(vnode, descriptor)
        vnode.descriptor.same?(descriptor)
      end

      sig do
        params(
          ctx: UpdateContext,
          vnodes: T::Array[VNode],
          descriptors: T::Array[Descriptor]
        ).returns(T::Array[VNode])
      end
      def update_children(ctx, vnodes, descriptors)
        check_duplicate_keys(descriptors)

        vnodes = vnodes.compact
        descriptors = descriptors.compact
        old_ids = vnodes.map(&:id)

        indexes = Indexes.new(vnodes.map(&:id))

        new_children =
          T.let(descriptors.map.with_index do |descriptor, i|
            vnode = vnodes.find { _1.same?(descriptor) }

            if vnode
              vnodes.delete(vnode)
              patch_vnode(ctx, vnode, descriptor)
            else
              init_vnode(ctx, descriptor)
            end
          end, T::Array[VNode])

        # This is very inefficient.
        # I tried to get the algorithm from snabbdom/vue to work,
        # but it's not very easy to get right.
        # I always got some weird ordering issues and it's tricky to debug.
        # Fun stuff for later though.

        all_vnodes = vnodes + new_children

        new_children.each_with_index do |vnode, expected_index|
          new_indexes = Indexes.new(indexes.to_a - vnodes.map(&:id))
          current_index = indexes.index(vnode.id)


          before_id = indexes[expected_index]
          before = before_id && all_vnodes.find do
            _1.id == before_id
          end

          if old_ids.include?(vnode.id)
            unless current_index == expected_index
              ctx.move(vnode, before:)
              indexes.insert_before(vnode.id, before_id)
            end
          else
            ctx.insert(vnode, before:)
            indexes.insert_before(vnode.id, before_id)
          end
        end

        vnodes.each do |vnode|
          remove_vnode(ctx, vnode)
        end

        new_children
      end

      sig do
        params(
          children: T::Array[VNode],
          start_index: Integer,
          end_index: Integer
        ).returns(T::Hash[Integer, T.untyped])
      end
      def build_key_index_map(children, start_index, end_index)
        keymap = {}

        start_index.upto(end_index) do |i|
          if key = children[i]&.descriptor&.key
            keymap[key] = i
          end
        end

        keymap
      end

      sig do
        params(descriptors: T::Array[Descriptor]).returns(T::Array[Descriptor])
      end
      def add_comments_between_texts(descriptors)
        comment = Descriptor.comment
        prev = T.let(nil, T.nilable(Descriptor))

        descriptors
          .map
          .with_index do |curr, i|
            prev2 = prev
            prev = curr if curr

            prev2&.text? && curr.text? ? [comment, curr] : [curr]
          end
          .flatten
      end

      sig do
        params(old_props: Component::Props, new_props: Component::Props).void
      end
      def update_handlers(old_props, new_props)
        old_handlers = old_props.keys.select { _1.start_with?("on_") }
        new_handlers = new_props.keys.select { _1.start_with?("on_") }

        # FIXME: If the same handler id is used somewhere else,
        # it will be cleared too.
        removed_handlers = old_handlers - new_handlers

        old_props
          .values_at(*T.unsafe(removed_handlers))
          .each { |handler| @handlers.delete(handler.id) }

        new_props
          .values_at(*T.unsafe(new_handlers))
          .each { |handler| @handlers[handler.id] = handler }
      end

      sig do
        params(
          ctx: UpdateContext,
          vnode: VNode,
          old_props: Component::Props,
          new_props: Component::Props
        ).void
      end
      def update_attributes(ctx, vnode, old_props, new_props)
        removed = old_props.keys - new_props.keys - [:children]

        new_props.each do |attr, value|
          next if attr == :children
          old_value = old_props[attr]
          next if value == old_props[attr]

          if attr == :style && old_value.is_a?(Hash) && value.is_a?(Hash)
            CSSAttributes.new(**old_value).patch(
              ctx,
              vnode,
              CSSAttributes.new(**value)
            )
            next
          end

          ctx.set_attribute(vnode, attr.to_s, value.to_s)
        end

        removed.each { |attr| ctx.remove_attribute(vnode, attr.to_s) }
      end

      sig { params(str1: String, str2: String).returns(T.nilable(String)) }
      def append_part(str1, str2)
        return nil if str1.strip.empty? || str1.length >= str2.length
        return nil unless str2.slice(0...str1.length) == str1
        str2.slice(str1.length..-1)
      end
    end
  end
end
