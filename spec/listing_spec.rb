require File.dirname(__FILE__) + '/spec_helper'

def app
  App
end

describe 'pdns-ui listing records' do
  it 'should load the main page' do
    get '/'
    last_response.should be_ok
  end

  it 'should load proper 404 page' do
    get '/notexistent'
    last_response.should_not be_ok
    last_response.body.should =~ /something went wrong/
  end

end
