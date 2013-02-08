class HyperObject
  class << self
    def outer
      const_get self.name.split('::')[-2]
    end

    def inner
      constants.inject(Array.new) do |list, name|
        child = const_get name
        list << child if child.is_a? Module
        list
      end
    end

    def proto
      superclass
    end

    def subtypes
      raise NotImplementedError
    end
  end
end

class Window < HyperObject
  class << self
    def set_size *new_size
      @size = new_size.flatten
    end

    def set_location *new_location
      @location = new_location.flatten
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
      children.each do |child|
        child.draw
      end
    end

    def redraw
      puts "redrawing #{self.name}"
      @redraw.call
      children.each do |child|
        child.redraw
      end
    end

    def width
      @size.last
    end

    def height
      @size.first
    end

    def display *text
      print "\e[31;1m"
      puts text.join
      print "\e[0m"
    end

    def clear
      puts "cleared #{self.name}"
    end

    def children
      inner.select{|child| child.ancestors.include? Window}
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
  set_size [100, 100]
  WidgetSize = [50, 50]

  class << self
    attr :counter
  end

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

print ' -- return value of click: '
puts value

