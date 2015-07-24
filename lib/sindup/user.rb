module Sindup
  class User < Internal::Base

  	attr_reader :user_id
  	attr_accessor :email, :name, :firstname
  	attr_accessor :company, :function
  	attr_accessor :phone
  	attr_reader :created_at

    def initialize(options = {}, &block)
    	super(options)
    	@routes_actions = [:self, :edit, :delete]

    	@user_id = options["user_id"] || options[:user_id]
    	@email = options["email"] || options[:email]
    	@name = options["name"] || options[:name]
    	@firstname = options["firstname"] || options[:firstname]
    	@company = options["company"] || options[:company]
    	@function = options["function"] || options[:function]
    	@phone = options["phone"] || options[:phone]
    	@created_at = options["created_at"] || options[:created_at]
      yield self if block_given?
    end

    def initialize_routes_keys
      super(user_id: news_id)
    end

    def self.from_hash(h, o = {})
      super (h.has_key?("data") ? h["data"] : h), o
    end

    def inspect
      [
        "#<#{self.class.name}:#{self.object_id}",
        "@user_id=#{@user_id.inspect}",
        "@email=#{@email.inspect}",
        "@name=#{@name.inspect}",
        "@firstname=#{@firstname.inspect}",
        "@company=#{@company.inspect}",
        "@function=#{@function.inspect}",
        "@phone=#{@phone.inspect}",
        "@created_at=#{@created_at.inspect}",
        "@connection(#{@connection.nil? ? 'no' : 'yes'})>",
      ].join(", ")
    end

    private

    def primary_key() :user_id end

  end # !Result
end # !Sindup
