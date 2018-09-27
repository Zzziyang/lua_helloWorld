legalage = 18
-io.write("enter your age to see can you vote or not" )
age = io.read()
canvote = tonumber(age) >18 and true or false
io.write("cam i vote: ", tostring(canvote),"\n")


print("enter your age to see can you vote or not")
age = tonumber(io.read())
canvote = false
if(age>legalage) then canvote = true end
io.write("can i vote: ",tostring(canvote),"\n")
i =1

while(i<10) do
io.write("password: ")
if(io.read() == "a") then
  io.write("Bingo!")
  break 
  end


i = i+1
end
repeat
  io.write("what's your name?")
  local name = tostring(io.read())
  if( name ~= 'Gary') then io.write("wrong","\n" ) end
  if( name == 'Gary') then io.write("correct ","\n" ) end
until name == 'Gary'






for i=3,5 do
  io.write(i,"\n")

end
