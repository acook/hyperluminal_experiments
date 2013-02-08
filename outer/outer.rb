class HyperObject
  class << self
    def outer
      const_get self.name.split('::')[-2]
    end

    def inner type = Module
      constants.inject(Array.new) do |list, name|
        child = const_get name
        list << child if child.is_a?(Module) && child.ancestors.include?(type)
        list
      end
    end

    def proto
      superclass
    end

    def subtypes
      raise NotImplementedError
    end

    def attribute *attributes
      attributes_with_types = attributes.last.is_a?(Hash) ? pop : {}

      attributes_with_types.each do |name, type|
        define_method sym, Proc.new { type.dup }

        module_eval(<<-EVAL, __FILE__, __LINE__ + 1)
          def #{name}= value
            class << self; attr_accessor :#{name} end
            @#{name} = value
          end
        EVAL
      end

      attributes.each do |name|
        module_eval(<<-EVAL, __FILE__, __LINE__ + 1)
          attr_accessor :#{name}
        EVAL
      end

      nil
    end


  end
end

module HyperExtensions
  def delegate(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
    end

    if options[:prefix] == true && options[:to].to_s =~ /^[^a-z_]/
      raise ArgumentError, "Can only automatically set the delegation prefix when delegating to a method."
    end

    prefix = options[:prefix] && "#{options[:prefix] == true ? to : options[:prefix]}_" || ''

    file, line = caller.first.split(':', 2)
    line = line.to_i

    methods.each do |method|
      on_nil =
        if options[:allow_nil]
          'return'
        else
          %(raise "#{self}##{prefix}#{method} delegated to #{to}.#{method}, but #{to} is nil: \#{self.inspect}")
        end

      module_eval(<<-EOS, file, line - 1)
        def #{prefix}#{method}(*args, &block)               # def customer_name(*args, &block)
      #{to}.__send__(#{method.inspect}, *args, &block)  #   client.__send__(:name, *args, &block)
        rescue NoMethodError                                # rescue NoMethodError
          if #{to}.nil?                                     #   if client.nil?
      #{on_nil}                                       #     return # depends on :allow_nil
          else                                              #   else
            raise                                           #     raise
          end                                               #   end
        end                                                 # end
      EOS
    end
  end
end

BasicObject.extend HyperExtensions

class Coordinate < HyperObject
  def initialize *dimensions
    @dimensions = dimensions.flatten
  end

  def x
    @dimensions.first
  end
  alias_method :height, :x
  alias_method :row, :x

  def y
    @dimensions[1]
  end
  alias_method :width, :y
  alias_method :col, :y

  def z
    @dimensions[2]
  end
  alias_method :depth, :z
  alias_method :layer, :z
end

class Window < HyperObject
  class << self
    attr :size
    delegate :width, :height, to: :size

    def set_size *new_size
      @size = Coordinate.new new_size.flatten
    end

    def set_location *new_location
      @location = Coordinate.new new_location.flatten
    end

    def on_draw draw_lambda
      @draw = draw_lambda
    end

    def on_redraw redraw_lambda
      @redraw = redraw_lambda
    end

    def draw
      puts "drawing #{self.name}"
      @draw.call
      inner(Window).each do |child|
        child.draw
      end
    end

    def redraw
      puts "redrawing #{self.name}"
      @redraw.call
      inner(Window).each do |child|
        child.redraw
      end
    end

    def display *text
      puts "\e[31;1m#{text.join}\e[0m"
    end

    def clear
      puts "cleared #{self.name}"
    end
  end
end

class Button < Window
  class << self
    def set_text new_text
      @text = new_text
    end

    def on_click click_lambda
      @click = click_lambda
    end

    def text
      @text
    end

    def click
      puts "clicked #{self.name}"
      @click.call
    end

    def inherited subclass
      subclass.instance_eval do
        on_draw lambda {
          display text
        }

        on_redraw lambda {
          clear
          display text
        }
      end
    end
  end

end

class SayWhenWindow < Window
  class << self
    attr :counter
  end
  WidgetSize = [50, 50]

  set_size [100, 100]

  on_draw lambda {
    @counter = 0
    display counter
  }

  on_redraw lambda {
    @counter += 1

    clear
    display counter
  }

  class WhenButton < Button
    set_size WidgetSize
    set_location (outer.width - height), (outer.height - height)
    set_text 'When!'

    on_click lambda {
      outer.counter
    }
  end
end

puts ' -- initial draw:'
SayWhenWindow.draw

puts ' -- redrawing a couple of times:'
SayWhenWindow.redraw
SayWhenWindow.redraw

puts ' -- clicking button: '
value = SayWhenWindow::WhenButton.click

print " -- return value of click: #{value}"

