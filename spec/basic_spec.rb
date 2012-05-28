require File.dirname(__FILE__) + '/spec_helper'

def app
  App
end

describe 'basic page loading and routing' do
  it 'should load the "about" page' do
    get '/about'
    last_response.should be_ok
    last_response.body.should =~ /About this Project/
  end

  it 'should load proper 404 page' do
    get '/notexistent'
    last_response.should_not be_ok
    last_response.body.should =~ /something went wrong/
  end

end
