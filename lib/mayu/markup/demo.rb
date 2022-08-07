#!/usr/bin/env ruby
# typed: strict

require_relative "../markup"
require_relative "../vdom/descriptor"
require "pry"

extend T::Sig

class MyComponent
  extend T::Sig

  sig {returns(Mayu::VDOM::Descriptor)}
  def render
    h.div do
      h.h1 "Page title"

      h.table do
        h.tbody do
          h.tr do
            h.td "Item 1"
            h.td "User 1"
          end.tr

          h.tr do
            h.td "Item 2"
            h.td "User 1"
          end.tr

          h.tr do
            h.td "Item 3"
            h.td "User 2"
          end.tr
        end.tbody
      end.table

      h.div do
        h << "Hello "
        h.span "world", style: "font-weight: bold;"
      end.div
    end.div
  end

  sig{returns(Mayu::Markup::Builder)}
  def h
    Mayu::Markup::Builder.new
  end
end

sig{ params(descriptor: Mayu::VDOM::Descriptor).void}
def debug(descriptor)
  if descriptor.text?
    print descriptor.props[:text_content]
  elsif descriptor.comment?
    print "<!-- -->"
  else
    print "<#{descriptor.type.to_s}>"
    descriptor.children.each do
      debug(_1)
    end
    print "</#{descriptor.type.to_s}>"
  end
end

debug(MyComponent.new.render)