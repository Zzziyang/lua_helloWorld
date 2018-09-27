password = 12348765
repeat
  io.write("enter the password","\n")
  --password = 12348765
  guess = io.read()erfjh
  if(tonumber(guess) ~= password) then io.write("Wrong password","\n") end
  if(tonumber(guess) == password) then io.write("Correct password","\n") end
  until tonumber(guess) == password 
  