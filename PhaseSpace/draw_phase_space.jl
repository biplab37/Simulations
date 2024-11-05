using GLMakie
using DataStructures: CircularBuffer

include("../ode_sol.jl")

function dynamical_system(x, p, t)
    ω = p[1]
    dx = similar(x)
    dx[1] = x[2]
    dx[2] = (1-x[1]^2)*x[2] - ω*x[1]
    return dx
end

function intialize_figure(buffer, colors)
    fig = Figure()
    ax = Axis(fig[1, 1])
    limits!(ax, -2, 2, -2, 2)
    lines!(ax, buffer; color=colors, linewidth=2)
    return fig, ax
end

function initialize_state(param, buffer_size=100)
    ω = param[1]
    x0 = [1.0, 0.0]
    buffer = CircularBuffer{Point2f}(buffer_size)
    col = to_color(:blue)
    colors = RGBAf.(col.r, col.g, col.b, range(0, 1, length=buffer_size))
    fill!(buffer, Point2f(x0...))
    buffer = Observable(buffer)
    return x0, buffer, colors
end

function update_state!(x, param)
    next_step_rk4!(x, dynamical_system, 0.0, 0.1, param)
    push!(buffer[], Point2f(x...))
    buffer[] = buffer[]
end

param = [1.0]
state, buffer, colors = initialize_state(param)
fig, ax = intialize_figure(buffer, colors)
display(fig)
isrunning = Observable(false)
button = Button(fig[2, 1]; label = "run", tellwidth = false)
on(button.clicks) do clicks; isrunning[] = !isrunning[]; end
on(button.clicks) do clicks
     @async while isrunning[]
        isopen(fig.scene) || break # ensures computations stop if closed window
        update_state!(state, param)
        sleep(0.01)# or `yield()` instead
    end
end

Makie.deactivate_interaction!(ax, :rectanglezoom)
spoint = select_point(ax.scene, marker = :circle)

on(spoint) do z
    state = z
    # update_state!(state, param)
    fill!(buffer[], Point2f(state...))
    buffer[] = buffer[]
    sleep(0.01)
end