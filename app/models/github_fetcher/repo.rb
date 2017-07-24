module GithubFetcher
  class Repo < Resource
    def initialize(options)
      @api_path = File.join(
        'repos',
        options.delete(:user_name),
        options.delete(:name),
      )
      super
    end

    def default_branch
      as_json['default_branch']
    end

    # TODO - does this really belong here? Seems like it (and Repo#populate_docs!)
    #   should move into the PopulateDocs job
    def clone
      `cd #{dir} && git clone #{clone_url} 2>&1`
      return dir
    end

    private

    # TODO - moves w/ clone
    def dir
      @dir ||= Dir.mktmpdir
    end

    # TODO - moves w/ clone
    def clone_url
      as_json["clone_url"]
    end

    # TODO - this appears to be uncalled... remove? or do we need it and should use it?
    def cleanup
      FileUtils.remove_entry(dir)
    end
  end
end
