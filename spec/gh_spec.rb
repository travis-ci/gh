require 'spec_helper'

describe GH do
  it 'allows doing requests right from the GH object' do
    GH['users/rkh']['name'].should be == "Konstantin Haase"
  end

  it 'allows posting to github' do
    stub_request(:post, "https://api.github.com/somewhere").
      with(:body => "{\"foo\":\"bar\"}").to_return(:status => 200, :body => '{"hi": "ho"}', :headers => {})
    response = GH.post "somewhere", "foo" => "bar"
    response['hi'].should be == 'ho'
  end
end
