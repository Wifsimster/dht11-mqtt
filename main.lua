require('config')
require('dht11')

DATA_PIN = 3 -- GPIO_0

-- MQTT client
TOPIC = "/sensors/bureau/dht11/data"

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")

tmr.alarm(2, 1000, 1, function()
    tmr.stop(2)
    print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
    m:connect(BROKER_IP, BROKER_PORT, 0, function(conn)
        print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
        dht11_data = getData(DATA_PIN)
        temperature = tonumber(dht11_data.temperature)
        humidity = tonumber(dht11_data.humidity)
        
        -- First send data
        DATA = '{"temperature":"'..temperature..'","humidity":"'..humidity..'"}'
        m:publish(TOPIC, DATA, 0, 0, function(conn)
            print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
        end)
        
        -- Check every 5s for values change
        tmr.alarm(1, 5000, 1, function()
            dht11_data = getData(DATA_PIN)
            tmp_temperature = tonumber(dht11_data.temperature)
            tmp_humidity = tonumber(dht11_data.humidity)
            if(temperature ~= tmp_temperature or humidity ~= tmp_humidity) then
                DATA = '{"temperature":"'..tmp_temperature..'","humidity":"'..tmp_humidity..'"}'
                -- Publish a message (QoS = 0, retain = 0)
                m:publish(TOPIC, DATA, 0, 0, function(conn)
                    print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
                end)
            else
                print("No change in value, no data send to broker.")
            end
        end)
    end)
end)

m:close();
