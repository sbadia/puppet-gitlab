shared_examples_for "a Puppet::Error" do |description|
  it "with message matching #{description.inspect}" do
    expect { should have_class_count(1) }.to raise_error(Puppet::Error, description)
  end
end
