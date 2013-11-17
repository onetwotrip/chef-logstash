module Logstash
  module ErubisHelper

    def logstash; Logstash::ErubisHelper::Formatter; end

    # Logstash formatter class provides helper methods
    # to pretty print logstash config file.
    #
    # #plugin_pp method pretty prints plugin data.
    #
    class Formatter
      class PluginHash < Mash; end

      class << self
        def plugin_hash_to_str(hash, spacing)
          hash.map do |k, v|
            ' '*spacing + "#{k.to_s} => " + self.value_to_str(v, spacing+2)
          end.join("\n")
        end

        def array_to_str(array, spacing)
          if array.size < 2
            ['[', self.value_to_str(array.first, spacing), ']'].join(' ')
          else
            result = "[\n"
            result << array.map do |v|
              ' '*spacing + self.value_to_str(v,spacing+2)
            end.join(",\n")
            result << "\n" + ' '*(spacing-2) + ']'
          end
        end

        def hash_to_str(hash, spacing)
          if hash.keys.size < 2
            ['{', hash.map {|k, v| %Q&"#{k}" => #{self.value_to_str(v, spacing)}&}, '}'].join(' ')
          else
            result = "{\n"
            result << hash.map do |k, v|
              ' '*spacing + %Q&"#{k}" => #{self.value_to_str(v, spacing+2)}&
            end.join(",\n")
            result << "\n" + ' '*(spacing-2) + '}'
          end
        end
      end

      def self.value_to_str(v, spacing)
        case v
        when PluginHash
          plugin_hash_to_str(v, spacing)
        when Hash
          hash_to_str(v, spacing)
        when Array
          array_to_str(v, spacing)
        when String, Symbol
          %Q("#{v}")
        when FalseClass, TrueClass, Fixnum, Float, NilClass
          v.to_s
        else
          v.inspect
        end
      end

      def self.plugin_pp(data, spacing=2)
        return '' if data.nil? || data.empty?
        # don't add the opening spacing (since it's been most likely positioned within ERB)
        phash = PluginHash[data]
        result = phash.delete(:_type).to_s + " {\n"
        result << self.value_to_str(phash, spacing+2)
        result << "\n" + ' '*spacing + '}'
      end
    end
  end
end

::Erubis::Context.send(:include, Logstash::ErubisHelper)
