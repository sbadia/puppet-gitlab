require 'spec_helper_system'

# Here we put the more basic fundamental tests, ultra obvious stuff.
describe "basic tests:" do
  context 'make sure we have copied the module across' do
    # No point diagnosing any more if the module wasn't copied properly
    context shell 'ls /etc/puppet/modules/gitlab' do
      describe '#stdout' do
        subject { super().stdout }
        it { is_expected.to match(/Modulefile/) }
      end

      describe '#stderr' do
        subject { super().stderr }
        it { is_expected.to be_empty }
      end

      describe '#exit_code' do
        subject { super().exit_code }
        it { is_expected.to be_zero }
      end
    end
  end
end
