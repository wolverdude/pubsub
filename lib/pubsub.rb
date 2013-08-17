class PubSub
  @@id = 0

  def initialize
    @subscriptions = {}
  end
  
  def subscribe(event, &callback)
    @subscriptions[event] ||= {}
    @subscriptions[event][@@id] = callback

    key = generate_key(event, @@id)
    @@id += 1

    return key
  end
  
  def unsubscribe(key)
    event, id = retrieve_key_data(key)

    @subscriptions[event].delete id
  end
  
  def publish(event)
    @subscriptions[event].each_value do |callback|
      callback.call
    end
  end
  
  private
  
  def generate_key(event, id)
    [event, id]
  end
   
  def retrieve_key_data(key)
    key
  end

end
