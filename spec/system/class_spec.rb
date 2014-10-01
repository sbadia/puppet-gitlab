require 'spec_helper_system'

describe "gitlab class:" do
  context 'should run successfully' do
    pp = "class { 'gitlab': }"

    context puppet_apply(pp) do
      describe '#stderr' do
        subject { super().stderr }
        it { is_expected.to be_empty }
      end

      describe '#exit_code' do
        subject { super().exit_code }
        it { is_expected.not_to eq(1) }
      end

      describe '#refresh' do
        subject { super().refresh }
        it { is_expected.to be_nil }
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
