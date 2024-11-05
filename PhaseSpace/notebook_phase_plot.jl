### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 513b98e2-b5ab-4700-a534-830e60a6c47a
using Pkg; Pkg.activate()

# ╔═╡ d95986a6-99e2-11ef-029c-5b83b990a86b
using CairoMakie

# ╔═╡ 53b6844f-5e42-42f9-bdd7-db981a44bcdd
md"# Phase Space"

# ╔═╡ 775415d8-4c89-441e-a99d-9af92e936e26
function draw_phase_space(dynamical_system, xrange, dxrange, param)
	fig = Figure()
	ax = Axis(fig[1,1], backgroundcolor=:black, aspect=DataAspect())
	func(x,dx) = Point2f(dynamical_system([x,dx], param, 0.0)...)
	streamplot!(ax, func, xrange, dxrange, colormap=Reverse(:coolwarm), arrow_size=10)
	limits!(ax, xrange[1], xrange[end], dxrange[1], dxrange[end])
	hidedecorations!(ax)
	hidespines!(ax)
	return fig
end

# ╔═╡ 063ed5a1-41a2-4047-838c-dddd264a40c3
md"## Harmonic Oscillator"

# ╔═╡ 95ed1e9d-c95f-4ce1-bbd5-046432b4502c
function harmonic_oscillator(x, param, t)
	dx = similar(x)
	dx[1] = x[2]
	dx[2] = -param[1]*sin(x[1])
	return dx
end

# ╔═╡ ad670fa3-67c7-4882-ae20-f85d57c335ad
draw_phase_space(harmonic_oscillator, -10:0.01:10, -6:0.01:6, [1.0])

# ╔═╡ 4b8051a2-2ea2-460b-bba7-eac2efdaf73e
md"### Damped Harmonic Oscillator"

# ╔═╡ 2e2a946b-4b08-4094-9a18-a398e306da2e
function damped_harmonic_oscillator(x, param, t)
	dx = similar(x)
	dx[1]  = x[2]
	dx[2] = - param[1]^2*sin(x[1]) - 2*param[2]*param[1]*x[2] 
	return dx
end

# ╔═╡ 24b34f45-0ab3-4e30-8ff5-68a94e5bbcfc
draw_phase_space(damped_harmonic_oscillator,  -10:0.01:10, -6:0.01:6, [1.0, 0.4])

# ╔═╡ 9b7eee04-34f2-4a96-a50e-b3e7c4edcb22
md"### Driven Harmonic Oscillator"

# ╔═╡ 9f3d1418-705d-4bf2-8529-f7f227834a41
md"### Van der pol oscillator"

# ╔═╡ abdaceec-3424-4635-bef3-507652429333
function van_der_pol(x, p, t)
	dx = similar(x)
	dx[1] = x[2]
	dx[2] = -p[1]*x[1] - p[2]*(1- x[1]^2)x[2]
	return dx
end

# ╔═╡ e246c0de-06b3-4a8a-87cc-ff7890bd8af1
draw_phase_space(van_der_pol, -10:0.01:10, -10:0.01:10, [1.0, 0.2])

# ╔═╡ 31e056d8-7cea-470b-a04d-e26a2d27c15e
md"## Import Packages"

# ╔═╡ Cell order:
# ╟─53b6844f-5e42-42f9-bdd7-db981a44bcdd
# ╠═775415d8-4c89-441e-a99d-9af92e936e26
# ╟─063ed5a1-41a2-4047-838c-dddd264a40c3
# ╠═95ed1e9d-c95f-4ce1-bbd5-046432b4502c
# ╠═ad670fa3-67c7-4882-ae20-f85d57c335ad
# ╟─4b8051a2-2ea2-460b-bba7-eac2efdaf73e
# ╠═2e2a946b-4b08-4094-9a18-a398e306da2e
# ╠═24b34f45-0ab3-4e30-8ff5-68a94e5bbcfc
# ╟─9b7eee04-34f2-4a96-a50e-b3e7c4edcb22
# ╟─9f3d1418-705d-4bf2-8529-f7f227834a41
# ╠═abdaceec-3424-4635-bef3-507652429333
# ╠═e246c0de-06b3-4a8a-87cc-ff7890bd8af1
# ╟─31e056d8-7cea-470b-a04d-e26a2d27c15e
# ╠═513b98e2-b5ab-4700-a534-830e60a6c47a
# ╠═d95986a6-99e2-11ef-029c-5b83b990a86b
