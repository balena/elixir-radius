elixir-radius
=============

RADIUS protocol encoding and decoding

example
-------
```Elixir
#wrapper of gen_udp
{:ok,sk} = Radius.listen 1812

loop = fn(loop)->
  #secret can be a string or a function returning a string
  #{:ok,host,p} = Radius.recv sk,"123"
  {:ok,host,p} = Radius.recv sk,fn(_host) -> secret end

  IO.puts "From #{inspect host} : \n#{inspect p, pretty: true}"

  resp = %Radius.Packet{code: "Access-Reject", id: p.id, auth: p.auth, secret: p.secret}
  Radius.send sk,host,resp

  loop.(loop)
end
loop.(loop)
```
