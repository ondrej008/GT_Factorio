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
]]
local function a(b,c)
  if b.find_entities_filtered{area=c,type="decorative"} then 
    for d,e in pairs(b.find_entities_filtered{area=c,type="decorative"}) do 
      if e.name~="red-bottleneck"and e.name~="yellow-bottleneck"and e.name~="green-bottleneck" then 
        e.destroy()
      end 
    end 
  end
end;
local function f(b,g,h,i,j)
  a(b,{{g,h},{g+i,h+j}})
end;
local function k()
  local b=game.surfaces["nauvis"]
  for l in b.get_chunks() do 
    f(b,l.x*CHUNK_SIZE,l.y*CHUNK_SIZE,CHUNK_SIZE-1,CHUNK_SIZE-1)
  end;
  callAdmin("Decoratives have been removed")
end;
script.on_event(
  defines.events.on_chunk_generated,
  function(m)
    a(m.surface,m.area)
  end)
script.on_event(
  defines.events.on_player_created,
  function(m)
    local r=game.players[m.player_index]
    r.insert{name="iron-plate",count=8}
    r.insert{name="pistol",count=1}
    r.insert{name="firearm-magazine",count=10}
    r.insert{name="burner-mining-drill",count=1}
    r.insert{name="stone-furnace",count=1}
    r.force.chart(r.surface,{{r.position.x-200,r.position.y-200},{r.position.x+200,r.position.y+200}})
  end)
script.on_event(
  defines.events.on_player_respawned,
  function(m)
    local r=game.players[m.player_index]
    drawPlayerList()
    r.insert{name="pistol",count=1}
    r.insert{name="firearm-magazine",count=10}
  end)
script.on_event(
  defines.events.on_player_joined_game,
  function(m)
    local r=game.players[m.player_index]
    r.print({"","Welcome"})
    if r.gui.left.PlayerList~=nil then 
      r.gui.left.PlayerList.destroy()
    end;
    if r.gui.center.README~=nil then 
      r.gui.center.README.destroy()
    end;
    if r.gui.top.PlayerList~=nil then 
      r.gui.top.PlayerList.destroy()
    end;
    drawPlayerList()
    drawToolbar()
    local H=encode(game.players,"players",{"name","admin","online_time","connected","index"})
    game.write_file("players.json",H,false,0)
    if not r.admin and ticktominutes(r.online_time)<1 then 
      drawFrame(r,'Readme','Rules')
    end 
  end)
script.on_event(
  defines.events.on_player_left_game,
  function(m)
    local r=game.players[m.player_index]
    drawPlayerList()
  end)
script.on_event(
  defines.events.on_gui_click,
  function(m)
    local r=game.players[m.player_index]
    for d,I in pairs(guis.buttons) do 
      if I[1]==m.element.name then 
        if I[2]then 
          I[2](r,m.element)
        else 
          game.print('Invaid Button'..I[1])
        end;
        break 
      end 
    end 
  end)
