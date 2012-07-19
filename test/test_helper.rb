require 'rubygems'
require 'test/unit'
require 'mocha'
require 'logger'

$:.push File.expand_path('../lib', __FILE__)
require "timeline_fu"

ActiveRecord::Base.configurations = { 'sqlite': { adapter: 'sqlite3', database: ':memory:' } }
ActiveRecord::Base.establish_connection('sqlite3')

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::WARN

ActiveRecord::Schema.define(version: 0) do
  create_table :people do |t|
    t.string  :email,    default: ''
    t.string  :password, default: ''
  end

  create_table :lists do |t|
    t.integer :author_id
    t.string  :title
  end

  create_table :comments do |t|
    t.integer :list_id
    t.integer :author_id
    t.string  :body
  end

  create_table :sites do |t|
    t.string  :name
  end

  create_table :articles do |t|
    t.integer :site_id
    t.string :body
  end

  create_table :companies do |t|
    t.integer :owner_id
    t.string :name
  end
end

class Person < ActiveRecord::Base
  attr_accessor :new_watcher, :fire

  fires :follow_created,  on:     :update,
                          actor:  lambda { |person| person.new_watcher },
                          if:     lambda { |person| !person.new_watcher.nil? }
  fires :person_updated,  on:     :update,
                          if:     :fire?

  def fire?
    new_watcher.nil? && fire
  end
end

class List < ActiveRecord::Base
  belongs_to :author, class_name: "Person"
  has_many :comments

  fires :list_created_or_updated,  actor:  :author,
                                   on:     [:create, :update],
                                   callback: :callback_method
end

class Comment < ActiveRecord::Base
  belongs_to :list
  belongs_to :author, class_name: "Person"

  fires :comment_created, actor:   :author,
                          on:      :create,
                          secondary_subject: :list
  fires :comment_deleted, actor:   :author,
                          on:      :destroy,
                          subject: :list,
                          secondary_subject: :self
end

class Site < ActiveRecord::Base
end

class Article < ActiveRecord::Base
  belongs_to :author, class_name: "Person"
  belongs_to :site

  fires :article_created, actor: :author,
                          on:    :create,
                          site:  :site
end

class Company < ActiveRecord::Base
  belongs_to :owner, class_name: "Person"

  fires :company_created, actor:            :owner,
                          on:               :create,
                          event_class_name: "CompanyEvent"

  fires :company_updated, actor:            :owner,
                          on:               :update,
                          event_class_name: ["CompanyEvent", "IRSEvent"]
end

IRSEvent = Class.new
CompanyEvent = Class.new
TimelineEvent = Class.new

class Test::Unit::TestCase
  protected
    def hash_for_list(opts = {})
      { title: 'whatever' }.merge(opts)
    end

    def create_list(opts = {})
      List.create!(hash_for_list(opts))
    end

    def hash_for_person(opts = {})
      { email: 'james' }.merge(opts)
    end

    def create_person(opts = {})
      Person.create!(hash_for_person(opts))
    end
end
