
-- numbers.lua

-- https://replit.com/@dariocangialosi/numbers#main.lua

-- section: small utility functions

local function trim_trailing_zeroes(number)
  while number.decimal_places > 0 and number[#number]==0 do
    table.remove(number,#number)
    number.decimal_places = number.decimal_places - 1
  end
end

local function number_digits_before_dot(number)
  return #number - number.decimal_places
end

local function trim_leading_zeroes(number)
  local index = 1
  local digits_before_dot = number_digits_before_dot(number)
  while index < digits_before_dot and number[1]==0 do
    table.remove(number,1)
    index = index + 1
  end
end

local function trim_zeroes(number)
  trim_leading_zeroes(number)
  trim_trailing_zeroes(number)
end

local function number_is_zero(number)
  trim_zeroes(number)
  return #number==1 and number[1]==0
end

local function normalize_zero(number)
  if number_is_zero(number) then
    number.sign=1
    number.decimal_places=0
  end
end

local function normalize(number)
  trim_zeroes(number)
  normalize_zero(number)
end

local function number_unary_minus(number)
  number.sign = -number.sign
  normalize_zero(number)
end

-- section: conversions

-- string to number conversion
local function number_text_to_digit_sequence(number_as_text) -- TO DO : corrupted formats handled
  local number_as_sequence={}
  local start_scanning_index = 1
  number_as_sequence.sign = 1
  if string.sub(number_as_text,1,1)=="-" then
    number_as_sequence.sign=-1
    start_scanning_index=2
  end
  local dot_position_in_text = nil
  for position_in_text = start_scanning_index, #number_as_text do
    
    -- parse.lua
    local function character_between(character, lesser, greater)
      return string.byte(character)>=string.byte(lesser) and string.byte(character)<=string.byte(greater)
    end
    
    local character = string.sub(number_as_text, position_in_text, position_in_text)
    
    local is_numeric = character_between(character, '0', '9')
    
    if is_numeric then table.insert(number_as_sequence, tonumber( character ) ) end
    
    if character=='.' then dot_position_in_text = position_in_text end
    
  end
  
  if dot_position_in_text then
    number_as_sequence.decimal_places = #number_as_text - dot_position_in_text
  else
    number_as_sequence.decimal_places = 0
  end
  
  normalize(number_as_sequence)
  
  return number_as_sequence
end

-- number to string conversion
local function number_digit_sequence_to_text(number_as_sequence) -- TO DO : corrupted formats handled
  local text = ""
  local function write(text_to_write)
    text = text .. text_to_write
  end
  if number_as_sequence.sign==-1 then write("-") end
  local dot_position_in_text
  if number_as_sequence.decimal_places > 0 then
    local preceding_zeroes = number_as_sequence.decimal_places - #number_as_sequence + 1
    while preceding_zeroes > 0 do table.insert(number_as_sequence,1,"0"); preceding_zeroes = preceding_zeroes - 1 end
    dot_position_in_text = #number_as_sequence - number_as_sequence.decimal_places + 1
  end
  for digit_position, digit_value in ipairs(number_as_sequence) do
    if digit_position == dot_position_in_text then
      if #text==0 then text="0" end
      write('.')
    end
    write(tostring(digit_value))
  end
  return text
end

-- section: utility functions

-- print number
local function printn(number)
  print(number_digit_sequence_to_text(number))
end

-- comparison results translate-table
local function comparison_to_text(comparison)
  local comparison_table = { [0]= "==", [-1]= "<", [1]= ">" }
  return comparison_table[comparison]
end

-- section: operations

-- compare operation
local function number_compare(n1,n2)
  
  -- compare: zeroes, when sign doesn't matter
  if number_is_zero(n1) and number_is_zero(n1) then return 0 end
  
  -- compare: by sign, when signs alone suffice to discriminate
  if n1.sign < n2.sign then return -1 end
  if n1.sign > n2.sign then return  1 end
  
  -- compare: equal signs, discriminate by absolute value
  local sign = n1.sign
  
  -- compare: discriminate by number of digits (before the dot) alone
  if number_digits_before_dot(n1) > number_digits_before_dot(n2) then
    return  1*sign -- means: n1 > n2
  elseif number_digits_before_dot(n1) < number_digits_before_dot(n2) then
    return -1*sign -- means: n1 < n2
  end
  
  -- compare: equal number of digits before the dot, discriminate by all digits
  
  -- compare by digits
  local digit_index = 1
  local digit1, digit2
  while true do
    digit1 = n1[digit_index]; digit2 = n2[digit_index]
    if digit1==nil and digit2==nil then return 0 end
    if digit1==nil then digit1=0 end
    if digit2==nil then digit2=0 end
    if digit1 ~= digit2 then
      if digit1 > digit2 then return  1*sign end
      if digit1 < digit2 then return -1*sign end
    end
    digit_index = digit_index + 1
  end

end

-- n1 + n2
-- summation operation
local function number_sum(n1,n2)
  -- sum: n1==0 or/and n2==0
  if number_is_zero(n1) then return n2 end
  if number_is_zero(n2) then return n1 end
  
  -- sum: n1 not zero and n2 not zero
  
  local compare = number_compare(n1,n2)
  
  local sign
  if compare==1 or compare==0 then
    -- n1 is greater than n2
    sign = n1.sign
    
  elseif compare==-1 then
    -- n2 is greater than n1
    sign = n2.sign
    n2,n1 = n1,n2 -- swap: greater minus lesser
    -- now: n1 is greater than n2
  end
  
  -- mode == 1 : summation ; mode == -1 : subtraction
  local mode = n1.sign * n2.sign
  
  -- "summation or subtraction" follows
  
  local result = {} -- out-put result
  local position = 0 -- initial digit-position
  local carry_digit = 0 -- summation
  local borrow_digit = 0 -- difference
  
  -- align digits-places
  local decimal_places = math.max( n1.decimal_places, n2.decimal_places)
  
  while true do -- usage of "break" to exit (exit-condition)
    
    -- 2 in-put digits
    local digit1 = n1[#n1-position + (decimal_places-n1.decimal_places)]
    local d1= digit1 or 0
    local digit2 = n2[#n2-position + (decimal_places-n2.decimal_places)]
    local d2= digit2 or 0
    
    -- 1 out-put digit
    local digit
    
    -- summation: mode==1
    if mode==1 then
      
      -- exit condition
      if carry_digit == 0 and (not digit1 and not digit2) then break end
      
      -- ouput digit
      local summation = d1 + d2 + carry_digit

      if summation > 9 then
        digit = summation - 10
        carry_digit = 1
      else
        digit = summation
        carry_digit = 0
      end
    
    -- subtraction: mode==-1
    elseif mode==-1 then
      
      -- exit condition
      if not digit1 and not digit2 then break end
      
      -- ouput digit
      local difference = d1 - d2 - borrow_digit
      
      if difference < 0 then
        digit = difference + 10
        borrow_digit = 1
      else
        digit = difference
        borrow_digit = 0
      end
      
    end
    
    -- in "result" table, insert digit at the beginning
    table.insert(result,1, digit)
    
    -- increment by 1
    position = position + 1 
  end
  
  -- result's sign and result's decimal places
  result.sign = sign
  result.decimal_places = decimal_places
  
  -- result: normalize before out-put-ting
  normalize(result)
  
  -- out-put
  return result
end

-- n1 - n2
-- subtraction operation
local function number_sub(n1,n2)
  number_unary_minus(n2)
  local result = number_sum(n1,n2)
  number_unary_minus(n2)
  return result
end

-------------------------------------------------
-- https://replit.com/@dariocangialosi/introduzionelua#introduzione.lua

local num = number_text_to_digit_sequence
local somma = number_sum
local sottr = number_sub
local confr = number_compare
local txt = number_digit_sequence_to_text

-- per i numeri naturali
local function moltiplicazione(da_accumulare, quante_volte)
  local accumulatore=0
  while quante_volte>0 do
    accumulatore = accumulatore + da_accumulare
    quante_volte = quante_volte - 1
  end
  return accumulatore
end

-- per i numeri naturali
local function GMP_moltiplicazione(da_accumulare, quante_volte)
  local accumulatore=num('0')
  while confr( quante_volte , num('0') )==1 do
    accumulatore = somma( accumulatore , da_accumulare )
    quante_volte = sottr( quante_volte , num('1') )
  end
  return accumulatore
end

-- per i numeri naturali
local function divisione_resto(dividendo, divisore)
  local quoziente=0
  local resto=0
  while divisore <= dividendo do
    dividendo = dividendo - divisore
    quoziente = quoziente + 1
  end
  resto = dividendo
  return quoziente, resto
end

-- per i numeri naturali
local function GMP_divisione_resto(dividendo, divisore)
  local quoziente=num('0')
  local resto=num('0')
  while confr( divisore , dividendo ) <= 0 do
    dividendo = sottr( dividendo , divisore )
    quoziente = somma( quoziente , num('1') )
  end
  resto = dividendo
  return quoziente, resto
end

print("------------------------")

do
local a='2.5'; local b='3'
print(a.." * "..b)
print('prodotto',txt(GMP_moltiplicazione(num(a),num(b))))
end

print("------------------------")

do
local a='7.5'; local b='3'
print(a.." // "..b)
local quoziente,resto=GMP_divisione_resto(num(a),num(b))
print('quoziente',txt(quoziente)); print('resto',txt(resto))
end

-- ********************************************

local function number_tests()

print("------------ Tests -------------")

local function test_summation_subtraction(n1, n2)
  print('-------- test_summation_subtraction ----------------')
  
  printn(n1); printn(n2)
  
  print('n3 = n1 + n2')
  local n3 = number_sum(n1,n2)
  printn( n3 )

  print('n4 = n3 - n2')
  local n4 = number_sub(n3,n2)
  printn( n4 )
  
  print("comparison:", comparison_to_text(number_compare(n1,n4)))
end

local n1,n2

n1 = number_text_to_digit_sequence"9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999.9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999"

n2 = number_text_to_digit_sequence"0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"

test_summation_subtraction(n1, n2)

end

-- https://github.com/arkenidar/lua-numbers/blob/main/numbers.lua

-- https://replit.com/@dariocangialosi/numbers#main.lua

number_tests()
