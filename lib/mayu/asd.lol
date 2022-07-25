# typed: strict

require "cgi"
require_relative "modules"
require_relative "dom"

module Mayu
  module Renderer
    class VDOM
      extend T::Sig

      KeyIndexMap = T.type_alias { T::Hash[T.untyped, Integer] }

      class HandlerRef
        extend T::Sig

        sig {params(component: Component, name: Symbol, args: T::Array[T.untyped]).void}
        def initialize(component, name, args = [])
          @component = component
          @name = name
          @args = args
        end

        sig {params(data: T.untyped).void}
        def call(data)
          @component.send(:"handle_#{@name}")
        end

        sig {returns(String)}
        def to_s
          id = Digest::SHA256.hexdigest([@component.object_id, @name, @args].map(&:inspect).join(":"))
          "Mayu.handler('#{id}')"
        end
      end

      module DescriptorHelper
        extend T::Sig

        sig do
          params(
            type: VDOM::ElementType,
            props: VDOM::Props,
            children: T.nilable(VDOM::Descriptor::ComponentChildren),
            blk: T.nilable(T.proc.returns(VDOM::Descriptor::ComponentChildren)),
          ).returns(VDOM::Descriptor)
        end
        def h(type, props = {}, children = [], &blk)
          if blk
            VDOM::Descriptor.new(type, props, blk.call)
          else
            VDOM::Descriptor.new(type, props, children)
          end
        end
      end

      class Component
        extend T::Sig
        extend DescriptorHelper
        include DescriptorHelper

        sig {returns(Props)}
        attr_accessor :props
        sig {returns(State)}
        attr_accessor :state
        sig {returns(State)}
        attr_accessor :next_state

        sig {params(vnode: VNode, props: Props).void}
        def initialize(vnode, props)
          @vnode = vnode
          @props = props
          @state = T.let({}, State)
          @next_state = T.let({}, State)
          @dirty = T.let(true, T::Boolean)
          @is_rendering = T.let(false, T::Boolean)
        end

        MODULES = T.let(nil, T.nilable(Modules))
        MODULE_PATH = T.let(nil, T.nilable(String))

        sig {params(path: String).returns(T.class_of(Component))}
        def self.import(path)
          const_get(:MODULES)
            .load_component(path, const_get(:MODULE_PATH))
            .klass
        end

        sig {returns(CSSModule::IdentProxy)}
        def styles
          self.class.const_get(:CSS).proxy
        end

        sig {params(block: T.proc.returns(VDOM::Descriptor::Children)).void}
        def self.render(&block) = define_method(:render, &block)
        sig {params(block: T.proc.returns(State)).void}
        def self.initial_state(&block) = define_method(:initial_state, &block)
        sig {params(name: Symbol, block: T.proc.returns(State)).void}
        def self.handler(name, &block) = define_method(:"handle_#{name}", &block)
        sig {params(block: T.proc.params(arg0: Props, arg1: State).returns(T::Boolean)).void}
        def self.should_update?(&block) = define_method(:"should_update?", &block)

        sig {params(name: Symbol, args: T.nilable(T::Array[T.untyped])).returns(HandlerRef)}
        def handler(name, *args)
          HandlerRef.new(self, name, args)
        end

        sig {returns(T::Boolean)}
        def dirty? = @dirty
        sig {returns(TrueClass)}
        def dirty! = @dirty = true

        sig {returns(VDOM::Descriptor::Children)}
        def children
          props[:children]
        end

        sig {params(klass: T.untyped).returns(T::Boolean)}
        def self.component_class?(klass)
          !!(klass.is_a?(Class) && klass < self)
        end

        # Render

        sig {returns(T.nilable(Descriptor::Children))}
        def __render
          if @is_rendering
            raise RuntimeError, "Double render error"
          end

          begin
            render
          ensure
            @is_rendering = false
            @dirty = false
          end
        end

        sig {returns(T.nilable(Descriptor::Children))}
        def render = nil

        sig {returns(String)}
        def inspect
          "<#Component #{self.class.const_get(:MODULE_PATH)}>"
        end

        # Lifecycle methods

        sig {void}
        def did_mount = nil
        sig {void}
        def will_unmount = nil

        sig {params(next_props: Props, next_state: State).returns(T::Boolean)}
        def should_update?(next_props, next_state)
          props != next_props || state != next_state
        end

        sig {params(prev_props: Props, prev_state: State).void}
        def did_update(prev_props, prev_state) = nil
      end

      class HTMLComponent < Component
        render do
          h(:html, {}, [
            h(:head, { lang: "en" }, [
              h(:meta, { charset: "utf-8" })
            ]),
            h(:body, {}, [
            ])
          ])
        end
      end

      class VNode
        extend T::Sig

        Children = T.type_alias { T::Array[T.nilable(VNode)] }

        sig {returns(Descriptor)}
        attr_accessor :descriptor
        sig {returns(ElementType)}
        def type = descriptor.type
        sig {returns(Props)}
        def props = descriptor.props
        sig {returns(T.untyped)}
        def key = descriptor.key
        sig {returns(Children)}
        attr_accessor :children
        sig {returns(DOM::Node)}
        attr_accessor :dom

        sig {returns(T.nilable(Component))}
        attr_reader :component

        sig {returns(T.nilable(DOM::Node))}
        attr_reader :dom

        sig {params(vdom: VDOM, descriptor: Descriptor, dom: T.nilable(DOM::Node)).void}
        def initialize(vdom, descriptor, dom = nil)
          @dom = dom
          @id = T.let(vdom.next_id!, Integer)
          @vdom = vdom
          @descriptor = descriptor
          @children = T.let([], Children)
          @component = T.let(nil, T.nilable(Component))
          init_component
        end

        sig {returns(T.nilable(Component))}
        def init_component
          return @component if @component

          type = descriptor.type

          if type.is_a?(Class) && type < Component
            @component = type.new(self, props)
          else
            nil
          end
        end

        sig {params(descriptor: Descriptor).returns(T::Boolean)}
        def same?(descriptor)
          descriptor.type == type && descriptor.key == key
        end

        sig {params(level: Integer, exclude_components: T::Boolean).returns(String)}
        def inspect_tree(level = 0, exclude_components: false)
          indent = "  " * level
          type = descriptor.type

          if type == Descriptor::TEXT
            return indent + descriptor.text
          end

          if component && exclude_components
            return Array(children).flatten.compact.map {
              _1.inspect_tree(level, exclude_components:)
            }.join("\n")
          end

          formatted_props = props.reject { _1 == :children }.map { |key, value|
            format(
              ' %<key>s="%<value>s"',
              key: key.to_s.sub(/^on_/, "on").tr("_", "-"),
              value: CGI.escape(value.to_s),
            )
          }

          formatted_props.unshift(%< data-mayu-key="#{descriptor.key.to_s}">) if descriptor.key
          formatted_props.unshift(%< data-mayu-id="#{@id.to_s}">)

          cleaned_children = Array(children).flatten.compact

          if cleaned_children.empty?
            return indent + "<#{type.to_s}#{formatted_props.join} />"
          end

          [
            indent + "<#{type.to_s}#{formatted_props.join}>",
            *Array(children).flatten.compact.map {
              _1.inspect_tree(level.succ, exclude_components:)
            },
            indent + "</#{type.to_s}>"
          ].join("\n")
        end
      end

      sig {returns(DOM)}
      attr_reader :dom

      sig {returns(Integer)}
      def next_id! = @id_counter += 1

      sig {params(descriptor: Descriptor).void}
      def initialize(descriptor)
        @id_counter = T.let(0, Integer)
        @dom = T.let(DOM.new, DOM)
        @root = T.let(VNode.new(self, descriptor, @dom.root), T.nilable(VNode))
      end

      sig {params(descriptor: Descriptor).void}
      def render(descriptor)
        @root = patch_vnode(@root, descriptor)
      end

      sig {params(exclude_components: T::Boolean).returns(String)}
      def inspect_tree(exclude_components: false)
        @root&.inspect_tree(exclude_components:).to_s
      end

      private

      sig {params(vnode: T.nilable(VNode), descriptor: T.nilable(Descriptor)).void}
      def patch(vnode, descriptor)
        patch_vnode(vnode, descriptor)
      end

      sig {params(descriptor: Descriptor).returns(VNode)}
      def init_vnode(descriptor)
        vnode = VNode.new(self, descriptor)

        if component = vnode.init_component
          component.props = descriptor.props
          child_descriptors = component.__render
        else
          child_descriptors = descriptor.props[:children]
        end

        vnode.children = diff_children(
          vnode,
          Array(child_descriptors).flatten.compact
        )

        vnode
      end

      sig {params(vnode: T.nilable(VNode), descriptor: T.nilable(Descriptor)).returns(T.nilable(VNode))}
      def patch_vnode(vnode, descriptor)
        unless descriptor
          return nil
        end

        unless vnode
          return init_vnode(descriptor)
        end

        if descriptor.text?
          unless vnode.descriptor.text?
            return init_vnode(descriptor)
          end
        end

        if vnode.same?(descriptor)
          component = vnode.component

          if component
            if component.should_update?(descriptor.props, component.next_state) || component.dirty?
              component.props = descriptor.props
              component.state = component.next_state
              descriptors = component.__render
            else
              vnode.descriptor = descriptor
              vnode.children = vnode.children.map { _1 && patch_vnode(_1, _1.descriptor) }
              return vnode
            end
          else
            descriptors = descriptor.props[:children]
          end

          vnode.descriptor = descriptor
          vnode.children = diff_children(vnode, descriptors)

          vnode
        else
          descriptors = descriptor.props[:children]
          vnode.descriptor = descriptor
          vnode.children = diff_children(vnode, descriptors)
          vnode
        end
      end

      sig {params(vnode: VNode).returns(DOM::Node)}
      def create_dom_node(vnode)
        type = vnode.descriptor.type

        unless type.is_a?(Symbol)
          raise ArgumentError, "Trying to create a DOM-node for type #{type.inspect}"
        end

        if type == Descriptor::TEXT
          node = @dom.create_text_node(vnode.props[:text_content].to_s)
        else
          node = @dom.create_element(type)

          vnode.children.each do |child|
            if child
              node.append_child(create_dom_node(child))
            end
          end
        end

        vnode.dom = node
      end

      sig {params(vnode: VNode, descriptors: Descriptor::Children).returns(VNode::Children)}
      def diff_children(vnode, descriptors)
        descriptors = Array(descriptors).flatten.compact
        #parent_dom = T.cast(vnode.dom, DOM::Node)

        result = T.let(Array.new(descriptors.length), VNode::Children)

        old_children = vnode.children
        # Before
        old_start_index = 0
        # New front
        start_descriptor_index = 0
        # Old queen
        old_end_index = old_children.length
        # New post
        end_descriptor_index = descriptors.length
        # In the above four cases, it is the structure used in hit processing
        keymap = T.let(nil, T.nilable(KeyIndexMap))
        # Loop through processing nodes
        while old_start_index <= old_end_index && start_descriptor_index <= end_descriptor_index
          # The first is not to judge the first four hits , But to skip what has been added undefined Things marked
          unless old_start_vnode = old_children[old_start_index]
            old_start_vnode = old_children[old_start_index += 1]
            next
          end

          unless old_end_vnode = old_children[old_end_index]
            old_end_vnode = old_children[old_end_index -= 1]
            next
          end

          unless start_descriptor = descriptors[start_descriptor_index]
            start_descriptor = descriptors[start_descriptor_index += 1]
            next
          end

          unless end_descriptor = descriptors[end_descriptor_index]
            end_descriptor = descriptors[end_descriptor_index -= 1]
            next
          end

          case
          when old_start_vnode.same?(start_descriptor)
            # New and old
            result[start_descriptor_index] = patch_vnode(old_start_vnode, start_descriptor)
            old_start_vnode = old_children[old_start_index += 1]
            if x = descriptors[start_descriptor_index += 1]
              start_descriptor = x
            end
          when old_end_vnode.same?(end_descriptor)
            # New post and old post hit
            result[end_descriptor_index] = patch_vnode(old_end_vnode, end_descriptor)
            old_end_vnode = old_children[old_end_index -= 1]
            end_descriptor = descriptors[end_descriptor_index -= 1]
          when old_start_vnode.same?(end_descriptor)
            # New and old hits
            result[end_descriptor_index] = patch_vnode(old_start_vnode, end_descriptor)
            # parent_dom.insert_before(
            #   T.cast(old_start_vnode.dom, DOM::Node),
            #   old_end_vnode.dom&.next_sibling
            # )
            old_start_vnode = old_children[old_start_index += 1]
            end_descriptor = descriptors[end_descriptor_index -= 1]
          when old_end_vnode.same?(start_descriptor)
            # New before and old after hit
            result[start_descriptor_index] = patch_vnode(old_end_vnode, start_descriptor)
            # When the new front and old back hit , At this time, we need to move the node . Move the node pointed by the new node to the front of the old node
            # parent_dom.insert_before(
            #   T.cast(old_end_vnode.dom, DOM::Node),
            #   old_start_vnode.dom
            # )
            old_end_vnode = old_children[old_end_index -= 1]
            start_descriptor = descriptors[start_descriptor_index += 1]
          else
            # None of the four hits hit
            # Make keymap A mapping object , So you don't have to traverse the old object every time .
            keymap ||= build_key_index_map(old_children, old_start_index, old_end_index)
            # Look for the current （new_start_idx） This is in the keymap The position number of the map in
            index = keymap[start_descriptor.key]

            unless index
              # Judge , If idxInOld yes undefined Indicates that it is a brand new item
              # Added items （ Namely start_descriptor the ) It's not really DOM node
              new_child_vnode = init_vnode(start_descriptor)
              p new_child_vnode.descriptor.text if new_child_vnode.descriptor.text?
              result.insert(start_descriptor_index, new_child_vnode)
              # parent_dom.insert_before(create_dom_node(new_child_vnode), old_start_vnode.dom)
            else
              # If not undefined, Not a new item , But to move
              element_to_move = old_children[index]
              result[start_descriptor_index] = patch_vnode(element_to_move, start_descriptor)
              # Set this to undefined, It means that I have finished this
              # old_children[index] = nil
              # Move , call insert_before It can also be mobile .
              # parent_dom.insert_before(T.cast(element_to_move&.dom, DOM::Node), old_start_vnode.dom)
            end
            # The pointer moves down , Just move the new head
            start_descriptor = descriptors[start_descriptor_index += 1]
          end
        end
        # Go ahead and see if there's any left . The cycle is over start It's better than old Small
        if start_descriptor_index <= end_descriptor_index
          # Traverse the new descriptors, Add to the old ones that haven't been processed
          start_descriptor_index.upto(end_descriptor_index) do |i|
            new_child = descriptors[i]
            old_child = old_children[old_start_index]
            next unless new_child
            new_child_vnode = init_vnode(new_child)
            p new_child_vnode.descriptor.text if new_child_vnode.descriptor.text?
            result.push(new_child_vnode)
            # parent_dom.insert_before(create_dom_node(new_child_vnode), old_child&.dom)
          end
        elsif (old_start_index <= old_end_index)
          # Batch deletion oldStart and oldEnd Items between pointers
          old_start_index.upto(old_end_index) do |i|
            old_child = old_children[i]
            next unless old_child
            # parent_dom.remove_child(T.cast(old_child.dom, DOM::Node))
          end
        end

        result
      end

      sig {params(children: VNode::Children, start_index: Integer, end_index: Integer).returns(KeyIndexMap)}
      def build_key_index_map(children, start_index, end_index)
        keymap = {}

        start_index.upto(end_index) do |i|
          key = children[i]&.key
          keymap[key] = i
        end

        keymap
      end

      class VPatchSet
        class VPatch
        end

        extend T::Sig

        sig {returns(VNode)}
        attr_reader :node0
        sig {returns(T::Array[VPatch])}
        attr_reader :patches

        sig {params(node0: VNode).void}
        def initialize(node0)
          @node0 = node0
          @patches = T.let([], T::Array[VPatch])
        end
      end
    end
  end
end