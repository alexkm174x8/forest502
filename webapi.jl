include("forest.jl")
using Genie, Genie.Renderer.Json, Genie.Requests, HTTP
using UUIDs

instances = Dict()

route("/simulations", method = POST) do
    payload = jsonpayload()
    x = payload["dim"][1]
    y = payload["dim"][2]
  
    density = payload["density"]
    spread_probability = payload["spread"]
    south_wind = payload["winds"][1]
    west_wind = payload["winds"][2]

    model = forest_fire(density = density, griddims=(x, y), spread_probability = spread_probability, south_wind = south_wind, west_wind = west_wind)
    id = string(uuid1())
    instances[id] = model

    tree_list = []
    for tree in allagents(model)
        push!(tree_list, tree)
    end
    
    json(Dict(:msg => "Simulation started", "Location" => "/simulations/$id", "trees" => tree_list))
end

route("/simulations/:id") do
    model = instances[payload(:id)]
    run!(model, 1)
    tree_list = []
    for tree in allagents(model)
        push!(tree_list, tree)
    end
    
    json(Dict(:msg => "Simulation updated", "trees" => tree_list))
end

Genie.config.run_as_server = true
Genie.config.cors_headers["Access-Control-Allow-Origin"] = "*"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS" 
Genie.config.cors_allowed_origins = ["*"]

up()
