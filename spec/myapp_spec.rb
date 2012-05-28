require File.dirname(__FILE__) + '/spec_helper'

describe 'pdns-ui' do
  include Rack::Test::Methods

  def app
    App
  end

  it 'should run a simple test' do
    get '/'
    last_response.status.should == 200
  end


  it 'About page should show title' do
    get '/about'
    last_response.status.should == 200 
    last_response.body.should =~ /About this Project/
  end
end
