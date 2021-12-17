#!/usr/bin/env ruby

# Parse input and create a Hash with keys {x1, x2, y1, y2}
def read_input
    File.open("../inputs/input17.txt", "r")
    .each_line
    .first
    .scan(/(\-?\d+)/)
    .flatten
    .map(&:to_i)
    .zip([:x1, :x2, :y1, :y2])
    .to_h
    .invert
end

# Update the probe's (x,y) coords and velocity components
def do_step(probe)
    x, y, vx, vy = probe.values_at(:x, :y, :vx, :vy)
    probe2 = Hash.new
    probe2[:x] = x + vx
    probe2[:y] = y + vy
    probe2[:vx] = case
        when vx > 0 then vx - 1
        when vx < 0 then vx + 1
        else 0
    end
    probe2[:vy] = vy - 1
    probe2
end

def in_target_x(probe)
    x = probe[:x]
    x1, x2 = @target.values_at(:x1, :x2)
    x.between?(x1, x2)
end

def in_target_y(probe)
    y = probe[:y]
    y1, y2 = @target.values_at(:y1, :y2)
    y.between?(y1, y2)
end

def above_target_max_x(probe)
    probe[:x] > @target[:x2]
end

def below_target_min_y(probe)
    probe[:y] < @target[:y1]
end

def in_target?(probe)
    in_x = in_target_x(probe)
    in_y = in_target_y(probe)
    res = in_x && in_y
    [res, in_x, in_y]
end

# Fire the probe with given initial velocities. Returns [true, max_y] if target hit.
def fire_probe(vx, vy)
    probe = {x: 0, y: 0, vx: vx, vy: vy}
    max_y = 0
    for t in 1..500 do
        probe = do_step(probe)
        if probe[:y] > max_y
            max_y = probe[:y]
        end
        hit, in_x = in_target?(probe)

        if probe[:vx] == 0 && !in_x
            # settled x coord outside target - miss
            return [false]
        elsif below_target_min_y(probe)
            # passed target y - confirmed miss
            return [false]
        elsif above_target_max_x(probe)
            # passed target x - confirmed miss
            return [false]
        elsif hit
            #p [[vx,vy], t, probe, hit ? "HIT" : -1, max_y]
            return [true, max_y]
        end
    end
    # timeout
    [false]
end

@target = read_input()

max_y = 0
max_y_launch = []
hits = []
for vx in (1..350)
    for vy in (-300..200)
        hit, new_max_y = fire_probe(vx,vy)
        if hit
            hits.push([vx,vy])
            if new_max_y > max_y
                max_y = new_max_y
                max_y_launch = [vx,vy]
            end
        end
    end
end
p "Part 1: max_y = #{max_y} for launch #{max_y_launch}" # 11781
p "Part 2: #{hits.size} viable launches" # 4531
