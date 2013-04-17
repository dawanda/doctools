**Note**: _This is not very user-friendly at the moment. This notice will be
removed when the project is deemed "usable by most people without needing to
write their own webserver stuff"._

This repo contains various tools to help with writing and reading
documentation. It's not an API documentation tool like YARD, since its main
purpose at this time is to render the README of a project with various
additional bonuses.

## Usage

TODO: Not quite ready yet

What needs to be done:

- `doctools clone <username>/<project>` to clone a github repo
- `doctools sync` to update all repos to their latest git master
- `doctools server` to start a simple sinatra app that serves the checked-out repos

## Features

### Github linking

If you refer to class names, function names, or file paths from the project,
wrapped in backticks, they will be linked to github. Example:

``` markdown
A `User` can have only one `Shop`. To create the shop for a user, call the
method `create_shop`. You can find this in `app/models/user.rb`.
```

You don't have to go out of your way to include as many references as you can
-- just mention entities that can be referred to for deeper detail on a topic.

Note that this feature uses Ctags, which means it's a bit flawed. It will be
worked on more in the future.

### Inline Documentation

If you refer to an entity in the above way, and that entity is documented with
a simple comment block before it, that comment will be displayed as a tooltip
when you hover over it. To get this to work, all you need to do is write the
actual comment. Example:

``` ruby
module App
  # This model provides methods to calculate various listing fees applicable to
  # products. It's initialized with a collection of Product objects and a User
  # and all calculations are performed in the context of these items. It is
  # immutable -- create a new ListingFeeCalculator for a different set of
  # inputs.
  #
  class ListingFeeCalculator
    # ...
  end
end
```

In some cases, this could be overkill, but in many situations the act of
writing the comment could help you crystallize the role of the class in the
application. It's recommended to keep it short. If it's impossible to fit the
responsibilities of the class in as little as this, it may be a good idea to
consider splitting the class.

### Pretty relationship graphs

If you'd like to document relationships between entities, you can write a list
of relationships like this:

``` markdown
- User has one Cart
- Cart has many CartItems
- User has many Checkouts (but only one active)
```

If you want a nice GraphViz graph to be generated to help visualize the
relationship, all you need to do is use the forms:

- X has one Y
- X has many Ys

And, wrap the list in dummy `+` items:

``` markdown
- +
- User has one Cart
- Cart has many CartItems
- User has many Checkouts (but only one active)
- +
```

If you think that the generated graph is too large and difficult to understand,
you can split it by concerns by simply wrapping parts of the list in `+`
delimiters:

``` markdown
- +
- User has one Cart
- Cart has many CartItems
- User has many Checkouts (but only one active)
- +
- +
- Checkout has many CheckoutSellers (one for each seller in CartItems)
- Checkout has many CheckoutItems (one for every CartItem)
- CheckoutSeller has many CheckoutItems
- +
```

The reason this is not automatically inferred from models is that models have
*a lot* of relationships, most of which are only interesting for particular use
cases. This is why explaining the relationships that are relevant for a
specific piece of business logic should be done in the documentation.

### Include some additional info within a markdown file

The `MarkdownIncluder` class processes a markdown file and replaces calls to
the pseudo-helper `@include` with some predefined automagical content. This
content is always up-to-date, since it's generated directly from the code, so
it's generally quite safe to rely on it. You might want to leave some spaces
before the `@include` call in order to make the text look like code.

Currently, the following includes are implemented:

- `@include rake`. This executes a `rake -T` in the repository and puts the
  list of rake tasks in its place. At this time, it doesn't work well enough
  and should be significantly improved.

- `@include sinatra(file/name.rb)`. This processes the given filename as a
  sinatra service and looks for `get`, `post` and so on, to generate a short
  description of the service's API.
