using UsefulFunctions: rk4
using Makie, GLMakie
using DataStructures: CircularBuffer

# System of odes for the double pendulum

function double_pendulum_eom(x, p)
    g, m1, m2, l1, l2 = p
    dx = similar(x) # [θ1, ∂θ1, θ2, ∂θ2]
    dx[1] = x[2]
    dx[2] = -((g * (2 * m1 + m2) * sin(x[1]) + m2 * (g * sin(x[1] - 2 * x[3])) + 2 * (l2 * x[4]^2 + l1 * x[2]^2 * cos(x[1] - x[3])) * sin(x[1] - x[3]))) / (2 * l1 * (m1 + m2 - m2 * cos(x[1] - x[3])^2))
    dx[3] = x[4]
    dx[4] = (((m1 + m2) * (l1 * x[2]^2 + g * cos(x[1])) + l2 * m2 * x[4]^2 * cos(x[1] - x[3])) * sin(x[1] - x[3])) / (l2 * (m1 + m2 - m2 * cos(x[1] - x[3])^2))
    return dx
end

m1, m2, l1, l2 = 1.0, 1.0, 1.0, 1.0
param = [9.81, m1, m2, l1, l2]

function next_step_rk4!(x, F, h, p)
    k1 = F(x, p)
    k2 = F(x .+ k1 * (h / 2), p)
    k3 = F(x .+ k2 * (h / 2), p)
    k4 = F(x .+ h * k3, p)
    @. x += h * (k1 + 2 * k2 + 2 * k3 + k4) / 6
end

function convert_theta(x, param)
    l1, l2 = param[4], param[5]
    theta1 = x[1]
    theta2 = x[3]
    x1 = l1 * sin(theta1)
    y1 = -l1 * cos(theta1)
    x2 = x1 + l2 * sin(theta2)
    y2 = y1 - l2 * cos(theta2)
    return [x1, y1, x2, y2]
end

function next_step!(state, rod, balls, tail, param)
    next_step_rk4!(state, double_pendulum_eom, 0.01, param)
    x1, y1, x2, y2 = convert_theta(state, param)
    rod[] = [Point2f(0, 0), Point2f(x1, y1), Point2f(x2, y2)]
    balls[] = [Point2f(x1, y1), Point2f(x2, y2)]
    push!(tail[], Point2f(x2, y2))
    tail[] = tail[]
end

initial_state = [2.0, 0.0, 2.0, 0.0]
initial_state_2 = [2.0, 0.0, 2.0001, 0.0]
num = 100
tailcol = RGBAf.(0.0, 0.0, 1.0, 0.01:1/num:1)
tailcol2 = RGBAf.(1.0, 0.0, 0.0, 0.01:1/num:1)

function create_fig()
    fig = Figure()
    ax = Axis(fig[1, 1])
    limits!(ax, -2, 2, -2, 2)
    hidedecorations!(ax)
    ax.aspect = DataAspect()
    return fig, ax
end
function add_oscilator!(ax, initial_state, param, tailcol)
    x1, y1, x2, y2 = convert_theta(initial_state, param)
    rod = Observable([Point2f(0,0), Point2f(x1, y1), Point2f(x2, y2)])
    balls = Observable([Point2f(x1, y1), Point2f(x2, y2)])
    tail = CircularBuffer{Point2f}(num)
    fill!(tail, Point2f(x2, y2))
    tail = Observable(tail)
    lines!(ax, rod; color=:gray22, alpha=0.2, linewidth=2)
    scatter!(ax, balls; color=:black, alpha=0.2, markersize=15)
    lines!(ax, tail; color=tailcol, linewidth=2)
    # hidespines!(ax)
    return initial_state, rod, balls, tail
end

fig, ax = create_fig()
state, rod, balls, tail = add_oscilator!(ax, initial_state, param, tailcol)
state2, rod2, balls2, tail2 = add_oscilator!(ax, initial_state_2, param, tailcol2)
display(fig)
run = Button(fig[2,1]; label = "run", tellwidth = false)
# This button will start/stop an animation. It's actually surprisingly
# simple to do this. The magic code is:
isrunning = Observable(false)
on(run.clicks) do clicks; isrunning[] = !isrunning[]; end
on(run.clicks) do clicks
    @async while isrunning[]
        isopen(fig.scene) || break # ensures computations stop if closed window
        next_step!(state, rod, balls, tail, param)
        next_step!(state2, rod2, balls2, tail2, param)
        sleep(0.01) # or `yield()` instead
    end
end

# phase space plot
# phase_fig = Figure()
# ax = Axis(phase_fig[1,1])
# limits!(ax, -π, π, -10, 10)
# state = initial_state
# points = Observable(Point2f[])
# scatter!(ax, points)
# display(phase_fig)
# button = Button(phase_fig[2,1]; label = "run", tellwidth = false)
# on(button.clicks) do clicks; isrunning[] = !isrunning[]; end

# on(button.clicks) do clicks
#     @async while isrunning[]
#         isopen(phase_fig.scene) || break # ensures computations stop if closed window
#         next_step!(state, rod, balls, tail, param)
#         push!(points[], Point2f(state[1], state[2]))
#         points[] = points[]
#         sleep(0.01) # or `yield()` instead
#     end
# end