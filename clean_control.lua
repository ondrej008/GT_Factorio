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
function encode(R,S,T)
  local U;
  local V;
  local W;
  for G,X in pairs(R) do 
    W=nil;
    for G,Y in pairs(T) do 
      if type(X[Y])=="string" then 
        if W~=nil then 
          W=W..",\""..Y.."\": \""..X[Y].."\""
        else W="\""..Y.."\": \""..X[Y].."\""
        end 
      elseif type(X[Y])=="number" then 
        if W~=nil then 
          W=W..",\""..Y.."\": "..tostring(X[Y])
        else 
          W="\""..Y.."\": "..tostring(X[Y])
        end 
      elseif type(X[Y])=="boolean" then 
        if W~=nil then 
          W=W..",\""..Y.."\": "..tostring(X[Y])
        else W="\""..Y.."\": "..tostring(X[Y])
        end 
      end 
    end;
    if W~=nil and V~=nil then 
      V=V..", {"..W.."}"
    else 
      V="{"..W.."}"
    end 
  end;
  U="{".."\""..S.."\": ["..V.."]}"
  return U 
end;
function drawToolbar()
  for G,Z in pairs(game.connected_players) do 
    local s=Z.gui.top;clearElement(s)
    drawButton(
      s,
      "btn_toolbar_playerList",
      "Playerlist",
      "Adds a player list to your game."
    )
    drawButton(
      s,
      "btn_toolbar_rocket_score",
      "Rocket score",
      "Show the satellite launched counter if a satellite has launched."
    )
    drawButton(
      s,
      "btn_readme",
      "Readme",
      "Rules, Server info, How to chat, Playerlist, Adminlist."
    )
    if Z.tag=='[Owner]'or Z.tag=='[Developer]'or Z.tag=='[Com Mngr]' then 
      drawButton(
        s,
        "btn_admin",
        "Admin",
        "All admin fuctions are here"
      )
    end 
  end 
end;
function 
  drawPlayerList()
  for G,Z in pairs(game.connected_players) do 
    if Z.gui.left.PlayerList==nil then 
      Z.gui.left.add{
        type="frame",
        name="PlayerList",
        direction="vertical"
      }.add{
        type="scroll-pane",
        name="PlayerListScroll",
        direction="vertical",
        vertical_scroll_policy="always",
        horizontal_scroll_policy="never"
      }
    end;
    clearElement(Z.gui.left.PlayerList.PlayerListScroll)
    Z.gui.left.PlayerList.PlayerListScroll.style.maximal_height=200;
    for G,r in pairs(game.connected_players) do 
      if r.character then 
        if r.tag=='[Jail]' or r.character.active==false then 
          Z.gui.left.PlayerList.PlayerListScroll.add{
            type="label",
            name=r.name,
            style="caption_label_style",
            caption={"",ticktohour(r.online_time)," H - ",r.name," - Jail"}
          }
          Z.gui.left.PlayerList.PlayerListScroll[r.name].style.font_color={r=50,g=50,b=50}
          r.character.active=false;
          r.tag='[Jail]'
        end 
      end;
      if r.admin==true and r.tag~='[Jail]' then 
        if r.name=="badgamernl" or r.name=="BADgamerNL" then 
          Z.gui.left.PlayerList.PlayerListScroll.add{
            type="label",
            name=r.name,
            style="caption_label_style",
            caption={"",ticktohour(r.online_time)," H - ",r.name," - OWNER"}
          }
          Z.gui.left.PlayerList.PlayerListScroll[r.name].style.font_color={r=170,g=0,b=0}
          r.tag="[Owner]"
        elseif r.name=="eissturm" or r.name=="PropangasEddy"
          then Z.gui.left.PlayerList.PlayerListScroll.add{
            type="label",
            name=r.name,
            style="caption_label_style",
            caption={"",ticktohour(r.online_time)," H - ",r.name," - ADMIN"}
          }
          Z.gui.left.PlayerList.PlayerListScroll[r.name].style.font_color={r=170,g=41,b=170}
          r.tag="[Admin]"
        elseif r.name=="Cooldude2606" then 
          Z.gui.left.PlayerList.PlayerListScroll.add{
            type="label",
            name=r.name,
            style="caption_label_style",
            caption={"",ticktohour(r.online_time)," H - ",r.name," - DEV"}
          }
          Z.gui.left.PlayerList.PlayerListScroll[r.name].style.font_color={r=179,g=125,b=46}r.tag="[Developer]"
        elseif r.name=="arty714" then 
          Z.gui.left.PlayerList.PlayerListScroll.add{
            type="label",
            name=r.name,
            style="caption_label_style",
            caption={"",ticktohour(r.online_time)," H - ",r.name," - CM"}
          }
          Z.gui.left.PlayerList.PlayerListScroll[r.name].style.font_color={r=150,g=68,b=161}r.tag="[Com Mngr]"
        else 
          Z.gui.left.PlayerList.PlayerListScroll.add{
            type="label",
            name=r.name,
            style="caption_label_style",
            caption={"",ticktohour(r.online_time)," H - ",r.name," - MOD"}
          }
          Z.gui.left.PlayerList.PlayerListScroll[r.name].style.font_color={r=233,g=63,b=233}r.tag="[Moderator]"
        end 
      end 
    end;
    for G,r in pairs(game.connected_players) do 
      if r.admin==false and r.tag~='[Jail]' then 
        if ticktominutes(r.online_time)>=timeForRegular then 
          Z.gui.left.PlayerList.PlayerListScroll.add{
            type="label",
            name=r.name,
            style="caption_label_style",
            caption={"",ticktohour(r.online_time)," H - ",r.name}
          }
          Z.gui.left.PlayerList.PlayerListScroll[r.name].style.font_color={r=24,g=172,b=188}r.tag="[Regular]"
        elseif r.name=="explosivegaming" then 
          for G=10,1,-1 do 
            Z.gui.left.PlayerList.PlayerListScroll.add{
              type="label",
              name=r.name..G,
              style="caption_label_style",
              caption={"",ticktohour(r.online_time)," H - ",r.name,G}
            }
            Z.gui.left.PlayerList.PlayerListScroll[r.name..G].style.font_color={r=24,g=172,b=188}r.tag="[TEST]"
          end 
        else 
          Z.gui.left.PlayerList.PlayerListScroll.add{
            type="label",
            name=r.name,
            style="caption_label_style",
            caption={"",ticktohour(r.online_time)," H - ",r.name}
          }
          Z.gui.left.PlayerList.PlayerListScroll[r.name].style.font_color={r=255,g=159,b=27}r.tag="[Guest]"
        end 
      end 
    end 
  end 
