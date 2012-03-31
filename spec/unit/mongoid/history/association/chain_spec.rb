require 'spec_helper'

describe Mongoid::History::Association::Chain do
  let(:subject)     { chain                                           }
  let(:chain)       { Mongoid::History::Association::Chain.new        }
  let(:node_klass)  { Mongoid::History::Association::Node             }
  let(:car_node)    { node_klass.new 'Car', 1111, 'Car', car          }
  let(:door_node)   { node_klass.new 'doors', 1112, 'Door', door      }
  let(:window_node) { node_klass.new 'window', 1234, 'Window', window }
  let(:car)         { Car.new                                         }
  let(:door)        { Door.new :car => car                            }
  let(:window)      { Window.new :door => door                        }

  before do
    chain << car_node
    chain << door_node
    chain << window_node
  end

  describe "#leaf" do
    let(:subject) { chain.leaf }
    it { should == window_node }
  end

  describe "#root" do
    let(:subject) { chain.root }
    it { should == car_node    }
  end

  describe "#parents" do
    let(:subject) { chain.parents }
    it { should == [car_node, door_node] }
  end

  describe "#parent" do
    let(:subject) { chain.parent }
    it { should == door_node }
  end

  describe "#to_a" do
    let(:subject) { chain.to_a }
    it { should == chain.map(&:to_hash) }
  end
end
