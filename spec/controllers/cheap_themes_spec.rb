require 'spec/spec_helper'

describe Example1Controller, "not finding theme" do
  integrate_views

  it "should render action normally when theme is null" do
    get :index
    response.should have_text("Hello\n")
  end
end

describe Example1Controller, "views tests" do
  integrate_views

  it "should render action normally when theme is null" do
    @controller.should_receive(:find_view_theme).and_return(nil)
    get :index
    response.should have_text("Hello\n")
  end

  it "should render themed action when theme is present" do
    @controller.should_receive(:find_view_theme).and_return("ex_th")
    get :index
    response.should have_text("This is new theme\n")
  end

end

describe Example1Controller, "action tests" do
  integrate_views

  it "should render action normally when theme is null" do
    @controller.should_receive(:find_view_theme).and_return(nil)
    @controller.should_receive(:find_action_theme).and_return(nil)
    get :index
    response.should have_text("Hello\n")
  end

  it "should render themed action when theme is present" do
    @controller.should_receive(:find_view_theme).and_return(nil)
    @controller.should_receive(:find_action_theme).exactly(2).times.and_return("ex_th")
    get :index
    response.should have_text("This is some other template\n")
  end

  it "should cache themed action when theme is present" do
    @controller.should_receive(:find_view_theme).exactly(1).times.and_return(nil)
    @controller.should_receive(:find_action_theme).exactly(2).times.and_return("ex_th")
    get :index
    response.should have_text("This is some other template\n")
    @controller.should respond_to(:cheap_themes_customized_action_ex_th_example1_index) 
  end
end