script.on_event(
  defines.events.on_gui_text_changed,
  function(m)
    local r=game.players[m.player_index]
    if m.element.parent.parent.filterTable then 
      local s=m.element;
      local J={}
      local K=false;
      if s.parent.parent.parent.name=='Admin' then 
        K=true;J[#J+1]='online'
      end;
      if s.parent.parent.filterTable.status_input and not K then 
        local L=s.parent.parent.filterTable.status_input.text;
        if L=='yes'or L=='online'or L=='true'or L=='y' then 
          J[#J+1]='online'
        elseif L~=''then 
          J[#J+1]='offline'
        end 
      end;
      if s.parent.parent.filterTable.hours_input then 
        local M=s.parent.parent.filterTable.hours_input.text;
        if tonumber(M)and tonumber(M)>0 then 
          J[#J+1]=tonumber(M)
        end 
      end;
      if s.parent.parent.filterTable.name_input then 
        local N=s.parent.parent.filterTable.name_input.text;
        if N then 
          J[#J+1]=N 
        end 
      end;
      if s.parent.parent.playerTable then 
        s.parent.parent.playerTable.destroy()
      end;
      drawPlayerTable(r,s.parent.parent,K,J)
    end 
  end)
script.on_event(defines.events.on_marked_for_deconstruction,
  function(m)
    local O=game.players[m.player_index]
    if not O.admin and ticktominutes(O.online_time)<timeForRegular then 
      if m.entity.type~="tree"and m.entity.type~="simple-entity" then 
        m.entity.cancel_deconstruction("player")
        O.print(
          "You are not allowed to do this yet, player for a bit longer. Try again in about: "
          ..math.floor(timeForRegular-ticktominutes(O.online_time))..
          " minutes"
        )
        callAdmin(O.name.." tryed to deconstruced something")
      end 
    elseif m.entity.type=="tree"or m.entity.type=="simple-entity" then 
      m.entity.destroy()
    end 
  end)
script.on_event(
  defines.events.on_built_entity,
  function(m)
    local O=game.players[m.player_index]
    local timeForRegular=120;
    if not O.admin and ticktominutes(O.online_time)<timeForRegular then 
      if m.created_entity.type=="tile-ghost" then 
        m.created_entity.destroy()
        O.print(
          "You are not allowed to do this yet, player for a bit longer. Try: "
          ..math.floor(timeForRegular-ticktominutes(O.online_time))..
          " minutes"
        )
        callAdmin(O.name.." tryed to place concrete/stone with robots")
      end 
    end 
  end)
script.on_event(
  defines.events.on_rocket_launched,
  function(m)
    local P=m.rocket.force;
    if m.rocket.get_item_count("satellite")==0 then 
      if#game.players<=1 then 
        game.show_message_dialog{text={"gui-rocket-silo.rocket-launched-without-satellite"}}
      else 
        for Q,r in pairs(P.players) do 
          r.print({"gui-rocket-silo.rocket-launched-without-satellite"})
        end 
      end;
      return 
    end;
    if not global.satellite_sent then 
      global.satellite_sent={}
    end;
    if global.satellite_sent[P.name] then 
      global.satellite_sent[P.name]=global.satellite_sent[P.name]+1 
    else 
      game.set_game_state{game_finished=true,player_won=true,can_continue=true}
      global.satellite_sent[P.name]=1 
    end;
    for Q,r in pairs(P.players) do 
      if r.gui.left.rocket_score then 
        r.gui.left.rocket_score.rocket_count.caption=tostring(global.satellite_sent[P.name])
      else 
        local s=r.gui.left.add{name="rocket_score",type="frame",direction="horizontal",caption={"score"}}
        s.add{name="rocket_count_label",type="label",caption={"",{"rockets-sent"},":"}}
        s.add{name="rocket_count",type="label",caption=tostring(global.satellite_sent[P.name])}
      end 
    end 
  end)
script.on_event(
  defines.events.on_tick,
  function(m)
    if game.tick/(3600*game.speed)%15==0 then 
      autoMessage()
    end 
end)
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
function autoMessage()
  game.print('There are '..#game.connected_players..' players online')
  game.print(
    'This map has been on for '
    ..ticktohour(game.tick)..
    ' Hours and '
    ..ticktominutes(game.tick)-60*ticktohour(game.tick)..
    ' Minutes'
  )
  game.print('Please join us on:')
  game.print('Discord: https://discord.gg/RPCxzgt')
  game.print('Forum: explosivegaming.nl')
  game.print('Steam: http://steamcommunity.com/groups/tntexplosivegaming')
  game.print('To see these links again goto: Readme > Server Info')
end;
function addFrame(s)
  guis.frames[s]={}
  addButton(
    'close',
    function(r,t)
      t.parent.parent.parent.destroy()
    end)
end;
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
function drawButton(s,x,z,v)
  s.add{name=x,type="button",caption=z,tooltip=v}
end;
function openTab(r,A,B,u)
  local C=r.gui.center[A].tabBarScroll.tabBar;
  for d,D in pairs(guis.frames[A]) do 
    if D[1]==u then 
      C[D[1]].style.font_color={r=255,g=255,b=255,a=255}
      clearElement(B)D[3](r,B)
    else 
      C[D[1]].style.font_color={r=100,g=100,b=100,a=255}
    end
  end
end;
function drawFrame(r,A,u)
  if r.gui.center[A] then 
    r.gui.center[A].destroy()
  end;
  local s=r.gui.center.add{name=A,type='frame',caption=A,direction='vertical'}
  local E=s.add{type="scroll-pane",name="tabBarScroll",vertical_scroll_policy="never",horizontal_scroll_policy="always"}
  local C=E.add{type='flow',direction='horizontal',name='tabBar'}
  local B=s.add{type="scroll-pane",name="tab",vertical_scroll_policy="auto",horizontal_scroll_policy="never"}
  for d,D in pairs(guis.frames[A]) do
    drawButton(C,D[1],D[1],D[2])
  end;
  openTab(r,A,B,u)
  drawButton(C,'close','Close','Close this window')
  B.style.minimal_height=300;
  B.style.maximal_height=300;
  B.style.minimal_width=500;
  B.style.maximal_width=500;
  E.style.minimal_height=60;
  E.style.maximal_height=60;
  E.style.minimal_width=500;
  E.style.maximal_width=500 
end;
function toggleVisable(s)
  if s then 
    if s.style.visible==nil then
      s.style.visible=false
    else 
      s.style.visible=not 
      s.style.visible 
    end 
  end 
end;
function clearElement(F)
  if F~=nil then 
    for G,t in pairs(F.children_names) do 
      F[t].destroy()
    end 
  end 
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
