paramFixed = [[1, (1.09,1.35), (111,011)], # component 1, (y range), (upper and lower limit)
            [1, (1.35,1.55), (222,022)],
            [1, (1.55,1.75), (333,033)],
            [1, (1.75,2), (444,044)],

            [2, (1.09,1.35), (111,011)], # component 2, y range, upper and lower limit
            [2, (1.35,1.55), (222,022)],
            [2, (1.55,1.75), (333,033)],
            [2, (1.75,2), (444,044)],

            [3, (1.09,1.35), (111,011)], # component 3, y range, upper and lower limit
            [3, (1.35,1.55), (222,022)],
            [3, (1.55,1.75), (333,033)],
            [3, (1.75,2), (444,044)],] # 

#y=[1.2,2.2,3.3,4.4,5.5,6.6,7.7,8.8,9.9,10.9]

#pureZ=zeros(10,10)
# set up lower/upper limits for fit parameters
lower = fill(0.0, length(y), size(pureZ,2))
upper = fill(0.0, length(y), size(pureZ,2))

# apply fixed parameter values by setting bounds to same value 
for k in eachindex(paramFixed)
    yBool = paramFixed[k][2][1] .≤ y .≤ paramFixed[k][2][2] # this is the range tuple in the middle of param fixed
    global lower[yBool,paramFixed[k][1]] .= paramFixed[k][3][1]
    global upper[yBool,paramFixed[k][1]] .= paramFixed[k][3][2]
end


