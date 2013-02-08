require_relative '../rb_lib/hyper_ruby'

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

puts " -- return value of click: #{value}"

