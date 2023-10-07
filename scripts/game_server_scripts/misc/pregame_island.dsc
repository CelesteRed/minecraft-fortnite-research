
##make sure to disable lobby circle fx after game starts

pregame_island_handler:
  type: world
  debug: false
  definitions: square
  events:

    ######when server starts, set the chests, ammo boxes, and floor loot
    ###MAKE SURE TO DEBUG IT IN THE CONSOLE
    on server start:
    - bossbar create fort_info title:<proc[spacing].context[50]><&chr[A004].font[icons]><proc[spacing].context[-72]><&l><element[WAITING FOR PLAYERS].font[lobby_text]> color:YELLOW players:<server.online_players>

    on player enters fort_lobby_circle:
    - title title:<&font[denizen:black]><&chr[0004]><&chr[F801]><&chr[0004]> fade_in:7t stay:0s fade_out:1s
    - cast LEVITATION duration:8t amplifier:3 no_ambient no_clear no_icon hide_particles
    - wait 7t
    - teleport <player> <server.flag[fort.menu_spawn].above[0.5]>

    ##################################TEMP WORLD CHANGE SHIT
    on player changes world from fort_pregame_island:
    - define mode solo
    - flag server fort.available_servers.solo.test.players:<-:<player>
    - bossbar remove fort_info players:<player>

    on player changes world to fort_pregame_island:

    - flag player fort.wood.qty:0
    - flag player fort.brick.qty:0
    - flag player fort.metal.qty:0

    - foreach <list[light|medium|heavy|shells|rockets]> as:ammo_type:
      - flag player fort.ammo.<[ammo_type]>:999

    - flag player fort.in_queue:!

    - run update_hud
    - run minimap
    - wait 10t
    - bossbar update fort_info color:YELLOW players:<player>

    ##<server.online_players_flagged[fort].size>
    - if <world[fort_pregame_island].players.size> >= <script[nimnite_config].data_key[minimum_players]> && !<server.has_flag[fort.temp.game_starting]>:
      - run pregame_island_handler.countdown

  countdown:
    - define min_players <script[nimnite_config].data_key[minimum_players]>
    - define +spacing    <proc[spacing].context[99]>
    - define -spacing    <proc[spacing].context[-121]>
    - define bus_icon    <&chr[A025].font[icons]>
    - define clock_icon  <&chr[0004].font[icons]>

    - flag server fort.temp.game_starting
    #flagging phase for hud updating manually too
    - flag server fort.temp.phase:bus
    - repeat 10:
      ##<server.online_players_flagged[fort]>
      - define players <world[fort_pregame_island].players>
      - define seconds <element[10].sub[<[value]>]>
      - define timer <time[2069/01/01].add[<[seconds]>].format[m:ss]>

      - flag server fort.temp.timer:<[timer]>

      - bossbar update fort_info title:<[+spacing]><[bus_icon]><[-spacing]><&l><element[BATTLE BUS LAUNCHING IN].font[lobby_text]><&sp><element[<&d><&l><[seconds]> Seconds].font[lobby_text]> color:YELLOW players:<[players]>
      - sidebar set_line scores:5 values:<element[<&chr[0025].font[icons]> <[timer]>].font[hud_text].color[<color[50,0,0]>]> players:<[players]>

      - wait 1s
      ##<server.online_players_flagged[fort]>
      - define players <world[fort_pregame_island].players>
      - if <[players].size> < <[min_players]>:
        - bossbar update fort_info title:<proc[spacing].context[50]><&chr[A004].font[icons]><proc[spacing].context[-72]><&l><element[WAITING FOR PLAYERS].font[lobby_text]> color:YELLOW players:<[players]>
        - sidebar set_line scores:5 values:<element[<[clock_icon]> -].font[hud_text].color[<color[50,0,0]>]> players:<[players]>

        - flag server fort.temp:!
        - stop

    - announce start_game

    ###remove this
    - flag server fort.temp:!


  lobby_circle:
    anim:
      - define loc <server.flag[fort.pregame.lobby_circle.loc].with_pose[0,0]>
      - define circle <server.flag[fort.pregame.lobby_circle.circle]>

      - flag server fort.lobby_circle_enabled

      - while <server.has_flag[fort.lobby_circle_enabled]>:
        - if <[circle].is_spawned>:
          - adjust <[circle]> interpolation_start:0
          - adjust <[circle]> left_rotation:<quaternion[0,0,1,0].mul[<location[0,0,-1].to_axis_angle_quaternion[<[loop_index].div[85]>]>]>
          - adjust <[circle]> interpolation_duration:1t

        #-square
        - if <[loop_index].mod[6]> == 0:
          - define size <util.random.decimal[1.2].to[1.9]>
          #- define dest <[loc].above[<util.random.decimal[1.8].to[2.6]>]>

          - define origin <[loc].below[0.4].random_offset[0.75,0,0.75]>
          - define end_translation   0,<util.random.decimal[1.8].to[2.6]>,0

          - spawn <entity[text_display].with[text=<element[⬛].color[#<list[D8F0FF|AAF4FF].random>]>;pivot=VERTICAL;scale=<[size]>,<[size]>,<[size]>;background_color=transparent]> <[origin]> save:fx
          - define fx <entry[fx].spawned_entity>

          - wait 1t

          - adjust <[fx]> interpolation_start:0
          - adjust <[fx]> translation:<[end_translation]>
          - adjust <[fx]> scale:0,0,0
          - adjust <[fx]> interpolation_duration:50t
          - run fort_global_handler.death_fx.remove_square def:<map[square=<[fx]>;wait=52]>
        - else:
          - wait 1t