end;
addButton(
  'goto',
  function(r,s)
    local _=game.players[s.parent.name]
    r.teleport(game.surfaces[_.surface.name].find_non_colliding_position("player",_.position,32,1))
end)
function drawPlayerTable(r,s,K,J)
  s.add{name='playerTable',type="table",colspan=5}
  s.playerTable.style.minimal_width=500;
  s.playerTable.style.maximal_width=500;
  s.playerTable.style.horizontal_spacing=10;
  s.playerTable.add{name="id",type="label",caption="Id		"}
  s.playerTable.add{name="name",type="label",caption="Name		"}
  if not K then 
    s.playerTable.add{name="status",type="label",caption="Status		"}
  end;
  s.playerTable.add{name="online_time",type="label",caption="Online Time	"}
  s.playerTable.add{name="rank",type="label",caption="Rank	"}
  if K then 
    s.playerTable.add{name="commands",type="label",caption="Commands"}
  end;
  for G,_ in pairs(game.players) do 
    local a0=true;
    for d,a1 in pairs(J) do 
      if a1=='admin' then 
        if _.admin==false then 
          a0=false;
          break 
        end 
      elseif a1=='online' then 
        if _.connected==false 
          then a0=false;
          break 
        end 
      elseif a1=='offline' then 
        if _.connected==true then 
          a0=false;
          break 
        end 
      elseif type(a1)=='number' then 
        if a1>ticktominutes(_.online_time) then 
          a0=false;
          break 
        end 
      elseif type(a1)=='string' then 
        if _.name:lower():find(a1:lower())==nil then 
          a0=false;
          break
        end
      end 
    end;
    if a0==true and r.name~=_.name then 
      if s.playerTable[_.name]==nil then 
        s.playerTable.add{name=G.."id",type="label",caption=G}
        s.playerTable.add{name=_.name..'_name',type="label",caption=_.name}
        if not K then 
          if _.connected==true then 
            s.playerTable.add{name=_.name.."Status",type="label",caption="ONLINE"}
          else s.playerTable.add{name=_.name.."Status",type="label",caption="OFFLINE"}
          end 
        end;
        s.playerTable.add{
          name=_.name.."Online_Time",
          type="label",
          caption=ticktohour(_.online_time)..'H '..ticktominutes(_.online_time)-60*ticktohour(_.online_time)..'M'
        }
        s.playerTable.add{name=_.name.."Rank",type="label",caption=_.tag}
        if K then 
          s.playerTable.add{name=_.name,type="flow"}
          drawButton(s.playerTable[_.name],'goto','Tp','Goto to the players location')
          drawButton(s.playerTable[_.name],'bring','Br','Bring a player to your location')
          if _.tag=='[Owner]'or _.tag=='[Developer]'or _.tag=='[Com Mngr]'then 
          else 
            drawButton(
              s.playerTable[_.name],
              'jail',
              'Ja',
              'Jail/Unjail a player'
            )
            drawButton(
              s.playerTable[_.name],
              'kill',
              'Ki',
              'Kill this player'
            )
          end 
        end 
      end 
    end 
  end 
end;
