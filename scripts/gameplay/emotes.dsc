fort_emote_handler:
  type: world
  debug: false
  events:
    on player clicks in inventory slot:2|3|4|5:
    - if <context.clicked_inventory.inventory_type> != CRAFTING:
      - stop
    - determine passively cancelled
    - define emote <map[2=default;3=none;4=none;5=none].get[<context.slot>]>

    #second check is for if they're already emoting
    - if <[emote]> == none || <player.has_flag[fort.emote]>:
      - stop

    - choose <[emote]>:
      - case default:
        - define sound fort.emotes.default.<util.random.int[1].to[3]>
        - playsound <player.location> custom sound:<[sound]> volume:1.2

    #- run pmodels_spawn_model def.location:<player.location.above[2]> def.player:<player> def.scale:<location[1.87,1.87,1.87]> save:result
    - run dmodels_spawn_model def.player:<player> def.model_name:emotes def.location:<player.location.above[2]> save:result
    - define spawned <entry[result].created_queue.determination.first||null>
    - if !<[spawned].is_truthy>:
        - narrate "<&[error]>Emote spawning failed?"
        - stop

    #"remove" everything for their hands
    - fakeequip <player> for:<server.online_players> hand:air duration:10s

    #- run dmodels_set_yaw def.root_entity:<[spawned]> def.yaw:<player.location.yaw>
    - run dmodels_set_scale def.root_entity:<[spawned]> def.scale:1.87,1.87,1.87

    - spawn INTERACTION[height=2;width=1] <player.location> save:hitbox
    - define hb <entry[hitbox].spawned_entity>
    - flag <[hb]> emote.hitbox.host:<player>

    - flag player fort.emote.sound:<[sound]>
    - flag player spawned_dmodel_emotes:<[spawned]>
    - flag <[spawned]> emote_host:<player>
    - flag <[spawned]> emote_sound:<[sound]>
    - flag <[spawned]> emote_hitbox:<[hb]>
    - run dmodels_animate def.root_entity:<[spawned]> def.animation:<[emote]>

    on player clicks block flagged:fort.emote:
    - flag player fort.emote:!

    #this flag is added in dmodels_animating.dsc for the third person viewer
    #this event also fires when the player goes offline (but doesnt work?)
    on player exits vehicle flagged:fort.emote:
    - flag player fort.emote:!

    on player quits flagged:fort.emote:
    - invisible <player> false
    - fakeequip <player> for:<server.online_players> reset
    - if <player.has_flag[spawned_dmodel_emotes]>:
      - define model <player.flag[spawned_dmodel_emotes]>
      - define cam   <[model].flag[camera]>
      - define stand <[model].flag[stand]>
      - define hb    <[model].flag[emote_hitbox]>
      - remove <[cam]>   if:<[cam].is_spawned>
      - remove <[stand]> if:<[stand].is_spawned>
      - remove <[hb]>    if:<[hb].is_spawned>
    - flag player fort.emote:!