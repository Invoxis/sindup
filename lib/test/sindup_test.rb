require 'test/test_helper'

describe Sindup do


  describe Sindup::Authorization::Token do

    before do
      params = ["myToken", "myRefreshToken", Time.now]
      @token = Sindup::Authorization::Token.new(*params)
    end

    it "should have instantiated the token" do
      assert @token
    end

    it "should have saved my params" do
      assert_equal "myToken", @token.token
      assert_equal "myRefreshToken", @token.refresh_token
      assert_instance_of Time, @token.expires_at
    end

  end # !Sindup::Authorization::Token


  it "must be instantiated with required parameters" do

    describe "like client credentials" do

      describe "no param" do
        ->() do
          Sindup.new
        end.must_raise ArgumentError
      end # !"no param"

      describe "w/ app_id" do
        err = ->() do
          options = {
            app_id: 'myAppId'
          }
          Sindup.new(options)
        end.must_raise ArgumentError
        err.message.must_match(/Missing client credentials/)
      end # !"w/ app_id"

      describe "w/ app_secret" do
        err = ->() do
          options = {
            app_secret: 'myAppSecret'
          }
          Sindup.new(options)
        end.must_raise ArgumentError
        err.message.must_match(/Missing client credentials/)
      end # !"w/ app_secret"

      describe "w/ app_id & app_secret" do
        err = ->() do
          options = {
            app_id: 'myAppId',
            app_secret: 'myAppSecret'
          }
          Sindup.new(options)
        end.must_raise ArgumentError
        err.message.must_match(/Missing auth/)
      end # !"w/ app_id & app_secret"
      
    end # !"like client credentials"

    describe "like auth" do

      describe "using token" do

        describe "w/o token" do
          err = ->() do
            options = {
              app_id: 'myAppId',
              app_secret: 'myAppSecret',
              auth: {}
            }
            Sindup.new(options)
          end.must_raise ArgumentError
          err.message.must_match(/Missing auth/)
        end # !"w/o token"

        describe "w/o valid token" do
          ->() do
            options = {
              app_id: 'myAppId',
              app_secret: 'myAppSecret',
              auth: { token: nil }
            }
            Sindup.new(options)
          end.must_raise NoMethodError
        end # !"w/o valid token"

        describe "w/ token" do
          it "should work" do
            options = {
              app_id: 'myAppId',
              app_secret: 'myAppSecret',
              auth: { token: get_token }
            }
            assert Sindup.new(options)
          end
        end # !"w/ token"

      end # !"using token"
      
      describe "using email:password" do
        
        describe "w/o string" do
          err = ->() do
            options = {
              app_id: 'myAppId',
              app_secret: 'myAppSecret',
              auth: {}
            }
            Sindup.new(options)
          end.must_raise ArgumentError
          err.message.must_match(/Missing auth/)
        end # !"w/o token"

        describe "w/o valid string" do
          ->() do
            options = {
              app_id: 'myAppId',
              app_secret: 'myAppSecret',
              auth: { basic: nil }
            }
            Sindup.new(options)
          end.must_raise NoMethodError
        end # !"w/o valid token"

        describe "w/ string" do
          err = ->() do
            options = {
              app_id: 'myAppId',
              app_secret: 'myAppSecret',
              auth: { basic: "my@email.com:myPassword" }
            }
            Sindup.new(options)
          end.must_raise ArgumentError
          err.message.must_match(/Missing redirect url/)
        end # !"w/ string"

      end # !"using email:password"

    end # !"like auth"

    describe "like authorize_url" do

      describe "w/o valid string" do
        err = ->() do
          options = {
            app_id: 'myAppId',
            app_secret: 'myAppSecret',
            auth: { basic: "my@email.com:myPassword" },
            authorize_url: { redirect_url: nil }
          }
          Sindup.new(options)
        end.must_raise ArgumentError
        err.message.must_match(/Missing redirect url/)
      end

      describe "w/ redirect_url" do
        it "should work" do
          options = {
            app_id: 'myAppId',
            app_secret: 'myAppSecret',
            auth: { basic: "my@email.com:myPassword" },
            authorize_url: { redirect_url: "http://mySite.com/myRedirectUrl" }
          }
          assert Sindup.new(options)
        end
      end # !"w/ redirect_url"

    end

  end # !"must be instantiated with required parameters"


end # !Sindup

require 'test/folder_test'
