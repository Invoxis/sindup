module Sindup
  class Result < Internal::Base

    attr_reader :news_id
    attr_reader :source_name, :source_url
    attr_reader :language
    attr_reader :headline, :summary, :body
    attr_reader :author
    attr_reader :published_at
    attr_reader :read_tracking_url, :read_url, :appli_url
    attr_reader :tag_list

    def initialize(options = {}, &block)
      super(options)
      @news_id = options["news_id"] || options[:news_id]
      @source_name = (options["source"]["name"] rescue nil) || options[:source_name]
      @source_url = (options["source"]["name"] rescue nil) || options[:source_url]
      @language = options["language"] || options[:language]
      @headline = options["headline"] || options[:headline]
      @summary = options["summary"] || options[:summary]
      @body = options["body"] || options[:body]
      @author = options["author"] || options[:author]
      @published_at = options["published_at"] || options[:published_at]
      @read_tracking_url = options["read_tracking_url"] || options[:read_tracking_url]
      @read_url = options["read_url"] || options[:read_url]
      @appli_url = options["appli_url"] || options[:appli_url]
      @tag_list = options["tag_list"] || options[:tag_list]
      yield self if block_given?
    end

    def initialize_routes_keys
      super(news_id: news_id)
    end

    def self.from_hash(h, o = {})
      super (h.has_key?("data") ? h["data"] : h), o
    end

    def inspect
      [
        "#<#{self.class.name}:#{self.object_id}",
        "@news_id=#{@news_id.inspect}",
        "@source_name=#{@source_name.inspect}",
        "@source_url=#{@source_url.inspect}",
        "@language=#{@language.inspect}",
        "@headline=#{@headline.inspect}",
        "@summary=#{@summary.inspect}",
        "@body=#{@body.inspect}",
        "@author=#{@author.inspect}",
        "@published_at=#{@published_at.inspect}",
        "@read_tracking_url=#{@read_tracking_url.inspect}",
        "@read_url=#{@read_url.inspect}",
        "@appli_url=#{@appli_url.inspect}",
        "@tag_list=#{@tag_list.inspect}",
        "@connection(#{@connection.nil? ? 'no' : 'yes'})>",
      ].join(", ")
    end

    private

    def primary_key() :news_id end

  end # !Result
end # !Sindup
