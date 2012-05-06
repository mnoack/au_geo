class Localities
  def self.call(env)
    locality_name = env['action_dispatch.request.path_parameters'][:name]
    localities = Locality.find_matching_search(locality_name)
    res = localities.map do |l|
      [l.name, l.post_code, l.subdivision_code, l.subdivision.name, l.subdivision.country_code]
    end
    [
      200,
      {'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*'},
      [res.to_json]
    ]
  end
end
