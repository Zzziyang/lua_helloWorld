months = {"January", "February", "March", "April", "May",
"June", "July", "August", "September", "October", "November",
"December"}
 
-- Cycle through table where k is the key and v the value of each item
for k, v in pairs(months) do
 -- io.write(k," ",v, " ")
end
 
 
 sentence = {"a",'b','c'}
 valueofi = 0
 for i,j in pairs(sentence) do 
   valueofi = i
 end
 print("value of i is:" , valueofi)
 print("size:" ,#sentence)
 print("first:", sentence[2])
 table.insert(sentence,1,'Q')
 
 print(table.concat(sentence,' '))
io.write ("size is ", #sentence,"\n")
 --[[for i,v in pairs(sentence) do
   print(v)
   end]]
table.remove(sentence,2)
print(table.concat(sentence,' '))
io.write ("size is ", #sentence,"\n")

--creat multidimentional table(2d array)

aMultiTable = {}
for i = 1, 10 do
  aMultiTable[i] = {} -- IMPORTANT STEP!!!!!!!!!!!!!!!!!!!!!!!
  for j = 1, 10 do
    aMultiTable[i][j] = tostring(i-1) .. tostring(j-1)
  end
end
--io.write("Table[0][0] : ", aMultiTable[1][1], "\n")

--io.write ("size of aMultiTable is ", #aMultiTable,"\n")
for i=1,10 do
  io.write("colume ",i,": ")
  for j=1,10 do
   io.write("[", i, "]", "[", j, "]:" , aMultiTable[i][j],"   ") 
  end
  print()

  end
io.write ("size of aMultiTable is ", #aMultiTable,"\n")