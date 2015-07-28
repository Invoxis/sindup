module Sindup
  class User < Internal::Base

    attr_reader :user_id
    attr_accessor :email, :password
    attr_accessor :role
    attr_accessor :name, :firstname, :gender
    attr_accessor :company, :function, :group_id
    attr_accessor :phone
    attr_reader :created_at
    attr_reader :send_email
    attr_reader :client_id

    def initialize(options = {}, &block)
      super(options)
      @routes_actions = [:self, :edit, :delete]

      @user_id = options["user_id"] || options[:user_id]
      @email = options["email"] || options[:email]
      @password = options["password"] || options[:password]
      @role = options["role"] || options[:role]
      @name = options["name"] || options[:name]
      @firstname = options["firstname"] || options[:firstname]
      @gender = options["gender"] || options[:gender]
      @company = options["company"] || options[:company]
      @function = options["function"] || options[:function]
      @group_id = options["group_id"] || options[:group_id]
      @phone = options["phone"] || options[:phone]
      @created_at = options["created_at"] || options[:created_at]
      @send_email = true
      yield self if block_given?
    end

    def initialize_routes_keys
      super(user_id: user_id)
      @client_id = @connection.client_id
    end

    def self.from_hash(h, o = {})
      super (h.has_key?("data") ? h["data"] : h), o
    end

    def inspect
      [
        "#<#{self.class.name}:#{self.object_id}",
        "@user_id=#{@user_id.inspect}",
        "@email=#{@email.inspect}",
        "@password=#{@password.inspect}",
        "@role=#{@role.inspect}",
        "@name=#{@name.inspect}",
        "@firstname=#{@firstname.inspect}",
        "@gender=#{@gender.inspect}",
        "@company=#{@company.inspect}",
        "@function=#{@function.inspect}",
        "@group_id=#{@group_id.inspect}",
        "@phone=#{@phone.inspect}",
        "@created_at=#{@created_at.inspect}",
        "@send_email=#{@send_email.inspect}",
        "@connection(#{@connection.nil? ? 'no' : 'yes'})>",
      ].join(", ")
    end

    def primary_key() :user_id end

  end # !Result
end # !Sindup
