require 'spec_helper'

describe Mongoid::History::Trackable::AssociationChain do
  let(:subject) { chain }
  let(:chain)   { Mongoid::History::Trackable::AssociationChain.new doc }
  let(:node)    { Mongoid::History::Trackable::AssociationChain::Node.new doc }
  let(:doc)     { baz }

  let(:foo)     { Foo.new }
  let(:bar)     { Bar.new :foo => foo }
  let(:baz)     { Baz.new :bar => bar }

  describe "#initialize" do
    its(:node) { should == node }
  end

  describe "#nodes" do
    let(:subject) { chain.nodes }

    it { should be chain.nodes }

    it "should call walk_nodes" do
      chain.should_receive(:walk_nodes).with(node)
      subject
    end
  end

  describe "#walk_nodes" do
    let(:subject) { chain.walk_nodes(node) }
    it { should == [node.parent.parent, node.parent, node] }
  end

  describe "#to_a" do
    let(:subject) { chain.to_a }

    it { should == chain.nodes.map(&:to_hash) }
  end
end
