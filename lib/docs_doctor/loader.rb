# loads parsers for different languages and tools
module DocsDoctor
  class Loader
    attr_accessor :name, :version, :lang

    def initialize(parser_lang_name, version)
      @lang, @name = parser_lang_name.to_s.downcase.split("/")
      @version     = Gem::Version.new version
      load_parser
    end

    def parser
      require self.path
      return constant.new
    end

    def constant
      Kernel.const_get "DocsDoctor::Parsers::#{lang.capitalize}::#{name.capitalize}_#{pretty_version}"
    end

    # parsers/ruby/rdoc.rb
    def path
      [__dir__, 'parsers', lang, name_extension].join('/')
    end

    def load_parser
      case lang
      when "ruby"
        Ruby.new(name, version).load
      else
        raise "looks like parser for language #{lang} is not yet implemented"
      end
    end

    private

    def name_extension
      name + dot_extension
    end

    def dot_extension
      @extension = extension
      @extension.prepend('.rb') unless @extension.include?('.')
      @extension
    end

    def pretty_version
      version.to_s.tr('.', '_')
    end
  end
end
