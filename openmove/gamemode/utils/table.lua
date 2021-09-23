util = util or {}

util.Table = {}

/*
  NAME - isEqual
  FUNCTION - Checks if two tables are equal
*/

function util.Table.IsEqual(a, b)
   local function isEqualTable(t1,t2)

      if t1 == t2 then
         return true
      end

      for k,v in pairs(t1) do

         if type(t1[k]) ~= type(t2[k]) then
            return false
         end

         if type(t1[k]) == "table" then
            if not isEqualTable(t1[k], t2[k]) then
               return false
            end
         else
            if t1[k] ~= t2[k] then
               return false
            end
         end
      end

      for k,v in pairs(t2) do

         if type(t2[k]) ~= type(t1[k]) then
            return false
         end

         if type(t2[k]) == "table" then
            if not isEqualTable(t2[k], t1[k]) then
               return false
            end
         else
            if t2[k] ~= t1[k] then
               return false
            end
         end
      end

      return true
   end

   if type(a) ~= type(b) then
      return false
   end

   if type(a) == "table" then
      return isEqualTable(a,b)
   else
      return (a == b)
   end

end

/*
  NAME - TblContain
  FUNCTION - Check if table contain element
*/
function util.Table.Contain(table, element)
	if type(table) != "table" then
		table = {table}
	end
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

/*
  NAME - GetByKey
  FUNCTION - Gets a value in a table by key
*/
function util.Table.GetByKey(table, key)
  for k, value in pairs(table) do
    if k == key then
      return value
    end
  end
  return false
end

/*
  NAME - GetByValue
  FUNCTION - Gets a key in a table by vakue
*/
function util.Table.GetByValue(table, val)
  for _, value in pairs(table) do
    if value == val then
      return _
    end
  end
  return false
end

/*
  NAME - Compare
  FUNCTION - Compares two tables
*/

function util.Table.Compare(tbl1,tbl2)
	for k, v in pairs( tbl1 ) do
		if ( type(v) == "table" and type(tbl2[k]) == "table" ) then
			if ( !util.Table.Compare( v, tbl2[k] ) ) then return false end
		else
			if ( v != tbl2[k] ) then return false end
		end
	end
	for k, v in pairs( tbl2 ) do
		if ( type(v) == "table" and type(tbl1[k]) == "table" ) then
			if ( !util.Table.Compare( v, tbl1[k] ) ) then return false end
		else
			if ( v != tbl1[k] ) then return false end
		end
	end
	return true
end

/*
  NAME - RemoveByKey
  FUNCTION - Removes key from table
*/
function util.Table.RemoveByKey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

/*
  NAME - RemoveByKey
  FUNCTION - Removes key from table
*/
function util.Table.RemoveByValue(table, val)
  local element = table[util.Table.GetByValue(table, val)]
  if !element then return end
    table[util.Table.GetByValue(table, val)] = nil
    return element
end

/*
  NAME - AddToTable
  FUNCTION - Adds a value to chosen table
*/

function util.Table.AddToTable(tbl,val)
	if !util.Table.GetByValue(tbl, val) then
		table.insert(tbl,val)
	end
end

util.t = util.Table
ut_tbl = util.Table
