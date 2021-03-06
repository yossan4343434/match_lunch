# This file was auto-generated by lib/generators/tasks/generate.rb

module Slack
  module Endpoint
    module Discovery
      #
      # There is no documentation for this method.
      #
      # @option options [Object] :file
      #   Specify a file by providing its ID.
      # @see https://api.slack.com/methods/discovery.file
      # @see https://github.com/aki017/slack-api-docs/blob/master/methods/discovery.file.md
      # @see https://github.com/aki017/slack-api-docs/blob/master/methods/discovery.file.json
      def discovery_file(options={})
        throw ArgumentError.new("Required arguments :file missing") if options[:file].nil?
        post("discovery.file", options)
      end

    end
  end
end
