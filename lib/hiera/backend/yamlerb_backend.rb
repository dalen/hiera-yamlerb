class Hiera
  module Backend
    class Yamlerb_backend
      class ErbWrapper
        def initialize(scope, code)
          @code = code
          scope.to_hash.each do |name, value|
            realname = name.gsub(/[^\w]/, "_")
            instance_variable_set("@#{realname}", value)
          end
        end

        def build
          b = binding
          ERB.new(@code).result b
        end
      end

      def initialize(cache=nil)
        require 'yaml'
        require 'erb'

        Hiera.debug("Hiera YAML+ERB backend starting")

        @cache = cache || Filecache.new
      end

      def lookup(key, scope, order_override, resolution_type)
        answer = nil

        Hiera.debug("Looking up #{key} in YAML+ERB backend")

        Backend.datasourcefiles(:yamlerb, scope, "yaml.erb", order_override) do |source, erbfile|
          data = @cache.read_file(erbfile, Hash) do |code|
            wrapper = ErbWrapper.new(scope, code)
            begin
              YAML.load(wrapper.build) || {}
            rescue => detail
              info = detail.backtrace.first.split(':')
              raise Exception, "Failed to parse ERB #{file}:\n  Filepath: #{info[0]}\n  Line: #{info[1]}\n  Detail: #{detail}\n"
            end
          end

          next if data.empty?
          next unless data.include?(key)

          # Extra logging that we found the key. This can be outputted
          # multiple times if the resolution type is array or hash but that
          # should be expected as the logging will then tell the user ALL the
          # places where the key is found.
          Hiera.debug("Found #{key} in #{source}")

          # for array resolution we just append to the array whatever
          # we find, we then goes onto the next file and keep adding to
          # the array
          #
          # for priority searches we break after the first found data item
          new_answer = Backend.parse_answer(data[key], scope)
          case resolution_type
          when :array
            raise Exception, "Hiera type mismatch for key '#{key}': expected Array and got #{new_answer.class}" unless new_answer.kind_of? Array or new_answer.kind_of? String
            answer ||= []
            answer << new_answer
          when :hash
            raise Exception, "Hiera type mismatch for key '#{key}': expected Hash and got #{new_answer.class}" unless new_answer.kind_of? Hash
            answer ||= {}
            answer = Backend.merge_answer(new_answer,answer)
          else
            answer = new_answer
            break
          end
        end

        return answer
      end

      private

      def file_exists?(path)
        File.exist? path
      end
    end
  end
end
