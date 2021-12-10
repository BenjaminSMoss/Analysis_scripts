    ## cell1
    using Plots
    using DelimitedFiles
    using NLopt
    using LinearAlgebra: Diagonal

include("TypeDefinitions.jl")
include("DataImport.jl")
home_dir=pwd()
#### INPUT

E_reg_1=(1.09,1.25)
E_reg_2=(1.25,1.425)
E_reg_3=(1.425,1.7)
E_reg_4=(1.7,2)
# first int defines component to apply to, first tuple the E region to apply the values to, second tuple the upper and lower bounds to set 
paramFixed = [
            [1, E_reg_1, (0,0)], # component 1, (y range), (lower and upper limit)
            [1, E_reg_2, (0,0)],
            [1, E_reg_3, (0,10)],
            [1, E_reg_4, (0.0,10)],

            [2, E_reg_1, (0,10)], # component 2, y range, (lower and upper limit)
            [2, E_reg_2, (0,10)],
            [2, E_reg_3, (0,10.0)],
            [2, E_reg_4, (0,10.0)],

            [3, E_reg_1, (0,10)], # component 3, y range, (lower and upper limit)
            [3, E_reg_2, (0,10)],
            [3, E_reg_3, (0,10)],
            [3, E_reg_4, (0,10.0)],
            ] # 



# pick dataset (e.g. 1 for first dataset)
numDat = 1

# times for pure spectra from same dataset. Leave as empty array [] if
# dataset does not contain pure spectra (i.e. all pure spectra come from 
# separate .csv files)
pureY = [] #[0.5,6000]

# any x data beyond these limits will not be used for fit 
xLim = [460, 850] #[400, 700]

# normalise input spectra? "yes" or "no" 
xNorm = "yes"

# directory for data to be fitted. Normally this is e.g. a spectrum vs time matrix
#dirData = raw"C:\Box Sync\Data\fs-TAS\Julia data\Co3O4\all"
dirData = raw"C:\Users\Benjamin\Box\Julia\GA_Test\exp1"

# directory for pure spectra. Input format is .csv file containing spectral info in first column,
# while each subsequent column is one pure spectrum. Spectra can be distributed over 
# multiple files with this format in the same folder. Leave as empty string "" if no external 
# pure spectra are wanted
#file = normpath(joinpath(@__DIR__,"..", raw"data\"))
dirPureY = raw"C:\Users\Benjamin\Box\Julia\GA_Test\PB pure\Experiment1comps"



#### IMPORT DATA TO BE FITTED

Data = importData(dirData)

# divide dataset and apply x limits
x = Data[numDat].x
y = Data[numDat].y
z = Data[numDat].z
xBool = xLim[1] .< x .< xLim[2]
x = x[xBool]
z = z[xBool,:]


#### DEFINE PURE SPECTRA

if isdir(dirPureY)
    # import pure spectra from .csv
    pureZ = importDataVectors(dirPureY, x)

    # remove elements for which any of the pure vectors is NaN
    missBool = [sum(isnan.(pureZ), dims=2)...] .> 0
    x = x[.!missBool]
    z = z[.!missBool,:]
    pureZ = pureZ[.!missBool,:]
else
    # empty array otherwise 
    pureZ = Array{Union{Float64,Missing}}(undef,length(x),0)
end

# add pure x vectors at y specified in pureY 
for k in eachindex(pureY)
    pureZIdx = argmin(abs.(y .- pureY[k]))
    pureZ = hcat(pureZ, z[:,pureZIdx])
end 

# normalise pure vectors to 1 if desired 
if xNorm == "yes"
    maxi = abs.(maximum(pureZ, dims=1))
    mini = abs.(minimum(pureZ, dims=1))
    for k in eachindex(maxi)
        pureZ[:,k] ./= (maxi[k] .> mini[k] ? maxi[k] : mini[k])
    end
end



###### OPTIMISATION 
#=
Below two different ways are given to calculate kinetics of using the pure spectra. Both independently
fit spectra at each time/potential using a linear combination of the pure component spectra. The 
NLopt way does this sequentially for each spectrum, whereas BlackBoxOptim fits all spectra 
simultaneously but still in an independent manner. I would recomment NLopt as it seems much faster 
=#


#### Optimisation option 1: NLopt

# this function calculates residuals for the optimisation. Loss functions in NLopt have a gradient as 
# mandatory input; we are not using one here, but the function still needs to be able to 
# accept grad as a parameter
function lossFun(param, grad, currentZ)
    testZ = pureZ * Diagonal(param)
    #calculate sum of squares; coalesce sets missings to zero for fitting purposes
    loss = sum(abs2, coalesce.(sum(testZ,dims=2),0) .- coalesce.(currentZ,0))
