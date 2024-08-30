
function calc_propeller_output(propellers, pitch, yaw, roll, default_idle, correction_factor)
    local outputs = {}

    -- Use default_idle parameter or default to 50% if not provided
    default_idle = default_idle or 0.5
    -- Use correction_factor parameter or default to 0.5 if not provided
    correction_factor = correction_factor or 0.5

    for i, prop in ipairs(propellers) do
        -- Start with the specified default idle output
        local output = default_idle
        
        -- Adjust the output based on the propeller's coordinates and the quadcopter's pitch, yaw, and roll
        output = output - (pitch * prop.coords.y * correction_factor) - (roll * prop.coords.x * correction_factor) - (yaw * prop.coords.z * correction_factor)
        
        -- Clamp the output between 0 and 1
        output = math.max(0, math.min(output, 1))
        
        -- Store the output percentage
        outputs[i] = output * 100
    end

    return outputs
end



function visualize_propellers(propellers, outputs)
    local width, height = 15, 8
    local centerX, centerY = math.floor(width / 2), math.floor(height / 2)
    local grid = {}

    -- Initialize the grid with spaces
    for y = 1, height do
        grid[y] = {}
        for x = 1, width do
            grid[y][x] = ' '
        end
    end

    -- Place power outputs on the grid
    for i, prop in ipairs(propellers) do
        local x = math.floor(centerX + prop.coords.x * 4 + 0.5)  -- Scale and offset to fit grid
        local y = math.floor(centerY - prop.coords.y * 2 + 0.5)  -- Scale and offset to fit grid

        -- Ensure coordinates are within the grid boundaries
        if x >= 1 and x <= width and y >= 1 and y <= height then
            -- Add power output on the grid
            local output_str = string.format("%.1f%%", outputs[i])
            -- Center the output string around the propeller location
            local startX = math.max(1, x - math.floor(#output_str / 2))
            for j = 1, #output_str do
                if startX + j - 1 < width then
                    grid[y][startX + j - 1] = output_str:sub(j, j)
                end
            end
        end
    end

    -- Place center marker on the grid
    grid[centerY][centerX] = '+'

    -- Create a single string for the grid
    local output_str = ""
    for y = 1, height do
        for x = 1, width do
            output_str = output_str .. grid[y][x]
        end
        output_str = output_str .. "\n"
    end

    -- Print the grid
    io.write(output_str)
end




local propellers = {
    {coords = {x = 1, y = 1, z = 0}},   -- front-right propeller
    {coords = {x = -1, y = 1, z = 0}},  -- front-left propeller
    {coords = {x = 1, y = -1, z = 0}},  -- back-right propeller
    {coords = {x = -1, y = -1, z = 0}}  -- back-left propeller
}



local test_cases = {
    {
        coords = {x = 1342, y = 120, z = 2341},
        orientation = {pitch = 0.1, yaw = 0.05, roll = -0.1}
    },
    {
        coords = {x = 4799, y = 150, z = 3890},
        orientation = {pitch = 0.2, yaw = -0.1, roll = 0.0}
    },
    {
        coords = {x = 2914, y = 75, z = 1500},
        orientation = {pitch = -0.1, yaw = 0.1, roll = 0.2}
    },
    {
        coords = {x = 3567, y = 50, z = 2900},
        orientation = {pitch = 0.0, yaw = 0.0, roll = 0.0}   -- perfectly level
    },
    {
        coords = {x = 4231, y = 120, z = 4320},
        orientation = {pitch = -0.05, yaw = 0.15, roll = -0.1}
    }
}


local i = 0
-- Run the simulations
for _, test in ipairs(test_cases) do
    i = i + 1
    print("----\nTest case "..i.."\npos: "..test.coords.x..","..test.coords.y..","..test.coords.z.."\npitch: "..test.orientation.pitch.."\nyaw: "..test.orientation.yaw.."\nroll: "..test.orientation.roll)
    local outputs = calc_propeller_output(propellers, test.orientation.pitch, test.orientation.yaw, test.orientation.roll)
    
    visualize_propellers(propellers,outputs)

end



