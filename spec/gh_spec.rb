require 'spec_helper'

describe GH do
  it 'allows doing requests right from the GH object' do
    GH['users/rkh']['name'].should be == "Konstantin Haase"
  end
end
