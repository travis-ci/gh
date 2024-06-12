require 'spec_helper'

describe GH::Retry do
  let(:not_finder) do
    Class.new(GH::MockBackend) do
      def fetch_resource(key)
        if key =~ %r{users/not-found}
          @requests << key
          error = Struct.new(:info).new(response_status: 404)
          raise GH::Error.new(error)
        end
        super(key)
      end
    end
  end

  subject { described_class.new(not_finder.new, retries: 3, wait: 0.1) }

  it 'retries request specified number of times' do
    expect { subject['users/not-found'] }.to raise_error(GH::Error)
    expect(subject.backend.requests.count).to eq 3
  end

  it 'does not retry when response is successful' do
    subject['users/rkh']
    expect(subject.backend.requests.count).to eq 1
  end
end
