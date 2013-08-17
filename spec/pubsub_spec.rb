require 'pubsub'

describe PubSub do

  subject(:pubsub) { PubSub.new }

  let(:random_event) { %w{f o o b a r b a z}.shuffle.join }

  let(:callback1) { Proc.new { "foo1 happened!" } }
  let(:callback2) { Proc.new { "foo2 happened!" } }
  let(:callback3) { Proc.new { "foo3 happened!" } }

  it "stores and retrieves an arbitrarily-named event" do
    pubsub.subscribe(random_event, &callback1)

    callback1.should_receive(:call)
    pubsub.publish(random_event)
  end

  it "stores and retrieves subscriptions to multiple events" do
    pubsub.subscribe('foo', &callback1)
    pubsub.subscribe('bar', &callback2)
    pubsub.subscribe('baz', &callback3)

    callback1.should_receive(:call)
    callback2.should_receive(:call)
    callback3.should_not_receive(:call)

    pubsub.publish('foo')
    pubsub.publish('bar')
  end

  context '#subscribe' do

    it "takes a proc but doesn't call it" do
      callback1.should_not_receive(:call)
      pubsub.subscribe('foo', &callback1)
    end

    it "returns a unique subscription key" do
      key1 = pubsub.subscribe('foo', &callback1)
      key2 = pubsub.subscribe('foo', &callback2)

      key1.should_not == key2
    end

  end

  context '#publish' do
    before { pubsub.subscribe('foo', &callback1) }

    it "calls an associated proc when passed an event" do
      callback1.should_receive(:call)
      pubsub.publish('foo')
    end

    it "calls all procs associated with an event" do
      pubsub.subscribe('foo', &callback2)

      callback1.should_receive(:call)
      callback2.should_receive(:call)

      pubsub.publish('foo')
    end

  end

  context '#unsubscribe' do
    let!(:key) { pubsub.subscribe('foo', &callback1) }

    it "removes a subscription when passed its key" do
      pubsub.unsubscribe(key)

      callback1.should_not_receive(:call)
      pubsub.publish('foo')
    end

    it "doesn't remove other subscriptions" do
      pubsub.subscribe('bar', &callback2)
      pubsub.subscribe('foo', &callback3)

      pubsub.unsubscribe(key)

      callback1.should_not_receive(:call)
      callback2.should_receive(:call)
      callback3.should_receive(:call)

      pubsub.publish('foo')
      pubsub.publish('bar')
    end

  end

end
