require('config')
require('dht11')

TOPIC = "/sensors/"..LOCATION.."/dht11/data"

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")

ip = wifi.sta.getip()

m:lwt("/offline", '{"message":"'..CLIENT_ID..'", "topic":"'..TOPIC..'", "ip":"'..ip..'"}', 0, 0)

print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
    print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
    tmr.alarm(1, REFRESH_RATE, 1, function()
        dht11_data = getData(DATA_PIN)
        temperature = tonumber(dht11_data.temperature)
        humidity = tonumber(dht11_data.humidity)        
        DATA = '{"mac":"'..wifi.sta.getmac()..'", "ip":"'..ip..'",'
        DATA = DATA..'"temperature":"'..temperature..'","humidity":"'..humidity..'"}'        
        -- Publish a message (QoS = 0, retain = 0)
        m:publish(TOPIC, DATA, 0, 0, function(conn)
            print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
        end)
    end)
end)
