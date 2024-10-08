using Agents, Random, Distributions

@enum TreeStatus green burning burnt

@agent struct TreeAgent(GridAgent{2})
    status::TreeStatus = green
    spread = 0
    southWind = 0
    westWind = 0
end

function forest_step(tree::TreeAgent, model)
    if tree.status == burning
        posibleTrees = nearby_agents(tree, model, 1)
        
        wind_adjustments = Dict(
            (-1, -1) => (-tree.southWind / 2 - tree.westWind / 2),
            (0, -1)  => (-tree.southWind),
            (1, -1)  => (-tree.southWind / 2 + tree.westWind / 2),
            (-1, 0)  => (-tree.westWind),
            (1, 0)   => tree.westWind,
            (-1, 1)  => (tree.southWind / 2 - tree.westWind / 2),
            (0, 1)   => tree.southWind,
            (1, 1)   => (tree.southWind / 2 + tree.westWind / 2)
        )
        
        for neighbor in posibleTrees
            relative_pos = (neighbor.pos[1] - tree.pos[1], neighbor.pos[2] - tree.pos[2])
            spread_adjustment = get(wind_adjustments, relative_pos, 0)
            adjusted_spread = tree.spread + spread_adjustment
            adjusted_spread = clamp(adjusted_spread, 0, 100)
            posibility_of_spread = rand(0:100)
            
            if neighbor.status == green && posibility_of_spread < adjusted_spread
                neighbor.status = burning
            end
        end
        
        tree.status = burnt
    end
end

function forest_fire(; density = 0.70, griddims = (5, 5), probability_of_spread = 0, south_wind_speed = 0, west_wind_speed = 0)
    space = GridSpaceSingle(griddims; periodic = false, metric = :euclidean)
    forest = StandardABM(TreeAgent, space; agent_step! = forest_step, scheduler = Schedulers.Randomly())
    
    for pos in positions(forest)
        if rand(0:100) < density * 100 
            tree = add_agent!(pos, forest)
            tree.spread = probability_of_spread
            tree.southWind = -south_wind_speed
            tree.westWind = west_wind_speed

            if pos[1] == 5 
                tree.status = burning
            end
        end
    end

    return forest
end
