require 'spec_helper'
require 'mongoid/history/association_chain'

describe Mongoid::History::AssociationChain::Node do
  let(:subject) { node }
  let(:node)    { klass.new doc }
  let(:klass)   { Mongoid::History::AssociationChain::Node }
  let(:doc)     { bar }

  let(:foo)     { Foo.new }
  let(:bar)     { Bar.new :foo => foo }
  let(:baz)     { Baz.new :bar => bar }

  describe "#initialize" do
    its(:doc) { should equal doc }
  end

  describe "#parent" do
    let(:subject) { node.parent }

    context "when doc is not embedded" do
      let(:doc) { foo }

      it { should be nil }
    end

    it { should eq klass.new(foo) }
    it { should be node.parent }
    its(:class) { should be klass }
  end

  describe "#parent_association" do
    let(:subject) { node.parent_association }

    it { should be node.parent_association }
  end

  describe "#association_name" do
    let(:subject) { node.association_name }

    context "when doc is not embedded" do
      let(:doc) { foo }

      it {should be nil}
    end

    it { should == 'bars' }
  end

  describe "#get_parent_association" do
    let(:subject) { node.get_parent_association }

    its(:key) { should == 'foo' }
  end

  describe "#model_name" do
    let(:subject) { node.model_name }

    it { should == 'Bar' }
  end

  describe "#name" do
    let(:subject) { node.name }

    context "when doc is not embedded" do
      let(:doc) { foo }

      it { should == 'Foo' }
    end

    it { should == 'bars' }
  end

  describe "#to_hash" do
    let(:subject) { node.to_hash }
    before { doc.save }

    it { should eql 'name' => node.name, 'id' => doc.id }
  end

  describe "#==" do
    context "when comparing with same doc" do
      let(:subject) { node == klass.new(doc) }

      it { should be true }
    end

    context "when comparing different docs" do
      let(:subject) { node == klass.new(baz) }

      it { should be false }
    end
  end
end
