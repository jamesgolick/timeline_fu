require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'TimelineFu' do

  let(:james) { create_person(email: 'james@giraffesoft.ca') }
  let(:mat)   { create_person(email: 'mat@giraffesoft.ca')   }
  let(:list)  { List.new hash_for_list(author: james)        }

  let(:anonumous_model) { Class.new(ActiveRecord::Base) }

  it 'should fail with ArgumentError if :on is not specified in callback' do
    expect do
      anonumous_model.class_eval do
        attr_accessor :someone
        fires :some_event, actor: :someone
      end
    end.to raise_error(ArgumentError, 'Argument :on is mandatory')
  end

  context 'with conditions' do
    it 'should fire if conditions are true' do
      TimelineEvent.should_receive(:create!).with(actor: mat, subject: james, event_type: 'follow_created')
      james.new_watcher = mat
      james.save
    end

    it 'should not fire if conditions are false' do
      TimelineEvent.should_not_receive(:create!)
      james.new_watcher = nil
      james.save
    end

    it 'should fire event if :if condition is true' do
      james.fire = true
      TimelineEvent.should_receive(:create!).with(subject: james, event_type: 'person_updated')
      james.save
    end

    it 'should not fire event if :if condition is false' do
      james.fire = false
      TimelineEvent.should_not_receive(:create!).with(subject: james, event_type: 'person_updated')
      james.save
    end
  end

  it 'should fire event with secondary subject' do
    list = List.new(hash_for_list(author: james));
    TimelineEvent.should_receive(:create!).with(actor: james, subject: list, event_type: 'list_created_or_updated')
    list.save

    comment = Comment.new(body: 'cool list!', author: mat, list: list)
    TimelineEvent.should_receive(:create!).with(actor: mat, subject: comment, secondary_subject: list, event_type: 'comment_created')
    comment.save
  end

  it 'should use specified event class when present' do
    company = Company.new(owner: james, name: 'A great company!')
    CompanyEvent.should_receive(:create!).with(actor: james, subject: company, event_type: 'company_created')
    company.save
  end

  it 'should support specifying multiple event classes' do
    CompanyEvent.should_receive(:create!)
    company = Company.create(owner: james, name: 'A great company!')

    CompanyEvent.should_receive(:create!).with(actor: james, subject: company, event_type: 'company_updated')
    IRSEvent.should_receive(:create!).with(actor: james, subject: company, event_type: 'company_updated')

    company.save
  end

  it 'should set additional attributes when present' do
    site = Site.create(name: 'foo.com')
    article = Article.new(body: 'cool article!', author: james, site: site)

    TimelineEvent.should_receive(:create!).with(actor: james, subject: article, event_type: 'article_created', site: site)

    article.save
  end

  it 'should fire the appropriate callback' do
    TimelineEvent.should_receive(:create!).with(actor: james, subject: list, event_type: 'list_created_or_updated')
    list.save

    TimelineEvent.should_receive(:create!).with(actor: mat, subject: list, event_type: 'list_created_or_updated')
    list.author = mat
    list.save
  end

  it 'should fire callback hook after each event' do
    event = TimelineEvent.new

    TimelineEvent.should_receive(:create!).with(actor: james, subject: list, event_type: 'list_created_or_updated').and_return(event)
    list.should_receive(:callback_method).with(event)

    list.save
  end

  it 'should set secondary subject to self when requested' do
    site = Site.new(name: 'foo.com')
    article = Article.new(body: 'cool article!', author: james, site: site)

    TimelineEvent.should_receive(:create!).with(actor: james, subject: list, event_type: 'list_created_or_updated')
    list.save

    comment = Comment.new(body: 'cool list!', author: mat, list: list)
    TimelineEvent.should_receive(:create!).with(actor: mat, subject: comment, secondary_subject: list, event_type: 'comment_created')
    comment.save

    TimelineEvent.should_receive(:create!).with(actor: mat, subject: list, secondary_subject: comment, event_type: 'comment_deleted')
    comment.destroy
  end

end
