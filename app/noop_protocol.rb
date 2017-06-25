class ReverseProxy < NSURLProtocol
  REVERSE_PROXY_KEY = 'ReverseProxy'

  def self.canInitWithRequest request
    @whitelist ||= []

    url = request.URL.absoluteString

    puts "testing whitelist: #{url}" if @debug == 2

    return false if @disable

    return false if NSURLProtocol.propertyForKey(REVERSE_PROXY_KEY, inRequest: request)

    return false if @whitelist.none? { |r| r =~ url }

    true
  end

  def self.disable
    @disable = true
  end

  def self.enable
    @disable = false
  end

  def self.debug= value
    @debug = value
  end

  def self.debug
    @debug
  end

  def self.whitelist regex
    @whitelist ||= []
    @whitelist << regex
  end

  def self.delegate= value
    @delegate = value
  end

  def self.delegate
    @delegate
  end

  def self.canonicalRequestForRequest request
    request
  end

  def startLoading
    puts "started: #{self.request.URL.absoluteString}" if ReverseProxy.debug == 1
    NSURLProtocol.setProperty(true, forKey: REVERSE_PROXY_KEY, inRequest: self.request)
    @connection = NSURLConnection.connectionWithRequest(self.request, delegate: self)
    ReverseProxy.delegate.startedLoading(self.request.URL.absoluteString) if ReverseProxy.delegate
  end

  def stopLoading
    @connection.cancel
    @connection = nil
  end

  def connection connection, didReceiveResponse: response
    puts "completed: #{self.request.URL.absoluteString}" if ReverseProxy.debug == 1
    self.client.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: NSURLCacheStorageNotAllowed)
    @response = response
    performSelectorOnMainThread 'completedLoading', withObject: nil, waitUntilDone: true
  end

  def completedLoading
    ReverseProxy.delegate.completedLoading(self.request.URL.absoluteString) if ReverseProxy.delegate
  end

  def connection connection, didReceiveData: data
    self.client.URLProtocol self, didLoadData: data
  end

  def connectionDidFinishLoading connection
    self.client.URLProtocolDidFinishLoading self
  end

  def connection connection, didFailWithError: error
    self.client.URLProtocol self, didFailWithError: error
  end
end
