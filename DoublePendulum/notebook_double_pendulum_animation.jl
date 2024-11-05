### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 1677bd11-282c-4d75-a248-0285f09865c5
using Pkg;Pkg.activate()

# ╔═╡ aebf04cc-9aee-11ef-1e9a-21a7b743a12b
using WGLMakie

# ╔═╡ 60422d71-e924-403b-be71-918127eb41c0
using Makie

# ╔═╡ d48eacd6-8e3c-4c31-b943-f7647eb0da46
using DataStructures: CircularBuffer

# ╔═╡ 2d5da954-71f9-4ed0-b2d5-ca4bb9b13f26
md"# Double Pendulum"

# ╔═╡ 47b13d1d-196b-45c2-95f7-59e2c85dfab8
md"## Import Packages"

# ╔═╡ d31c86c6-e2a6-49ab-a973-4a526549fdc4
md"## Calculation "

# ╔═╡ 213cf630-0031-467e-9d53-91946f1bac86
md"### Function Definitions"

# ╔═╡ 4a28d5bd-85cf-439c-a899-2565cf980bc8
function next_step_rk4!(x, F, t, h, p)
    k1 = F(x, p, t)
    k2 = F(x .+ k1 * (h / 2), p, t + h / 2)
    k3 = F(x .+ k2 * (h / 2), p, t + h / 2)
    k4 = F(x .+ h * k3, p,  t + h)
    x .+= h * (k1 .+ 2 * k2 .+ 2 * k3 .+ k4) / 6
end

# ╔═╡ 0bda6721-275e-47d4-a0c0-3ff82aad73e1
function double_pendulum_eom(x, p, t)
    g, m1, m2, l1, l2 = p
    dx = similar(x) # [θ1, ∂θ1, θ2, ∂θ2]
    dx[1] = x[2]
    dx[2] = -((g * (2 * m1 + m2) * sin(x[1]) + m2 * (g * sin(x[1] - 2 * x[3])) + 2 * (l2 * x[4]^2 + l1 * x[2]^2 * cos(x[1] - x[3])) * sin(x[1] - x[3]))) / (2 * l1 * (m1 + m2 - m2 * cos(x[1] - x[3])^2))
    dx[3] = x[4]
    dx[4] = (((m1 + m2) * (l1 * x[2]^2 + g * cos(x[1])) + l2 * m2 * x[4]^2 * cos(x[1] - x[3])) * sin(x[1] - x[3])) / (l2 * (m1 + m2 - m2 * cos(x[1] - x[3])^2))
    return dx
end

# ╔═╡ 9eaa97d0-b25d-4380-a022-52802bb2fb30
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

# ╔═╡ 0807966d-3eef-4182-ac64-2c8cf3de08f1
function next_step!(state, rod, balls, tail, param)
    next_step_rk4!(state, double_pendulum_eom, 0.0, 0.01, param)
    x1, y1, x2, y2 = convert_theta(state, param)
    rod[] = [Point2f(0, 0), Point2f(x1, y1), Point2f(x2, y2)]
    balls[] = [Point2f(x1, y1), Point2f(x2, y2)]
    push!(tail[], Point2f(x2, y2))
    tail[] = tail[]
end

# ╔═╡ e19baa49-d9e3-4dfa-b0ef-8fa3946a38cc
function init_fig()
    fig = Figure(backgroundcolor=:gray22)
    ax = Axis(fig[1, 1])
    limits!(ax, -2, 2, -2, 2)
    hidedecorations!(ax)
    ax.aspect = DataAspect()
    return fig, ax
end

# ╔═╡ 0349da10-66ab-4148-8eb0-ba4750960f97
md"### Parameters"

# ╔═╡ 5d5472f5-2eaa-4fed-aed5-4ed5e15fe255
begin
	m1, m2, l1, l2 = 1.0, 1.0, 1.0, 1.0
	param = [9.81, m1, m2, l1, l2]
end

