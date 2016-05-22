function getData(pin)
  humidity = 0
  humidityDec = 0
  temperature = 0
  temperatureDec = 0
  checksum = 0
  checksumTest = 0
  bitStream = {}
  for j = 1, 40, 1 do
    bitStream[j] = 0
  end
  bitlength = 0
  gpio.mode(pin, gpio.OUTPUT)
  gpio.write(pin, gpio.LOW)
  tmr.delay(20000)
  gpio_read=gpio.read
  gpio_write=gpio.write
  gpio.mode(pin, gpio.INPUT)
  while (gpio_read(pin)==0) do end
  c=0
  while (gpio_read(pin)==1 and c<100) do c=c+1 end
  while (gpio_read(pin)==0) do end
  c=0
  while (gpio_read(pin)==1 and c<100) do c=c+1 end
  for j = 1, 40, 1 do
    while (gpio_read(pin)==1 and bitlength<10) do
      bitlength=bitlength+1
    end
    bitStream[j]=bitlength
    bitlength=0
    while (gpio_read(pin)==0) do end
  end
  for i = 1, 8, 1 do
    if (bitStream[i+0] > 2) then
      humidity = humidity+2^(8-i)
    end
  end
  for i = 1, 8, 1 do
    if (bitStream[i+8] > 2) then
      humidityDec = humidityDec+2^(8-i)
    end
  end
  for i = 1, 8, 1 do
    if (bitStream[i+16] > 2) then
      temperature = temperature+2^(8-i)
    end
  end
  for i = 1, 8, 1 do
    if (bitStream[i+24] > 2) then
      temperatureDec = temperatureDec+2^(8-i)
    end
  end
  for i = 1, 8, 1 do
    if (bitStream[i+32] > 2) then
      checksum = checksum+2^(8-i)
    end
  end  
  checksumTest=(humidity+humidityDec+temperature+temperatureDec) % 0xFF
  rst = {}
  rst["temperature"] = temperature.."."..temperatureDec
  rst["humidity"] = humidity.."."..humidityDec
  return rst
end
