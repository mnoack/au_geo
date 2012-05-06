class Subdivisions
  def self.call(env)
    subdivision_name = env['action_dispatch.request.path_parameters'][:name]
    subdivisions = Subdivision.where([ 'LOWER(name) LIKE ?', subdivision_name + '%' ]).limit(15)
    res = Hash[subdivisions.map{ |s| [s.code, s.name] }]
    [
      200,
      {'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*'},
      [res.to_json]
    ]
  end
end
