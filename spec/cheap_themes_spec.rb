require 'spec/spec_helper'


class MyController < ActionController::Base
  def index
    render :text => "ziom"
  end
end

describe true.class do
it "should be true" do
true.should be_true
end
end
