# Sindup

This is a wrap of sindup.com API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sindup', github: 'etrnljg/sindup'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sindup

## Usage

### Instantiate the client.

You have yet two different ways to instantiate your client.

#### If you got a valid token/refresh-token pair.

```ruby
t = Sindup::Authorization::Token.new "token", "refresh-token", Time.at(1437995506)
s = Sindup.new(app_id: "myAppId", app_secret: "myAppSecret", auth: { token: t })
```

#### If you know your user ids

```ruby
options = {
	app_id: "myAppId", app_secret: "myAppSecret",
	auth: { basic: "myEmail:myPassword" },
	authorize_url: { redirect_url: "myOAuth2CallbackUrl" }
}
s = Sindup.new(options)
```

#### Note

More options are available for `authorize_url` hash :
- `token_url`
- `authorize_url`

### Retrieve your current token

If you prefer to save in your database a token instead of your ids, you could retrieve your token using
```ruby
s.current_token
 => #<Sindup::Authorization::Token:0x00000003749138 @token="myToken", @refresh_token="myRefreshToken", @expires_at=2015-07-27 13:11:46 +0200>
```

### Collections

All different objects are associated to collections.

Your client could have several folders.
Your client can access to its neighbor users.
A folder could have several collect filters and results.

```ruby
s.users
 => #<Sindup::Collection::User:0x0000000369ea80>
s.folders
 => #<Sindup::Collection::Folder:0x000000036a2658>
```

#### Laziness

All collections are "lazy". Their data is not loaded until you ask for.
You can't retrieve all objects by once. You can only iterate over each of them using `each` method.
```ruby
s.folders.each { |folder|  }
 => {:cursor=>nil, :total_queries=>1, :total_markers=>0, :total_initialized_items=>15, :total_different_initialized_items=>15, :total_matching_initialized_items=>15} 
```
Instead, you get statistics on what you have iterated.

#### Criterias

You can specify criterias to select items matching your needs.
Just use the `where` function on your collection.
Note that you have to give the function `Procs`

```ruby
s.folders.where(->(fo) { fo.name.include?("test") })
 => #<Sindup::Collection::Folder:0x000000027f8be8>
```

In case you don't want to iterate on results you have already seen, you can specify an endpoint.
It could be the id of the last item you know...
```ruby
s.folders.until(42)
 => #<Sindup::Collection::Folder:0x00000002739108>
```
... or a condition :
```ruby
s.folders.until(->(fo) { fo.id <= 42 })
 => #<Sindup::Collection::Folder:0x00000002739108>
```

Unlike criterias, you can't chain end-criterias. Only the last provided is used.

### Models

Each object correctly instantiated inherits of the internal connection object that make them queryable.

#### Instantiating

You can instantiate an object from its dedicated collection.
```ruby
fo = s.folders.new(folder_id: 42, name: "folderName", description: "folderDescription")
```
The object will then be able to process basic queries like pushing its modifications.

#### Updating

To push your modifications, just use the `save` method.
```ruby
fo.name = "newFolderName"
fo.save
```

#### Creation

You can either use the `create` method on a collection...
```ruby
fo = s.folders.create(name: "folderName")
```
... or save an object that don't have any primary key setted :
```ruby
fo = s.folders.new(name: "folderName")
fo = fo.save
```

Note that to create a user, you will need
- the correct access rights
- to provide your `client_id` when instantiating your client.

## Contributing

1. Fork it ( https://github.com/etrnljg/sindup/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
