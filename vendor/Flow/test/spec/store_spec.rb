describe Store do
  before do
    Store['string'] = 1
    Store[:symbol] = 1
    Store['hash'] = {'test' => 1}
    Store['array'] = [1, 2, 3]
    Store['complex'] = [1, 2, {'test' => 1}, "A", [{'test' => 2}]]
  end

  describe "hash methods" do
    it "access a string key" do
      Store['string'].should == 1
    end

    it "converts symbols keys to strings" do
      Store['symbol'].should == 1
    end

    it "serializes hash" do
      Store['hash'].should == {'test' => 1}
    end

    it "serializes array" do
      Store['array'].should == [1, 2, 3]
    end

    it "serializes complex structures" do
      Store['complex'].should == [1, 2, {'test' => 1}, "A", [{'test' => 2}]]
    end
  end

  describe ".all" do
    it "returns all stored values" do
      dict = Store.all
      dict['string'].should == 1
      dict['symbol'].should == 1
      dict['hash'].should == {'test' => 1}
      dict['array'].should == [1, 2, 3]
      dict['complex'].should == [1, 2, {'test' => 1}, "A", [{'test' => 2}]]
    end
  end

  describe ".delete" do
    it "deletes a string key" do
      Store.delete('string')
      Store['string'].should == nil
    end

    it "deletes a symbol key" do
      Store.delete(:symbol)
      Store[:symbol].should == nil
    end
  end
end
