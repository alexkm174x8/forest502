using Agents, Random, Distributions

@enum TreeStatus green burning burnt

@agent struct TreeAgent(GridAgent{2})
    status::TreeStatus = green
    spread_rate = 0
    southWind_speed = 0
    westWind_speed = 0
end

function forest_step(tree::TreeAgent, model)
    if tree.status == burning
        neighboringTrees = nearby_agents(tree, model, 1) 
        
        wind_effects = Dict(
            (-1, -1) => (-tree.southWind_speed / 2 - tree.westWind_speed / 2),
            (0, -1)  => (-tree.southWind_speed),
            (1, -1)  => (-tree.southWind_speed / 2 + tree.westWind_speed / 2),
            (-1, 0)  => (-tree.westWind_speed),
            (1, 0)   => tree.westWind_speed,
            (-1, 1)  => (tree.southWind_speed / 2 - tree.westWind_speed / 2),
            (0, 1)   => tree.southWind_speed,
            (1, 1)   => (tree.southWind_speed / 2 + tree.westWind_speed / 2)
        )
        
        for neighbor in neighboringTrees
            relative_pos = (neighbor.pos[1] - tree.pos[1], neighbor.pos[2] - tree.pos[2])
            spread_modification = get(wind_effects, relative_pos, 0)
            effective_spread = tree.spread_rate + spread_modification
            effective_spread = clamp(effective_spread, 0, 100) 
            spread_chance = rand(0:100)
            
            if neighbor.status == green && spread_chance < effective_spread
                neighbor.status = burning
            end
        end
        
        tree.status = burnt
    end
end

function forest_fire(; density = 0.70, griddims = (5, 5), spread_probability = 0, south_wind = 0, west_wind = 0)
    space = GridSpaceSingle(griddims; periodic = false, metric = :euclidean)
    forest = StandardABM(TreeAgent, space; agent_step! = forest_step, scheduler = Schedulers.Randomly())
    
    for pos in positions(forest)
        if rand(0:100) < density * 100 
            tree = add_agent!(pos, forest)
            tree.spread_rate = spread_probability
            tree.southWind_speed = -south_wind
            tree.westWind_speed = west_wind

            if pos[1] == 5 
                tree.status = burning
            end
        end
    end

    return forest
end