# ╔═╡ 4c856818-e0bc-4ca1-a92b-1be0af2e57b3
begin
	initial_state = [2.0, 0.0, 2.0, 0.0]
	initial_state_2 = [2.0, 0.0, 2.0001, 0.0]
	num = 100
	tailcol = RGBAf.(1.0, 0.0, 0.0, 0.01:1/num:1)
	tailcol2 = RGBAf.(0.0, 1.0, 0.0, 0.01:1/num:1)
end;

# ╔═╡ 19f23959-b786-4ec4-8d92-618981d5d0cb
function add_oscilator!(ax, initial_state, param, tailcol)
    x1, y1, x2, y2 = convert_theta(initial_state, param)
    rod = Observable([Point2f(0, 0), Point2f(x1, y1), Point2f(x2, y2)])
    balls = Observable([Point2f(x1, y1), Point2f(x2, y2)])
    tail = CircularBuffer{Point2f}(num)
    fill!(tail, Point2f(x2, y2))
    tail = Observable(tail)
    lines!(ax, rod; color=:white, alpha=0.3, linewidth=2)
    scatter!(ax, balls; color=:white, alpha=0.3, markersize=15)
    lines!(ax, tail; color=tailcol, linewidth=2)
    hidespines!(ax)
    return initial_state, rod, balls, tail
end

# ╔═╡ e0587391-3d56-4c90-a070-c6e4550b15be
begin
	set_theme!(theme_dark())
	fig, ax = init_fig()
	state, rod, balls, tail = add_oscilator!(ax, initial_state, param, tailcol)
	state2, rod2, balls2, tail2 = add_oscilator!(ax, initial_state_2, param, tailcol2)
end

# ╔═╡ 52dd2292-fce2-45fd-89aa-8b1569ca8a99
@async for _ in 1:1000
	isopen(fig.scene) || break # ensures computations stop if closed window
	next_step!(state, rod, balls, tail, param)
	next_step!(state2, rod2, balls2, tail2, param)
	sleep(0.01) # or `yield()` instead
end

# ╔═╡ 918a405f-808b-4c47-81f9-e28767cdce40
md"## Animation"

# ╔═╡ 796f61f3-4f0e-4cf2-86a6-bc6336f444ee
fig

# ╔═╡ Cell order:
# ╟─2d5da954-71f9-4ed0-b2d5-ca4bb9b13f26
# ╟─47b13d1d-196b-45c2-95f7-59e2c85dfab8
# ╠═1677bd11-282c-4d75-a248-0285f09865c5
# ╠═aebf04cc-9aee-11ef-1e9a-21a7b743a12b
# ╠═60422d71-e924-403b-be71-918127eb41c0
# ╠═d48eacd6-8e3c-4c31-b943-f7647eb0da46
# ╟─d31c86c6-e2a6-49ab-a973-4a526549fdc4
# ╟─213cf630-0031-467e-9d53-91946f1bac86
# ╠═4a28d5bd-85cf-439c-a899-2565cf980bc8
# ╠═0bda6721-275e-47d4-a0c0-3ff82aad73e1
# ╠═9eaa97d0-b25d-4380-a022-52802bb2fb30
# ╠═0807966d-3eef-4182-ac64-2c8cf3de08f1
# ╠═e19baa49-d9e3-4dfa-b0ef-8fa3946a38cc
# ╠═19f23959-b786-4ec4-8d92-618981d5d0cb
# ╟─0349da10-66ab-4148-8eb0-ba4750960f97
# ╠═5d5472f5-2eaa-4fed-aed5-4ed5e15fe255
# ╠═4c856818-e0bc-4ca1-a92b-1be0af2e57b3
# ╠═e0587391-3d56-4c90-a070-c6e4550b15be
# ╠═52dd2292-fce2-45fd-89aa-8b1569ca8a99
# ╟─918a405f-808b-4c47-81f9-e28767cdce40
# ╠═796f61f3-4f0e-4cf2-86a6-bc6336f444ee
