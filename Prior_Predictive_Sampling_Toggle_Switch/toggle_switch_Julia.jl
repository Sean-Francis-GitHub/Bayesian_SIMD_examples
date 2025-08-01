using Distributions
using Random
using Statistics
using Distributed
using DataFrames
using CSV

# Prior predictive sampling parameters
T = 600
C = 8000
N = 8064

seed = 123
Random.seed!(seed)

cores = [1, 2, 4, 8, 12]

# Initialize output DataFrame
results = DataFrame(cores=Int[], time=Float64[])

for P in cores
    # Add exactly P workers
    new_workers = addprocs(P)

    @info "Using $P cores (workers: $new_workers)"

    # Broadcast function definitions to newly added workers
    @everywhere new_workers begin
        using Random
        using Distributions
        using Statistics

        function simulate_toggle_switch_vec(mu, sigma, gam, alpha, beta, T, C)
            u_t = Vector{Float64}(undef, C)
            v_t = Vector{Float64}(undef, C)

            alpha_u = alpha[1]
            alpha_v = alpha[2]
            beta_u = beta[1]
            beta_v = beta[2]

            u_t .= 10.0
            v_t .= 10.0

            # Generate random variates
            zeta = rand(Normal(0, 1), C, 2*(T - 1) + 1)

            for j = 2:T
                p_u = v_t .^ beta_u
                p_v = u_t .^ beta_v

                u_t = 0.97 .* u_t .+ alpha_u ./ (1 .+ p_u) .- 1.0 .+ 0.5 .* zeta[1:C, 2*(j - 1)]
                v_t = 0.97 .* v_t .+ alpha_v ./ (1 .+ p_v) .- 1.0 .+ 0.5 .* zeta[1:C, 2*(j - 1) + 1]

                u_t[u_t .< 1.0] .= 1.0
                v_t[v_t .< 1.0] .= 1.0
            end

            y = u_t .+ sigma .* mu .* zeta[1:C, 1] ./ (u_t .^ gam)
            y[y .< 1.0] .= 1.0

            return y
        end

        function generate_sample(T, C)
            theta = rand.(Uniform.(
                [250.0, 0.05, 0.05, 0.0, 0.0, 0.0, 0.0],
                [400.0, 0.5, 0.35, 50.0, 50.0, 7.0, 7.0]
            ))

            mu = theta[1]
            sigma = theta[2]
            gam = theta[3]
            alpha = theta[4:5]
            beta = theta[6:7]

            result = simulate_toggle_switch_vec(mu, sigma, gam, alpha, beta, T, C)
            return vcat(theta, result)  # Combine theta and simulation output
        end
    end

    # Use WorkerPool to restrict execution to just added workers
    pool = WorkerPool(new_workers)
    t_start = time()

    obs_vals2 = pmap(x -> generate_sample(T, C), pool, 1:N)

    t_end = time()
    exec_time = t_end - t_start

    push!(results, (P, exec_time))

    # Optionally free workers after use to avoid accumulation
    rmprocs(new_workers)
end

# Save to CSV
CSV.write("output_Julia_runtime.csv", results)
