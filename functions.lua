--functions
function sum(num1,num2)
  return num1+num2;
end

print(string.format("5+2 = %.1f",sum(3,2.29)))



function total(...)
  sum = ''
  
  --ATTENTION!!!!!!!!!!!!!!!!!!!!!!!!!!: pairs is only doable when checking table
  for k,v in pairs{...} do
    sum = sum..v
  end
  
  --io.write("output: ",sum,"\n")
return sum
end

print(string.format("sum of  is %s",total('w','h','o','a','r','e','u'))) -- ATTENTION!!!! MUST have '', this makes reconginazable to do the adding of string

----another way of define a function
times2 = function(x) answer = x*2 return answer end
print (string.format("skrrr %d",times2(1)))

--[[Variadic Function recieve unknown number of parameters


function getSumMore(...)
  local sum = 0
 
  for k, v in pairs{...} do
    sum = sum + v
  end
  return sum
end
 
io.write("Sum : ", getSumMore(1,2,3,4,5,6), "\n")
 
-- A function is a variable in that we can store them under many variable
-- names as well as in tables and we can pass and return them though functions
 
-- Saving an anonymous function to a variable



--doubleIt = function(x) return x * 2 end
--print(doubleIt(4))]]
 
 
 --no idea what's the following saying........... CLOSURE shit 
 print("okayyyyyyy:")
function outerFunc()
  local i = 0
  return function()
    i = i + 1
    return i
  end
end
 
-- When you include an inner function in a function that inner function
-- will remember changes made on variables in the inner function
getI = outerFunc()
print(getI())
print(getI())