require 'spec_helper'

describe GH::Cache do
  before { subject.backend = GH::MockBackend.new }

  it 'send HTTP requests for uncached resources' do
    subject['users/rkh']['name'].should be == "Konstantin Haase"
    requests.count.should be == 1
  end

  it 'uses the cache for subsequent requests' do
    subject['users/rkh']['name'].should be == "Konstantin Haase"
    subject['users/svenfuchs']['name'].should be == "Sven Fuchs"
    subject['users/rkh']['name'].should be == "Konstantin Haase"
    requests.count.should be == 2
  end
end
