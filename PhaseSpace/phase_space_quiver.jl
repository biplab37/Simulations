using CairoMakie

function dynamical_system(x, param, t)
    ω = param[1]
    dx = similar(x)
    dx[1] = x[2]
    dx[2] =  - ω^2*x[1]
    return dx
end



fig = Figure()
ax = Axis(fig[1,1], backgroundcolor = :black)
streamplot!(ax, (x,y)->Point2f(dynamical_system([x,y], [0.1], 0.0)...), -π:0.1:π, -π:0.1:π , colormap=Reverse(:plasma), arrowsize)
fig

