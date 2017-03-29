itemRotated={}
entityRemoved={}
entityCache={}
guis={
  frames={},
  buttons={}
}
warningAllowed=nil;
timeForRegular=180;
CHUNK_SIZE=32;
--[[
TADY JSOU EVENTY
TADY JSOU EVENTY
]]
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="stone-furnace", count = 1}
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
  if (#game.players <= 1) then
    game.show_message_dialog{text = {"msg-intro"}}
  else
    player.print({"msg-intro"})
  end
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
end)

script.on_event(defines.events.on_rocket_launched, function(event)
  local force = event.rocket.force
  if event.rocket.get_item_count("satellite") == 0 then
    if (#game.players <= 1) then
      game.show_message_dialog{text = {"gui-rocket-silo.rocket-launched-without-satellite"}}
    else
      for index, player in pairs(force.players) do
        player.print({"gui-rocket-silo.rocket-launched-without-satellite"})
      end
    end
    return
  end
  if not global.satellite_sent then
    global.satellite_sent = {}
  end
  if global.satellite_sent[force.name] then
    global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1   
  else
    game.set_game_state{game_finished=true, player_won=true, can_continue=true}
    global.satellite_sent[force.name] = 1
  end
  for index, player in pairs(force.players) do
    if player.gui.left.rocket_score then
      player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
    else
      local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
      frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ":"}}
      frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
    end
  end
end)
--[[
TADY JSOU FUNKCE
TADY JSOU FUNKCE
]]
function addTab(s,u,v,w)
  guis.frames[s][u]={u,v,w}
  addButton(
    u,function(r,t)
      openTab(r,t.parent.parent.parent.name,t.parent.parent.parent.tab,t.name)
    end)
end;
function addButton(x,y)
  guis.buttons[x]={x,y}
end;
function ticktohour(n)
  local o=tostring(math.floor(n/(216000*game.speed)))
  return o 
end;
function ticktominutes(n)
  local p=math.floor(n/(3600*game.speed))
  return p 
end;
function callAdmin(q)
  for d,r in pairs(game.connected_players) do 
    if r.admin then
      r.print(q)
    end 
  end
end;
function addFrame(s)
  guis.frames[s]={}
  addButton(
    'close',
    function(r,t)
      t.parent.parent.parent.destroy()
    end)
end;

--[[
TADY JE ZBYTEK
]]
addFrame('Readme')
addTab(
  'Readme',
  'Rules',
  'The rules of the server',
  function(r,s)
    local a2={
      "Hacking/cheating, exploiting and abusing bugs is not allowed.",
      "Do not disrespect any player in the server (This includes staff).",
      "Do not spam, this includes stuff such as chat spam, item spam, chest spam etc.",
      "Do not laydown concrete with bots without permission.",
      "Do not use active provider chests without permission.",
      "Do not remove/move major parts of the factory without permission.",
      "Do not walk in a random direction for no reason(to save map size).",
      "Do not remove stuff just because you don't like it, tell people first.",
      "Do not make train roundabouts.","Trains are Left Hand Drive (LHD) only.",
      "Do not complain about lag, low fps and low ups or other things like that.",
      "Do not ask for rank.","Use common sense and what an admin says goes."}
    for G,a3 in pairs(a2) do 
      s.add{name=G,type="label",caption={"",G,". ",a3}}
    end 
  end)
addTab(
  'Readme',
  'Server Info',
  'Info about the server',
  function(r,s)
    s.add{name=1,type="label",caption={"","Discord voice and chat server:"}}
    s.add{name=2,type='textfield',text='https://discord.gg/RPCxzgt'}.style.minimal_width=400;
    s.add{name=3,type="label",caption={"","Our forum:"}}
    s.add{name=4,type='textfield',text='https://explosivegaming.nl'}.style.minimal_width=400;
    s.add{name=5,type="label",caption={"","Steam:"}}
    s.add{name=6,type='textfield',text='http://steamcommunity.com/groups/tntexplosivegaming'}.style.minimal_width=400 
  end)
addTab(
  'Readme',
  'How to chat',
  'Just in case you dont know how to chat',
  function(r,s)
    local a4={
      "Chatting for new players can be difficult because it’s different than other games!",
      "It’s very simple, the button you need to press is the “GRAVE/TILDE key”",
      "it’s located under the “ESC key”. If you would like to change the key go to your",
      "controls tab in options. The key you need to change is “Toggle Lua console”",
      "it’s located in the second column 2nd from bottom."}
    for G,a5 in pairs(a4) do 
      s.add{name=G,type="label",caption={"",a5}}
    end 
  end)
addTab(
  'Readme',
  'Admins',
  'List of all the people who can ban you :P',
  function(r,s)
    local a6={
      "This list contains all the people that are admin in this world. Do you want to become",
      "an admin dont ask for it! an admin will see what you've made and the time you put",
      "in the server."}
    for G,a5 in pairs(a6) do 
      s.add{name=G,type="label",caption={"",a5}}
    end;
    drawPlayerTable(r,s,false,{'admin'})
  end)
addTab(
  'Readme',
  'Players',
  'List of all the people who have been on the server',
  function(r,s)
    local a7={
      "These are the players who have supported us in the making of this factory. Without",
      "you the player we wouldn't have been as far as we are now."
    }
    for G,a5 in pairs(a7) do 
      s.add{name=G,type="label",caption={"",a5}}
    end;
    s.add{name='filterTable',type='table',colspan=3}
    s.filterTable.add{name='name_label',type='label',caption='Name'}
    s.filterTable.add{name='status_label',type='label',caption='Online?'}
    s.filterTable.add{name='hours_label',type='label',caption='Online Time (minutes)'}
    s.filterTable.add{name='name_input',type='textfield'}
    s.filterTable.add{name='status_input',type='textfield'}
    s.filterTable.add{name='hours_input',type='textfield'}
    drawPlayerTable(r,s,false,{})
end)
