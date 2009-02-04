require File.dirname(__FILE__) + '/spec_helper'
require 'machinist'


class Person < ActiveRecord::Base
  attr_protected :password
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :author, :class_name => "Person"
end

describe Machinist do
  describe "make method" do
    it "should set an attribute on the constructed object from a constant in the blueprint" do
      Person.blueprint do
        name "Fred"
      end
      Person.make.name.should == "Fred"
    end
  
    it "should set an attribute on the constructed object from a block in the blueprint" do
      Person.blueprint do
        name { "Fred" }
      end
      Person.make.name.should == "Fred"
    end
    
    it "should override an attribute from the blueprint with a passed-in attribute" do
      Person.blueprint do
        name "Fred"
      end
      Person.make(:name => "Bill").name.should == "Bill"
    end
    
    it "should allow overridden attribute names to be strings" do
      Person.blueprint do
        name "Fred"
      end
      Person.make("name" => "Bill").name.should == "Bill"
    end
    
    it "should not call a block in the blueprint if that attribute is passed in" do
      block_called = false
      Person.blueprint do
        name { block_called = true; "Fred" }
      end
      Person.make(:name => "Bill").name.should == "Bill"
      block_called.should be_false
    end
    
    it "should save the constructed object" do
      Person.blueprint { }
      person = Person.make
      person.should_not be_new_record
    end
    
    it "should create an associated object for an attribute with no arguments in the blueprint" do
      Post.blueprint { }
      Comment.blueprint { post }
      Comment.make.post.class.should == Post
    end
    
    it "should create an associated object for an attribute with an association class name" do
      Post.blueprint { }
      Comment.blueprint { author }
      Comment.make.author.class.should == Person
    end
    
    it "should call a passed-in block with the object being constructed" do
      Person.blueprint { }
      block_called = false
      Person.make do |person|
        block_called = true
        person.class.should == Person
      end
      block_called.should be_true
    end
    
    it "should provide access to the object being constructed from within the blueprint" do
      person = nil
      Person.blueprint { person = object }
      Person.make
      person.class.should == Person
    end
    
    it "should allow reading of a previously assigned attribute from within the blueprint" do
      Post.blueprint do
        title "Test"
        body { title }
      end
      Post.make.body.should == "Test"
    end
    
    it "should allow setting a protected attribute in the blueprint" do
      Person.blueprint do
        password "Test"
      end
      Person.make.password.should == "Test"
    end
    
    it "should allow overriding a protected attribute" do
      Person.blueprint do
        password "Test"
      end
      Person.make(:password => "New").password.should == "New"
    end
    
    it "should allow setting the id attribute in a blueprint" do
      Person.blueprint { id 12345 }
      Person.make.id.should == 12345
    end
    
    it "should allow setting the type attribute in a blueprint" do
      Person.blueprint { type "Person" }
      Person.make.type.should == "Person"
    end
  end
  
  describe "plan method" do
    it "should not save the constructed object" do
      person_count = Person.count
      Person.blueprint { }
      person = Person.plan
      Person.count.should == person_count
    end
    
    it "should save associated objects" do
      Post.blueprint { }
      Comment.blueprint { post }
      comment = Comment.plan
      comment[:post].should_not be_new_record
    end
  end
  
  describe "make_unsaved method" do
    it "should not save the constructed object" do
      Person.blueprint { }
      person = Person.make_unsaved
      person.should be_new_record
    end
    
    it "should not save associated objects" do
      Post.blueprint { }
      Comment.blueprint { post }
      comment = Comment.make_unsaved
      comment.post.should be_new_record
    end
    
    it "should save objects made within a passed-in block" do
      Post.blueprint { }
      Comment.blueprint { }
      comment = nil
      post = Post.make_unsaved { comment = Comment.make }
      post.should be_new_record
      comment.should_not be_new_record
    end
  end
end
