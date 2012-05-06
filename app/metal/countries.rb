class Countries
  def self.call(env)
    res = Hash[Country.from_cache.map{ |c| [c.code, c.name] }]
    [200, {"Content-Type" => "application/json"}, [res.to_json]]
  end
end
