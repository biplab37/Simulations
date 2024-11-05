### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 65fa47fd-71d7-4674-b302-3e74abb08b17
using Pkg;Pkg.activate()

# ╔═╡ 365eb824-ce48-4d1a-b75b-df2ab08b5836
using WGLMakie

# ╔═╡ b01a6fc7-52da-408c-ae54-fb57be1e0234
using Makie

# ╔═╡ f580bb79-22cb-44f5-92f6-ca6c51486e0b
using DataStructures: CircularBuffer

# ╔═╡ d349911f-2e10-4d8c-bc9e-b20d5161eb09
md"# Newtonian Dynamics"

# ╔═╡ 6e0d2c3d-8666-4e43-a7d1-933a6a725159
md"## Import Packages"

# ╔═╡ e6fa4484-7e4f-4890-9120-443c92f84788
md"## Calculation "

# ╔═╡ fdc1a90c-1614-4d76-aeb7-7ea19685c3b6
md"### Function Definitions"

# ╔═╡ ae1f5926-30a9-4173-a97f-be7aa0977649
function next_step_rk4!(x, F, t, h, p)
    k1 = F(x, p, t)
    k2 = F(x .+ k1 * (h / 2), p, t + h / 2)
    k3 = F(x .+ k2 * (h / 2), p, t + h / 2)
    k4 = F(x .+ h * k3, p,  t + h)
    x .+= h * (k1 .+ 2 * k2 .+ 2 * k3 .+ k4) / 6
end

# ╔═╡ 002d8b34-d896-4d94-975f-447122082b37
function earth_rotation(state, params, t)
	G, M, m = params
	x, dx, y, dy = state
	dstate = similar(state)
	distance = sqrt(x^2 + y^2)
	dstate[1] = dx
	dstate[2] = - G*M*m*x/distance^3
	dstate[3] = dy
	dstate[4] = - G*M*m*y/distance^3
	return dstate
end

# ╔═╡ 9ae892a2-4683-46ca-b0d8-e4af199f7340
num = 200

# ╔═╡ c6cdb51a-4c87-4cf7-a46c-592bf12f92d0
tailcol = RGBAf.(0.0, 1.0, 0.0, 0.01:1/num:1);

# ╔═╡ 898755af-6722-4ca6-8ef9-0d7b6bf331dc
function next_step_earth!(state, earth, tail, param)
	next_step_rk4!(state, earth_rotation, 0.0, 0.01, param)
	earth[] = Point2f(state[1], state[3])
	push!(tail[], Point2f(state[1], state[3]))
	tail[] = tail[]
end

# ╔═╡ 6306223e-bbd6-4806-8032-1ae2c52a99b6
function init_fig()
    fig = Figure(backgroundcolor=:gray22)
    ax = Axis(fig[1, 1])
    limits!(ax, -0.25, 1, -0.5, 0.5)
   	hidedecorations!(ax)
	hidespines!(ax)
    ax.aspect = DataAspect()
    return fig, ax
end

# ╔═╡ 18601048-2353-4a6f-9587-00b584630589
function add_sun_earth!(ax, state, param)
	earthpos = Point2f(state[1], state[3])
	earth = Observable(earthpos)
	tail = CircularBuffer{Point2f}(num)
	fill!(tail, earthpos)
	tail = Observable(tail)
	# sun
	scatter!(ax, [Point2f(0, 0)], markersize=50, color=:red)
	#earth
	scatter!(ax, earth, markersize=15, color=:green)
	#tail
	lines!(ax, tail, linewidth=2, color=tailcol)
	return state, earth, tail
end

# ╔═╡ bb3f79ff-e0cf-4529-becf-2cb87a36bb0c
md"### Parameters"

# ╔═╡ 260b20fa-69d5-41c1-895f-46535ab96b3e
G, M, m = 1,1,1

# ╔═╡ 954857db-cb0a-4f8c-93ae-03c32f685d50
param = [G, M , m]

# ╔═╡ a3ffd9a2-dea1-4793-ab1b-28e987e91519
initial_state = [0.95, 0.0, 0.0, 0.6]

# ╔═╡ ae32c69d-a6ad-410e-9584-ba750a4a4b31
set_theme!(theme_light())

# ╔═╡ 53d744f8-c769-422a-bef7-9218a185c8f1
begin
	fig, ax = init_fig()
	state, earth, tail = add_sun_earth!(ax, initial_state, param)
end

# ╔═╡ 4ec8348b-3a6d-4764-bc8f-024d0e2417a0


# ╔═╡ e4e4d4f3-195f-40b7-9e07-ee77d92fd2dc
fig

# ╔═╡ c02ff0b1-928e-499e-b4ef-a825d3f5a340
state

# ╔═╡ 17aca947-207f-4309-b6dd-767d1f58e799
@async for _ in 1:5000
	next_step_earth!(state, earth, tail, param)
	sleep(0.01) # or `yield()` instead
end

# ╔═╡ Cell order:
# ╟─d349911f-2e10-4d8c-bc9e-b20d5161eb09
# ╟─6e0d2c3d-8666-4e43-a7d1-933a6a725159
# ╠═65fa47fd-71d7-4674-b302-3e74abb08b17
# ╠═365eb824-ce48-4d1a-b75b-df2ab08b5836
# ╠═b01a6fc7-52da-408c-ae54-fb57be1e0234
# ╠═f580bb79-22cb-44f5-92f6-ca6c51486e0b
# ╟─e6fa4484-7e4f-4890-9120-443c92f84788
# ╟─fdc1a90c-1614-4d76-aeb7-7ea19685c3b6
# ╠═ae1f5926-30a9-4173-a97f-be7aa0977649
# ╠═002d8b34-d896-4d94-975f-447122082b37
# ╠═9ae892a2-4683-46ca-b0d8-e4af199f7340
# ╠═c6cdb51a-4c87-4cf7-a46c-592bf12f92d0
# ╠═898755af-6722-4ca6-8ef9-0d7b6bf331dc
# ╠═6306223e-bbd6-4806-8032-1ae2c52a99b6
# ╠═18601048-2353-4a6f-9587-00b584630589
# ╠═bb3f79ff-e0cf-4529-becf-2cb87a36bb0c
# ╠═260b20fa-69d5-41c1-895f-46535ab96b3e
# ╠═954857db-cb0a-4f8c-93ae-03c32f685d50
# ╠═a3ffd9a2-dea1-4793-ab1b-28e987e91519
# ╠═ae32c69d-a6ad-410e-9584-ba750a4a4b31
# ╠═53d744f8-c769-422a-bef7-9218a185c8f1
# ╠═4ec8348b-3a6d-4764-bc8f-024d0e2417a0
# ╠═e4e4d4f3-195f-40b7-9e07-ee77d92fd2dc
# ╠═c02ff0b1-928e-499e-b4ef-a825d3f5a340
# ╠═17aca947-207f-4309-b6dd-767d1f58e799
