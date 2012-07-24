# TimelineFu [![Build Status](https://secure.travis-ci.org/styx/timeline_fu.png?branch=master)](http://travis-ci.org/styx/timeline_fu) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/styx/timeline_fu)

Easily build timelines, much like GitHub's news feed.

## Usage

TimelineFu requires you to have a TimelineEvent model. 
The simplest way is to use the generator.

```
  $ script/generate timeline_fu && rake db:migrate
        exists  db/migrate
        create  db/migrate/20090333222034_create_timeline_events.rb
        create  app/models/timeline_event.rb
  # Migration blabber...
```

Next step is to determine what generates an event in your various models.

```ruby
  class Post < ActiveRecord::Base
    #...
    belongs_to :author, class_name: 'Person'
    fires :new_post, on: :create, actor: :author
  end
```

You can add 'fires' statements to as many models as you want on as many models
as you want. 

They are hooked for you after standard ActiveRecord events. In
the previous example, it's an after_create on Posts. 

### Parameters for #fires

You can supply a few parameters to fires, two of them are mandatory.
* the first param is a custom name for the event type. It'll be your way of figuring out what events your reading back from the timeline_events table later.
  * :new_post in the example

The rest all fit neatly in an options hash.

* on: [ActiveRecord event] 
  * mandatory. You use it to specify whether you want the event created after a create, update or destroy. You can also supply an array of events, e.g. [:create, :update].
* :actor is your way of specifying who took this action.
  * In the example, post.author is going to be this person.
* :subject is automatically set to self, which is good most of the time.  You can however override it if you need to, using :subject.
* :secondary_subject can let you specify something else that's related to the event. A comment to a blog post would be a good example.
* if: symbol or proc/lambda lets you put conditions on when a TimelineEvent is created. It's passed right to the after_xxx ActiveRecord event hook, so it's has the same behavior.
* event_class_name: string specifying the event class name (or an array of them) you'd like you use. Defaults to "TimelineEvent".
  * If you specify more than one event class name, an object for each will be created in the appropriate callbacks.
* any other parameter is treated as TimelineEvent's attribute
  * This is useful if you add a custom field to timeline_events table

Here's another example:

```ruby
  class Comment < ActiveRecord::Base
    #...
    belongs_to :commenter, :class_name => 'Person'
    belongs_to :post
    fires :new_comment, :on                 => :create,
                        :actor              => :commenter,
                        #implicit :subject  => self,
                        :secondary_subject  => 'post',
                        :if => lambda { |comment| comment.commenter != comment.post.author }
  end
```

### TimelineEvent instantiation

The ActiveRecord event hook will automatically instantiate a 
TimelineEvent instance for you.
It will receive the following parameters in #create!

* event_type 
  * "new_comment" in the comment example
* actor 
  * the commenter
* subject
  * the comment instance
* secondary_subject
  * the post instance

The generated model stores most of its info as polymorphic relationships.

```ruby
  class TimelineEvent < ActiveRecord::Base
    belongs_to :actor,              :polymorphic => true
    belongs_to :subject,            :polymorphic => true
    belongs_to :secondary_subject,  :polymorphic => true
  end
```

## How you actually get your timeline

To get your timeline you'll probably have to create your own finder SQL or scopes 
(if your situation is extremely simple). 

TimelineFu is not currently providing anything to generate your timeline because 
different situations will have wildly different requirements. Like access control 
issues and actually just what crazy stuff you're cramming in that timeline.

We're not saying it can't be done, just that we haven't done it yet. 
Contributions are welcome :-)

```ruby
## Get it

  # Gemfile
  gem "timeline_fu"

## License
```

Copyright (c) 2008 James Golick, released under the MIT license
