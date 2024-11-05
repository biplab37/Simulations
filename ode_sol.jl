function next_step_rk4!(x, F, t, h, p)
    k1 = F(x, p, t)
    k2 = F(x .+ k1 * (h / 2), p, t + h / 2)
    k3 = F(x .+ k2 * (h / 2), p, t + h / 2)
    k4 = F(x .+ h * k3, p,  t + h)
    x .+= h * (k1 .+ 2 * k2 .+ 2 * k3 .+ k4) / 6
end