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
