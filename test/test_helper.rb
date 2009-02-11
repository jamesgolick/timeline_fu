require 'rubygems'
require 'activerecord'
require 'mocha'
require 'test/unit'
require 'logger'

require File.dirname(__FILE__)+'/../lib/timeline_fu'

ActiveRecord::Base.configurations = {'sqlite3' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('sqlite3')

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::WARN

ActiveRecord::Schema.define(:version => 0) do
  create_table :people do |t|
    t.string  :email,    :default => ''
    t.string  :password, :default => ''
  end
  
  create_table :lists do |t|
    t.integer :author_id
    t.string  :title
  end
end

class Person < ActiveRecord::Base
  has_timeline
  attr_accessor :new_watcher, :fire
  
  fires :follow_created,  :on     => :update, 
                          :actor  => :new_watcher, 
                          :target => :self, 
                          :if     => lambda { |person| !person.new_watcher.nil? }
  fires :person_updated,  :on     => :update, 
                          :actor  => :self, 
                          :target => :self, 
                          :if     => :fire?
  
  def fire?
    new_watcher.nil? && fire
  end
end

class List < ActiveRecord::Base
  belongs_to :author, :class_name => "Person"
  
  fires :list_created,  :actor            => :author, 
                        :secondary_target => :self, 
                        :target           => :self, 
                        :on               => :create
end

TimelineEvent = Class.new

class Test::Unit::TestCase
  protected
    def hash_for_list(opts = {})
      {:title => 'whatever'}.merge(opts)
    end
    
    def create_list(opts = {})
      List.create!(hash_for_list(opts))
    end
    
    def hash_for_person(opts = {})
      {:email => 'james'}.merge(opts)
    end
    
    def create_person(opts = {})
      Person.create!(hash_for_person(opts))
    end
end
