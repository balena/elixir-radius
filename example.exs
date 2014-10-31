require Logger
RadiusDict.start_link("dict/dictionary")
#IO.puts inspect RadiusDict.Vendor.by_name("Cisco")
#IO.puts inspect RadiusDict.Attribute.by_name("Service-Type")
#IO.puts inspect RadiusDict.Value.by_name("Service-Type","Login-User")
#IO.puts inspect RadiusDict.Value.by_value(6,11)
#IO.puts inspect RadiusDict.Value.by_name("Cisco","Cisco-Disconnect-Cause","Unknown")
#IO.puts inspect RadiusDict.Value.by_value(9,195,11)
#IO.puts inspect RadiusDict.Value.by_value(9,1950,11)

secret = "112233"

attrs = [
  {"Tunnel-Type","PPTP"},
  {"User-Password","1234"},
  {"Tunnel-Type",{0,"PPTP"}},
  {"Tunnel-Type",{10,"PPTP"}},
  #test name resolve
  {"Service-Type","Login-User"},
  #test id resolve
  {6,1},
  #test fot has_tag
  {"NAS-IP-Address",{1,2,3,4}},
  {"NAS-IP-Address",0x12345678},
  {"Login-IPv6-Host",{2003,0xefff,0,0,0,0,0,4}},
  #test VSA
  {{"Vendor-Specific",9},[
    {"Cisco-Disconnect-Cause",10},
    {195,100,"Unknown"}
  ]},
  #empty VSA?
  {{"Vendor-Specific",311},[]},
  {255,"123456"}
]

p = %Radius.Packet{code: "Access-Request", id: 12, auth: nil, secret: secret, attrs: attrs}
data =  Radius.Packet.encode p
Logger.debug "data=#{inspect data}"
p = Radius.Packet.decode :erlang.iolist_to_binary(data),p.secret
Logger.debug inspect p, pretty: true

p = %Radius.Packet{code: "Access-Accept", id: 12, auth: p.auth, secret: secret, attrs: p.attrs}
data =  Radius.Packet.encode p
Logger.debug "data=#{inspect data}"
#password decoding SHOULD FAIL here, guess why?
p = Radius.Packet.decode :erlang.iolist_to_binary(data),p.secret
Logger.debug inspect p, pretty: true

{:ok,sk} = Radius.listen 1812
{:ok,host,p} = Radius.recvfrom sk,"123"
IO.puts "From #{inspect host} : \n#{inspect p, pretty: true}"
resp = %Radius.Packet{code: "Access-Reject", id: p.id, auth: p.auth, secret: p.secret}
Radius.sendto sk,host,resp