
print("codici parziali quindi rotti, prendere gli interi")

--[[
dualismi in matematica:
- moltiplicazione come somma e suo inverso la divisione mediante sottrazioni (o altre implementazioni a parità di risultati)
- somma algebrica con riporto (carry) o prestito (borrow) che sono uno il duale dell'altro come moltiplicazione e somma sono uno l'inverso dell'altro
(spiegazioni intuitive non con linguaggio gergale necessariamente corretto).

si può vedere l'unità della parte comune che si diversifica specializzandosi, come da un arbusto gemmano ad esempio due rametti.
in particolare 2 data la struttura hardware del calcolatore elettronico binario (binario, base 2, due simboli, 0 e 1, detti 2 bits).
]]

------------------------------------------------------------------------------------

-- https://replit.com/@dariocangialosi/introduzionelua#introduzione.lua

-- per i numeri naturali
function moltiplicazione(da_accumulare, quante_volte)
  local accumulatore=0
  while quante_volte>0 do
    accumulatore = accumulatore + da_accumulare
    quante_volte = quante_volte - 1
  end
  return accumulatore
end

-- per i numeri naturali
function divisione_resto(dividendo, divisore)
  local quoziente=0
  local resto=0
  while divisore <= dividendo do
    dividendo = dividendo - divisore
    quoziente = quoziente + 1
  end
  resto = dividendo
  return quoziente, resto
end

-- https://replit.com/@dariocangialosi/introduzionelua#introduzione.lua

------------------------------------------------------------------------------------

-- https://replit.com/@dariocangialosi/numbers#main.lua

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

-- https://replit.com/@dariocangialosi/numbers#main.lua

------------------------------------------------------------------------------------
