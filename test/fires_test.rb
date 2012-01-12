require File.dirname(__FILE__)+'/test_helper'

class FiresTest < Test::Unit::TestCase
  def setup
    @james = create_person(:email => 'james@giraffesoft.ca')
    @mat   = create_person(:email => 'mat@giraffesoft.ca')
  end
  
  def test_should_fire_the_appropriate_callback
    @list = List.new(hash_for_list(:author => @james));
    TimelineEvent.expects(:create!).with(:actor => @james, :subject => @list, :event_type => 'list_created_or_updated')
    @list.save
    TimelineEvent.expects(:create!).with(:actor => @mat, :subject => @list, :event_type => 'list_created_or_updated')
    @list.author = @mat
    @list.save
  end

  def test_should_fire_event_with_secondary_subject
    @list = List.new(hash_for_list(:author => @james));
    TimelineEvent.stubs(:create!)
    @list.save
    @comment = Comment.new(:body => 'cool list!', :author => @mat, :list => @list)
    TimelineEvent.expects(:create!).with(:actor             => @mat, 
                                         :subject           => @comment, 
                                         :secondary_subject => @list, 
                                         :event_type        => 'comment_created')
    @comment.save
  end

  def test_exception_raised_if_on_missing
    # This needs to be tested with should_raise, to check out the msg content
    assert_raise(ArgumentError) do
      some_class = Class.new(ActiveRecord::Base)
      some_class.class_eval do
        attr_accessor :someone
        fires :some_event, :actor => :someone
      end
    end
  end

  def test_should_only_fire_if_the_condition_evaluates_to_true
    TimelineEvent.expects(:create!).with(:actor => @mat, :subject => @james, :event_type => 'follow_created')
    @james.new_watcher = @mat
    @james.save
  end
  
  def test_should_not_fire_if_the_if_condition_evaluates_to_false
    TimelineEvent.expects(:create!).never
    @james.new_watcher = nil
    @james.save
  end
  
  def test_should_fire_event_with_symbol_based_if_condition_that_is_true
    @james.fire = true
    TimelineEvent.expects(:create!).with(:subject => @james, :event_type => 'person_updated')
    @james.save
  end
  
  def test_should_fire_event_with_symbol_based_if_condition
    @james.fire = false
    TimelineEvent.expects(:create!).never
    @james.save
  end

  def test_should_set_secondary_subject_to_self_when_requested
    @list = List.new(hash_for_list(:author => @james));
    TimelineEvent.stubs(:create!).with(has_entry(:event_type, "list_created_or_updated"))
    @list.save
    @comment = Comment.new(:body => 'cool list!', :author => @mat, :list => @list)
    TimelineEvent.stubs(:create!).with(has_entry(:event_type, "comment_created"))
    @comment.save
    TimelineEvent.expects(:create!).with(:actor             => @mat, 
                                         :subject           => @list, 
                                         :secondary_subject => @comment, 
                                         :event_type        => 'comment_deleted')
    @comment.destroy
  end


  def test_should_set_additional_attributes_when_present
    @site = Site.create(:name => 'foo.com')
    @article = Article.new(:body => 'cool article!', :author => @james, :site => @site)
    TimelineEvent.expects(:create!).with(:actor => @james, :subject => @article, :event_type => 'article_created', :site => @site)
    @article.save
  end

  def test_should_use_specified_event_class_when_present
    @company = Company.new(:owner => @james, :name => 'A great company!')
    CompanyEvent.expects(:create!).with(:actor => @james, :subject => @company, :event_type => 'company_created')
    @company.save
  end

  def test_should_support_specifying_multiple_event_classes
    CompanyEvent.stubs(:create!)
    @company = Company.create(:owner => @james, :name => 'A great company!')
    CompanyEvent.expects(:create!).with(:actor => @james, :subject => @company, :event_type => 'company_updated')
    IRSEvent.expects(:create!).with(:actor => @james, :subject => @company, :event_type => 'company_updated')
    @company.save
  end

  def test_should_fire_callback_hook_after_each_event
    @list = List.new(hash_for_list(:author => @james))
    def @list.callback_method(e); true; end
    event = TimelineEvent.new
    TimelineEvent.expects(:create!).with(:actor => @james, :subject => @list, :event_type => 'list_created_or_updated').returns(event)
    @list.expects(:callback_method).with(event)
    @list.save
  end
end
