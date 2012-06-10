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

  describe 'with' do
    it 'returns the GH instance if no block is given' do
      GH.with(:token => "...").should be_a(GH::Wrapper)
    end

    it 'returns the block value if block is given' do
      GH.with(:token => "...") { 42 }.should be == 42
    end

    it 'propagates options' do
      GH.with(:a => :b) do
        GH.with(:b => :c) do
          GH.options.should be == {:a => :b, :b => :c}
        end
      end
    end
  end
end
