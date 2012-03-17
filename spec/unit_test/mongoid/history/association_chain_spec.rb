require 'spec_helper'

describe Mongoid::History::Trackable::AssociationChain do
  let(:subject) { chain }
  let(:chain)   { Mongoid::History::Trackable::AssociationChain.new doc }
  let(:root)    { Mongoid::History::Trackable::AssociationChain::Node.new doc }
  let(:doc)     { baz }

  let(:foo)     { Foo.new }
  let(:bar)     { Bar.new :foo => foo }
  let(:baz)     { Baz.new :bar => bar }

  describe "#initialize" do
    its(:root) { should == root }
  end

  describe "#nodes" do
    let(:subject) { chain.nodes }

    it { should be chain.nodes }

    it "should call walk_nodes with root node" do
      chain.should_receive(:walk_nodes).with(root)
      subject
    end
  end

  describe "#walk_nodes" do
    let(:subject) { chain.walk_nodes(root) }
    it { should == [root.parent.parent, root.parent, root] }
  end

  describe "#to_a" do
    let(:subject) { chain.to_a }

    it { should == chain.nodes.map(&:to_hash) }
  end
end
