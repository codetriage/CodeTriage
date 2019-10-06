# frozen_string_literal: true

module DocsDoctor
  module Parsers
    module Ruby
      class Yard
        # we don't want any files in /test or /spec unless it's
        # for testing this codebase
        DEFAULT_EXCLUDE = ["(^|\/)test\/(?!fixtures)", "(^|\/)spec\/(?!fixtures)"]

        attr_reader :yard_objects
        attr_accessor :files, :base_path

        def initialize(base)
          @yard_objects = []
          @classes ||= []
          @base_path = base
        end

        def root_path
          root_path = Pathname.new(base_path).expand_path
          if root_path.to_s =~ /\.rb+$/
            root_path.dirname
          else
            root_path
          end
        end

        def store(repo)
          @yard_objects.each do |obj|
            store_entity(obj, repo)
          end
        end

        # YARD::CodeObjects::ModuleObject
        # YARD::CodeObjects::ClassObject
        # YARD::CodeObjects::ConstantObject
        # YARD::CodeObjects::MethodObject
        def store_entity(obj, repo)
          if obj.is_a? YARD::CodeObjects::MethodObject
            # attr_writer, attr_reader don't need docs
            # document original method instead
            # don't document initialize
            skip_write = obj.is_attribute? || obj.is_alias? || (obj.respond_to?(:is_constructor?) && obj.is_constructor?)
            skip_read = obj.docstring.strip.eql? ":nodoc:"

            method = repo.doc_methods.where(name: obj.name, path: obj.path).first_or_initialize
            method.assign_attributes(line: obj.line, file: obj.file, skip_write: skip_write, skip_read: skip_read) # line and file will change, do not want to accidentally create duplicate methods
            unless method.save
              Rails.logger.debug "Could not store YARD object, missing one or more properties: #{method.errors.inspect}"
              return false
            end

            method.doc_comments.where(comment: obj.docstring).first_or_create if obj.docstring.present?
          else
            Rails.logger.debug "Skipping storing non-method: #{obj.inspect}"
            return true
          end
        end

        def process(exclude = DEFAULT_EXCLUDE)
          require 'yard'
          yard = YARD::CLI::Yardoc.new

          # yard.files       = files
          yard.excluded    = exclude # http://rubydoc.org/gems/yard/YARD/Parser/SourceParser#parse-class_method
          yard.save_yardoc = false
          yard.generate    = false
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
          return false
        end
      end
    end
  end
end
