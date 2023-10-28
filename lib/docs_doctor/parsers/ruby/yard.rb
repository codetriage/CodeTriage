# frozen_string_literal: true

module DocsDoctor
  module Parsers
    module Ruby
      # This class is responsible for parsing Ruby Documentation and
      # storing it in the database. It uses yard under the hood
      #
      # Example:
      #
      #   `git clone https://github.com/schneems/get_process_mem`
      #   repo = Repo.where(full_name: "schneems/get_process_mem").first
      #
      #   parser = DocsDoctor::Parsers::Ruby::Yard.new("get_process_mem")
      #   parser.in_fork do
      #     parser.process
      #     parser.store(repo)
      #   end
      class Yard
        # we don't want any files in /test or /spec unless it's
        # for testing this codebase
        DEFAULT_EXCLUDE = ["(^|/)test/(?!fixtures)", "(^|/)spec/(?!fixtures)"]

        attr_reader :yard_objects
        attr_accessor :files, :base_path

        def initialize(base)
          @yard_objects = []
          @classes ||= []
          @base_path = base
          @time_now = Time.now.utc
        end

        def root_path
          root_path = Pathname.new(base_path).expand_path
          if /\.rb+$/.match?(root_path.to_s)
            root_path.dirname
          else
            root_path
          end
        end

        def store(repo)
          while @yard_objects.any?
            mega_upsert_method_array = []
            @yard_objects.pop(50).each do |obj|
              h = hash_for_entity(obj, repo)
              mega_upsert_method_array << h if h
            end
            DocMethod.upsert_all(mega_upsert_method_array,
              unique_by: [:repo_id, :name, :path])
          end
        end

        # YARD::CodeObjects::ModuleObject
        # YARD::CodeObjects::ClassObject
        # YARD::CodeObjects::ConstantObject
        # YARD::CodeObjects::MethodObject
        def hash_for_entity(obj, repo)
          if obj.is_a? YARD::CodeObjects::MethodObject
            # attr_writer, attr_reader don't need docs
            # document original method instead
            # don't document initialize
            skip_write = obj.is_attribute? || obj.is_alias? || (obj.respond_to?(:is_constructor?) && obj.is_constructor?)
            skip_read = obj.docstring.strip.eql? ":nodoc:"

            doc_method_hash = {
              name: obj.name,
              path: obj.path,
              line: obj.line,
              file: obj.file,
              skip_write: skip_write,
              skip_read: skip_read,
              comment: obj.docstring,
              has_comment: obj.docstring.present?,
              repo_id: repo.id,
              created_at: @time_now,
              updated_at: @time_now
            }

            if doc_method_hash[:file] && doc_method_hash[:name] && doc_method_hash[:path]
              doc_method_hash
            end
          end
        end

        def process(exclude = DEFAULT_EXCLUDE)
          require "yard"
          yard = YARD::CLI::Yardoc.new

          # yard.files       = files
          yard.excluded = exclude # http://rubydoc.org/gems/yard/YARD/Parser/SourceParser#parse-class_method
          yard.save_yardoc = false
          yard.generate = false
          # yard.use_cache = false'

          Dir.chdir(root_path) do
            YARD::Logger.instance.enter_level(Logger::FATAL) do
              yard.run(root_path.to_s)
            end
          end

          @yard_objects = YARD::Registry.all
          YARD::Registry.delete_from_disk
          YARD::Registry.clear
        rescue SystemStackError
          Rails.logger.debug "Yard blew up while trying to read from #{root_path}"
          false
        end

        def in_fork
          rd, wr = IO.pipe

          pid = fork do
            $stdout = wr
            $stderr = wr
            rd.close
            yield
            wr.close

            Kernel.exit!(0) # needed for https://github.com/seattlerb/minitest/pull/683
          end
          Process.waitpid(pid)

          wr.close
          if $?.success?
            puts rd.read
          else
            raise rd.read
          end
        end
      end
    end
  end
end
