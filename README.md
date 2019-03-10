# esx_anticheat
It's an anticheat resource for the ESX framework running on FiveM.  I mean come on.  That's kind of obvious from the name, isn't it?

There is no support topic for this release on the FiveM forums.  If you need assistance, either submit an issue here or use the following Discord channel for support: https://discord.gg/muJyeM5

This resource spawns from a lot of previous works but primarily, the following two resources were vital in creating this and they should be thanked for their hard work:

**HG_AntiCheat:** https://forum.fivem.net/t/anticheat-for-fivem-stayfrosty-community/248835

**FiveM-BanSql:** https://forum.fivem.net/t/release-fivem-bansql/142487

This resource requires the ESX framework and it's dependencies.

**Install:** Drop folder into your resources directory, add "start esx_anticheat" to your server.cfg, add the sql file to your database and start your server.

**PLEASE NOTE: If you have installed the tables for FiveM-BanSql before, you can skip running the sql as it they are the same.**

**Configuration:**  The config file allows you to set the number of peds before the excess get deleted, whitelist steamIDs that don't get auto-whitelisted based on their group and set your blacklisted props, vehicles and weapons.

**What It Does:**  It will ban non-whitelisted users that superjump or sit in a blacklisted car the blacklisted car will also be deleted.  It will strip all weapons from a user that equips a blacklisted weapon. It will delete blacklisted props as they are spawned.  It will set a cap on peds in a player's area, preventing them from spawning numbers over your set threshold.

**Ban Controls:**  This is directly from the FiveM-BanSql page.  Currently, the ban system remains unchanged:

# Commands
___
1. **ban id days reason** (	Allows ban a connected player	)
 - "id" is the player's number in the list
 - "days" must be a number to say how many days it will be ban. (0 days mean permanent)
 - "reason" Ability to register why he is banished. Attention if there is no reason the player will see: "You are banned for: unknown reason"
 - example /ban 3 1 Troll (Will give ban player # 3 for 1 days with Troll reason)
___
2. **banoffline days name** (	   Allows ban a offline player	  )
 - "days" must be a number to say how many days it will be ban. (0 days mean permanent)
 - "name" is the player's steam name
 - example /banoffline 3 Alex Garcio (Will ask you to entry ban:reason to continu)
2.1 ***reason (reason)
 - "reason" Ability to register why he is banished.
 - example /reason reason (Will ban player you have entry before for X days and the reason)
___
3. **unban "Steam Name"**
 - Deban the player matching the written name.
 - Example ban:unban Alex Garcio (Will remove from the ban list the player)
___
4. **banreload ** (reload the BanList and the BanListHistory)
  - Can be used if you edit directly in your database.
___
5. **banhistory option** (Allows you to view the ban history of a player offline or online)
- "option"
- (Name of a player) To display all the banns of a player
- 1 To display only the first ban
- 2 To display only the second ban
- 3 ect ......
- 4 ect ......
- Example /banhistory Alex Garcio (Go to display all the list of player's bans)