end

# set up boundaries and start parameters for an intial guess
lower = fill(0.0, length(y), size(pureZ,2))
upper = fill(10.0, length(y), size(pureZ,2))
for k in eachindex(paramFixed)
    yBool = paramFixed[k][2][1] .≤ y .≤ paramFixed[k][2][2] # this is the range tuple in the middle of param fixed
    global lower[yBool,paramFixed[k][1]] .= paramFixed[k][3][1]
    global upper[yBool,paramFixed[k][1]] .= paramFixed[k][3][2]
end

startParam = fill(0.5, size(pureZ,2))

# array to collect fit result
paramOpt = Array{Float64}(undef,length(y),size(pureZ,2))
@time begin 
Threads.@threads for ny in 1:length(y)
    # y slice in z matrix (e.g. current spectrum)
    currentZ = z[:,ny]
    
    # set up NLopt parameters
    # COBYLA is a gradient free optimisation algorithm, hence grad is unused above
    opt = Opt(:LN_COBYLA, length(startParam)) 
    lower_bounds!(opt,lower[ny,:])
    upper_bounds!(opt,upper[ny,:])
    min_objective!(opt, (param,grad)->lossFun(param,grad,currentZ))
    xtol_rel!(opt, 1e-8)
    maxeval!(opt, 10000)

    # run optimisation 
    (NLOminf,NLOminx,NLOret) = NLopt.optimize(opt, startParam)
    @show NLOret
    # write fitted paramers into paramOpt
    paramOpt[ny,:] = NLOminx

end
end #time end

# write fit kinetics to .csv file 
writedlm("GA_kinetics.csv",[y paramOpt],',')


######## PLOT FIT RESULT 

## cell2

# set fonts and general styles for plot 
fo1 = font(10,"Arial")
fo2 = font(12,"Arial")
default(linewidth=1, grid=true, frame=:box, fg_legend=:transparent,
tickfont=fo1, legendfont=fo1, guidefont=fo2, legendtitlefont=fo2, 
titlefont=fo2,markershape=:circle)

#shift time zero for plot if needed 
yOffset = y .+ 0.0

yBool = yOffset .> 0

# plot pure spectra
p1 = scatter(x,pureZ, xlabel="Wavelength (nm)", ylabel = "Spectral ΔA", title="Pure spectra",
    label=["Component 1" "Component 2" "Component 3"], legend=:bottomright, markerstrokewidth=0, markersize=3)

# plot fit kinetics 
p2 = plot(yOffset[yBool], paramOpt[yBool,:],linewidth=1,xlabel="E (V vs RHE)", 
    ylabel = "Kinetic ΔA", title="Kinetics from spectral model", legend=false,
    markerstrokewidth=0, markersize=3, markershape=:circle)

# normalise fit kinetics and plot 
paramOptNorm = paramOpt ./ mapslices(maximum, paramOpt, dims=1)
p3 = plot(yOffset[yBool], paramOptNorm[yBool,:],xlabel="E (V vs RHE)", #xlim=(-1,1.5),
    ylabel = "Normalised ΔA", title="Kinetics from spectral model", legend=false,
    markerstrokewidth=0, markersize=3.5)

#plot(p1,p2,p3,layout=(3,1))
#plot!(titlefontsize=12, size=(500,800), leftmargin=6Plots.mm)


## cell3

# Plot residuals as contour plot

zSim = pureZ * transpose(paramOpt)
zDiff = z .- zSim

pltcon1 = contourf(x, yOffset[yBool], transpose(zDiff[:,yBool]),
    levels=50,linewidth=0,c=:viridis, title="Residuals map")

pltcon2 = contourf(x, yOffset[yBool], transpose(z[:,yBool]), 
    levels=50,linewidth=0,c=:viridis, title="Original data")

plot(pltcon1, pltcon2, layout=(2,1), size=(500,600), xlabel="Wavelength (nm)", 
    ylabel="Time (ps)", rightmargin=7Plots.mm) 


## cell4

# Plot fit at these y values 
yPlot = [0.4, 0.5, 0.6, 0.8, 1.4, 1.5] #number of elements should be multiple of 2

plts = []
for k in eachindex(yPlot)
    idx = argmin(abs.(y .- yPlot[k]))
    plt = scatter(x, z[:,idx], label="$(yPlot[k]) ps", markerstrokewidth=0, markersize=3)
    plot!(plt, x, zSim[:,idx], label="fit", linewidth=2, markersize=0, color=:red)
    push!(plts, plt)
end

plot(plts..., layout=(Int64(length(yPlot)/2),2), size=(600,800), legend=:bottomright)
