require 'spec_helper'

describe GH::Remote do
  it 'loads resources from github' do
    stub_request(:get, "https://api.github.com/foo").to_return(:body => '["foo"]')
    subject['foo'].to_s.should be == '["foo"]'
  end

  it 'sets headers correctly' do
    stub_request(:get, "https://api.github.com/foo").to_return(:headers => {'X-Foo' => 'bar'}, :body => '[]')
    subject['foo'].headers['x-foo'].should be == 'bar'
  end

  it 'raises an exception for missing resources' do
    stub_request(:get, "https://api.github.com/foo").to_return(:status => 404)
    expect { subject['foo'] }.to raise_error(Faraday::Error::ResourceNotFound)
  end

  it 'parses the body' do
    stub_request(:get, "https://api.github.com/foo").to_return(:body => '{"foo":"bar"}')
    subject['foo']['foo'].should be == 'bar'
  end
end
