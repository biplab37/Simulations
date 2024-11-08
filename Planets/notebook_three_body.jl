### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ ea912706-5ee8-462b-80cb-8534480b0fcb
using Pkg;Pkg.activate()

# ╔═╡ d0ed5e4f-a4d1-42e0-8def-f13b109ca7b7
using WGLMakie, Makie

# ╔═╡ 0814c0f2-bb94-4572-bd15-bd58d6f5669f
using DataStructures: CircularBuffer

# ╔═╡ b199d676-9dc9-11ef-2946-e1d4ca1a98a5
md"# Three Body simulation"

# ╔═╡ 9162e371-c887-415a-abd3-edea8810cfcf
md"## Function Definitions"

# ╔═╡ 2d156dad-0975-4e5a-bddd-fe7909d96dd8
function next_step_rk4!(x, F, t, h, p)
    k1 = F(x, p, t)
    k2 = F(x .+ k1 * (h / 2), p, t + h / 2)
    k3 = F(x .+ k2 * (h / 2), p, t + h / 2)
    k4 = F(x .+ h * k3, p,  t + h)
    x .+= h * (k1 .+ 2 * k2 .+ 2 * k3 .+ k4) / 6
end

# ╔═╡ 6bf74cb3-cc1c-4923-bf0e-00786973a1ca
function three_body(state, param, t)
	G, M, m = param
	position = state[1:6]
	momenta = state[7:end]

	dstate = similar(state)
	for i=1:6
		dstate[i] = momenta[i]
	end
	for i=1:2:6
		dist1_x = (position[i] - position[mod1(i+2, 6)])
		dist1_y = (position[i+1] - position[mod1(i+3, 6)])
		dist2_x = (position[i] - position[mod1(i+4, 6)])
		dist2_y = (position[i+1] - position[mod1(i+5, 6)])
		dstate[i+6] = -G*M*m*(dist1_x/(sqrt(dist1_x^2 + dist1_y^2))^3 + dist2_x/(sqrt(dist2_x^2 + dist2_y^2))^3)
		dstate[i+7] = -G*M*m*(dist1_y/(sqrt(dist1_x^2 + dist1_y^2))^3 + dist2_y/(sqrt(dist2_x^2 + dist2_y^2))^3)
	end
	return dstate
end

# ╔═╡ e05dcea5-f188-4cde-9fb6-a4350cec86ff
collect(1:2:6)

# ╔═╡ 0adaabbc-c8b3-4f75-95af-6b33de7498a9
function next_step_bodies!(state, positions, tails, param)
	next_step_rk4!(state, three_body, 0.0, 0.01, param)
	positions[] = [Point2f(state[i], state[i+1]) for i in 1:2:6]
	for (i,tail) in enumerate(tails)
		push!(tail[], Point2f(state[2*i-1], state[2*i]))
		tail[] = tail[]
	end
end

# ╔═╡ 1cf1d1b9-5044-46be-be85-e7ed572e8946
function init_fig()
    fig = Figure(backgroundcolor=:gray22)
    ax = Axis(fig[1, 1])
    limits!(ax, -6.0, 6.0, -6.0, 6.0)
   	hidedecorations!(ax)
	hidespines!(ax)
    ax.aspect = DataAspect()
    return fig, ax
end

# ╔═╡ 6c11f116-6ffc-4cb6-805c-6a9a5c2ba47a
begin
	G, M, m = 1,1,1
	param = [G, M, m]
end

# ╔═╡ 1ca7ab7e-42c1-440c-97e4-f82747fa3388
function add_sun_earth!(ax, state, param, num=200)
	positions = Observable([Point2f(state[i], state[i+1]) for i in 1:2:6])
	
	tail1 = CircularBuffer{Point2f}(num)
	fill!(tail1, positions[][1])
	tail1 = Observable(tail1)
	tail2 = CircularBuffer{Point2f}(num)
	fill!(tail2, positions[][2])
	tail2 = Observable(tail2)
	tail3 = CircularBuffer{Point2f}(num)
	fill!(tail3, positions[][3])
	tail3 = Observable(tail3)
	# sun
	scatter!(ax, positions, markersize=10, color=:red)
	lines!(ax, tail1, color=:blue, linewidth=2)
	lines!(ax, tail2, color=:red, linewidth=2)
	lines!(ax, tail3, color=:green, linewidth=2)
	return state, positions, [tail1, tail2, tail3]
end

# ╔═╡ 1e01506c-3cf6-4b89-a102-8a1d7e2d2908
set_theme!(theme_black())

# ╔═╡ cf3c318a-643c-4f5c-be7b-d4fe9961485b
initial_state = [0.0, 0.1, 4.0, 0.0, 0.0, 4.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

# ╔═╡ ba0ecb17-e929-4e76-9525-ee705189ddd4
begin
	fig, ax = init_fig()
	state, positions, tails = add_sun_earth!(ax, initial_state, param)
end

# ╔═╡ 5af5da85-c894-4d10-9f3e-a59cb8fa3be4
fig

# ╔═╡ 392cae62-39ca-4b89-adf1-2629ffbedc2e
@async for _ in 1:1000
	next_step_bodies!(state, positions, tails, param)
	sleep(0.01) # or `yield()` instead
end

# ╔═╡ Cell order:
# ╟─b199d676-9dc9-11ef-2946-e1d4ca1a98a5
# ╠═ea912706-5ee8-462b-80cb-8534480b0fcb
# ╠═d0ed5e4f-a4d1-42e0-8def-f13b109ca7b7
# ╠═0814c0f2-bb94-4572-bd15-bd58d6f5669f
# ╠═9162e371-c887-415a-abd3-edea8810cfcf
# ╠═2d156dad-0975-4e5a-bddd-fe7909d96dd8
# ╠═6bf74cb3-cc1c-4923-bf0e-00786973a1ca
# ╠═e05dcea5-f188-4cde-9fb6-a4350cec86ff
# ╠═0adaabbc-c8b3-4f75-95af-6b33de7498a9
# ╠═1cf1d1b9-5044-46be-be85-e7ed572e8946
# ╠═6c11f116-6ffc-4cb6-805c-6a9a5c2ba47a
# ╠═1ca7ab7e-42c1-440c-97e4-f82747fa3388
# ╠═1e01506c-3cf6-4b89-a102-8a1d7e2d2908
# ╠═cf3c318a-643c-4f5c-be7b-d4fe9961485b
# ╠═ba0ecb17-e929-4e76-9525-ee705189ddd4
# ╠═5af5da85-c894-4d10-9f3e-a59cb8fa3be4
# ╠═392cae62-39ca-4b89-adf1-2629ffbedc2e
