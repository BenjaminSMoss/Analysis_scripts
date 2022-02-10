using LinearAlgebra
#=
m, n = 5, 5
result=zeros(m,n)
odd_TF=zeros(m,n)
final_result=zeros(m,n)
# build an array from number 1 -5 
for i = 1:m
    for j = 1:n
        result[i,j]=i+j
    end 
end 
# two nested loops to check if even (% is remainder on division), building a boolian matrix and 
#broadcasting the bool matrix to get the final result
for i=1:m, j=i:n
 
        if result[i,j]%2 ==0
            odd_TF[i,j]=0
        else odd_TF[i,j]=1 
        end 
   
final_result[i,j]=result[i,j].*odd_TF[i,j]
     
end 
final_result    


time=zeros(100,2)
for i=1:100, j=1:2
    if j==1
    time[i,j]=i
    else
        b=rand(Float64, 1) # annoying use of dot product here to make 1d array a scalar
        b=sqrt(dot(b,b))
         time[i,j]=b
    end
     
    
end 
=#
# same but using concise syntax using ternay operators a ? b :

time=zeros(100,2)
for i=1:100, j=1:2
    b=rand(Float64, 1) 
    b=sqrt(dot(b,b))
    j==1 ?  time[i,j]=i : time[i,j]=b
end 
# create logical array from original array - can't get && to work so done in three lines
testF2=zeros(100,2)
final222=zeroes(100,2)
test2=time[:,1].>5
test3=time[:,1].<11
testF2=test2.*test3
#logical indexing
Final222=time[testF2,:]



