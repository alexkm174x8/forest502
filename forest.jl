using Agents, Random, Distributions

@enum TreeStatus green burning burnt

@agent struct TreeAgent(GridAgent{2})
    status::TreeStatus = green

    spread = 0
end

function forest_step(tree::TreeAgent, model)
    if tree.status == burning
        for neighbor in nearby_agents(tree, model)
            if neighbor.status == green 
                spread_chance = rand(0:100)
                if spread_chance < neighbor.spread  
                    neighbor.status = burning
                end
            end
        end
        tree.status = burnt  
    end
end

function forest_fire(; density = 0.70, griddims = (5, 5), probability_of_spread = 50) 
    space = GridSpaceSingle(griddims; periodic = false, metric = :manhattan)
    forest = StandardABM(TreeAgent, space; agent_step! = forest_step, scheduler = Schedulers.Randomly())
    for pos in positions(forest)
        if rand(0:100) < density * 100 
            tree = add_agent!(pos, forest)
            tree.spread = probability_of_spread
            if pos[1] == 5  
                tree.status = burning
            end
        end
    end
    return forest
end
