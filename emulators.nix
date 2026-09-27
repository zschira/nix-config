{ config, pkgs, ... }:

let
  emulationStation = pkgs.fetchurl {
    url = "https://gitlab.com/es-de/emulationstation-de/-/package_files/288156961/download";
    hash = "sha256-PGGkTXONVRY9qljt5wcgtCWg32JGDATcI908pYZyNYE=";
  };
  retroarch = pkgs.retroarch;
  #retroarch = pkgs.retroarch.withCores (cores: with cores; [
  #  bsnes
  #  mupen64plus
  #  dolphin
  #]);

  desktop = pkgs.makeDesktopItem {
    name = "emulationstation";
    desktopName = "Emulation Station";
    exec = "${pkgs.appimage-run}/bin/appimage-run ${emulationStation}";
    terminal = false;
    categories = [ "Game" ];
  };

  retroarchCoreDir = "${retroarch}/lib/retroarch/cores";
in
{
  home.packages = [
    pkgs.appimage-run
    desktop
    retroarch
    pkgs.moonlight-qt
  ];

  home.file."Games/ROMs/moonlight/stream.sh" = {
    text = ''
#!${pkgs.bash}/bin/bash
exec ${pkgs.moonlight-qt}/bin/moonlight "$@"
'';
    executable = true;
  };
  home.file."ES-DE/custom_systems/es_systems.xml".text = ''
<?xml version="1.0"?>
<systemList>
  <system>
    <name>desktop</name>
    <fullname>Zach Desktop</fullname>
    <path>%ROMPATH%/moonlight</path>
    <extension>.sh</extension>
    <command>bash %ROM%</command>
    <platform>pc</platform>
    <theme>pc</theme>
  </system>
</systemList>
'';
  home.file."ES-DE/custom_systems/es_find_rules.xml".text = ''
<?xml version="1.0"?>
<ruleList>
    <emulator name="RETROARCH">
        <rule type="systempath">
            <entry>retroarch</entry>
            <entry>org.libretro.RetroArch</entry>
        </rule>
        <rule type="staticpath">
            <entry>${retroarch}/bin/retroarch</entry>
        </rule>
    </emulator>
    <core name="RETROARCH">
        <rule type="corepath">
            <entry>${retroarch}/lib/retroarch/cores</entry>
        </rule>
    </core>
</ruleList>
'';

/*
  home.file = {
    # N64
    "Games/ROMs/n64/GoldenEye 007 (USA).7z".source =
      "/media/games/GoldenEye 007 (USA).7z";

    "Games/ROMs/n64/Legend of Zelda, The - Majora's Mask (USA).7z".source =
      "/media/games/Legend of Zelda, The - Majora's Mask (USA).7z";

    "Games/ROMs/n64/Legend of Zelda, The - Ocarina of Time (USA).7z".source =
      "/media/games/Legend of Zelda, The - Ocarina of Time (USA).7z";

    "Games/ROMs/n64/Mario Kart 64 (USA).7z".source =
      "/media/games/Mario Kart 64 (USA).7z";

    "Games/ROMs/n64/Mario Tennis (USA).7z".source =
      "/media/games/Mario Tennis (USA).7z";

    "Games/ROMs/n64/Pokemon Stadium (USA).7z".source =
      "/media/games/Pokemon Stadium (USA).7z";

    "Games/ROMs/n64/Pokemon Stadium 2 (USA).7z".source =
      "/media/games/Pokemon Stadium 2 (USA).7z";

    "Games/ROMs/n64/Star Fox 64 (USA).7z".source =
      "/media/games/Star Fox 64 (USA).7z";

    "Games/ROMs/n64/Star Wars - Rogue Squadron (USA).7z".source =
      "/media/games/Star Wars - Rogue Squadron (USA).7z";

    "Games/ROMs/n64/Star Wars - Shadows of the Empire (USA).7z".source =
      "/media/games/Star Wars - Shadows of the Empire (USA).7z";

    "Games/ROMs/n64/Super Mario 64 (USA).7z".source =
      "/media/games/Super Mario 64 (USA).7z";

    "Games/ROMs/n64/Super Smash Bros. (USA).n64".source =
      "/media/games/Super Smash Bros. (USA).n64";

    # GameCube
    "Games/ROMs/gc/Legend of Zelda, The - The Wind Waker (USA).rvz".source =
      "/media/games/Legend of Zelda, The - The Wind Waker (USA).rvz";

    "Games/ROMs/gc/Legend of Zelda, The - Twilight Princess (USA).rvz".source =
      "/media/games/Legend of Zelda, The - Twilight Princess (USA).rvz";

    "Games/ROMs/gc/Mario Golf - Toadstool Tour (USA).rvz".source =
      "/media/games/Mario Golf - Toadstool Tour (USA).rvz";

    "Games/ROMs/gc/Mario Kart - Double Dash!! (USA).rvz".source =
      "/media/games/Mario Kart - Double Dash!! (USA).rvz";

    "Games/ROMs/gc/Metroid Prime 2 - Echoes (USA).rvz".source =
      "/media/games/Metroid Prime 2 - Echoes (USA).rvz";

    "Games/ROMs/gc/Super Smash Bros. Melee (USA) (En,Ja) (Rev 2).rvz".source =
      "/media/games/Super Smash Bros. Melee (USA) (En,Ja) (Rev 2).rvz";

    # SNES (assuming these are SNES versions)
    "Games/ROMs/snes/Castlevania (USA).7z".source =
      "/media/games/Castlevania (USA).7z";

    "Games/ROMs/snes/SimCity (USA).7z".source =
      "/media/games/SimCity (USA).7z";

    "Games/ROMs/snes/SimCity 2000 - The Ultimate City Simulator (USA).7z".source =
      "/media/games/SimCity 2000 - The Ultimate City Simulator (USA).7z";

    "Games/ROMs/snes/Super Mario RPG - Legend of the Seven Stars (USA).7z".source =
      "/media/games/Super Mario RPG - Legend of the Seven Stars (USA).7z";

    "Games/ROMs/snes/Prince of Persia (USA).7z".source =
      "/media/games/Prince of Persia (USA).7z";

    "Games/ROMs/snes/Prince of Persia 2 (USA).7z".source =
      "/media/games/Prince of Persia 2 (USA).7z";

    "Games/ROMs/snes/Super Castlevania IV (USA).sfc".source =
      "/media/games/Super Castlevania IV (USA).sfc";

    "Games/ROMs/snes/Super Mario World (USA).sfc".source =
      "/media/games/Super Mario World (USA).sfc";

    "Games/ROMs/snes/Super Mario World 2 - Yoshi's Island (USA).sfc".source =
      "/media/games/Super Mario World 2 - Yoshi's Island (USA).sfc";

    "Games/ROMs/snes/Super Metroid (Japan, USA) (En,Ja).sfc".source =
      "/media/games/Super Metroid (Japan, USA) (En,Ja).sfc";
  };
*/
}
