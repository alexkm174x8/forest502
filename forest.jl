using Agents, Random, Distributions

@enum TreeStatus green burning burnt

@agent struct TreeAgent(GridAgent{2})
    status::TreeStatus = green
    probSpread = 0
end

function forest_step(tree::TreeAgent, model)
    if tree.status == burning
        for neighbor in nearby_agents(tree, model)
            if neighbor.status == green && rand(0:100) < tree.probSpread
                neighbor.status = burning
            end
        end
        tree.status = burnt
    end
end

function forest_fire(; density_trees = 0.7, griddims = (5, 5), probability_of_spread = 0)
    space = GridSpaceSingle(griddims; periodic = false, metric = :manhattan)
    forest = StandardABM(TreeAgent, space; agent_step! = forest_step, scheduler = Schedulers.Randomly())

    for pos in positions(forest)
        if rand(Uniform(0,1)) < density_trees
            tree = add_agent!(pos, forest)
            tree.probSpread = probability_of_spread
            if pos[1] == 5
                tree.status = burning
            end
        end
    end
    return forest
end