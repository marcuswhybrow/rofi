{
  description = "Rofi (dialogues) configured and themed by Marcus";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs: let 
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    theme = pkgs.writeText "theme.rasi" ''
      * {
        font: "FiraCode-Nerd-Font 12";
        spacing: 0px;
        margin: 0px;
        padding: 0px;
        screen-margin: 310px 400px;
      }

      window {
        fullscreen: true;
        transparency: "real";
        background-color: rgba(0,0,0,0.2);
        location: center;
        anchor: center;
        margin: 0; 
        spacing: 20px;
        children: [ mainbox ];
        border-radius: 3px;
      }

      mainbox {
        width: 100px;
        margin: @screen-margin;
        orientation: vertical;
        children: [ entry, listview ];
        background-color: rgba(255,255,255,0.98);
        padding: 32px 32px;
        spacing: 10px;
        border-radius: 3px;
      }

      prompt {
        text-color: #000000;
        spacing: 0px;
      }

      entry {
        placeholder: "Filter...";
        placeholder-color: #888888;
        background-color: transparent;
        expand: false;
        width: 10em;
      }

      listview {
        layout: vertical;
        spacing: 10px;
        background-color: transparent;
      }

      element {
        text-color: #888888;
        background-color: transparent;
        spacing: 10px;
        padding: 0;
      }

      element-icon {
        size: 1em;
        background-color: transparent;
      }

      element-text {
        text-color: inherit;
        background-color: transparent;
      }

      element normal urgent {
        text-color: #ff0000;
      }

      element normal active {
        text-color: #0000ff;
      }

      element selected {
        text-color: #000000;
      }

      element selected normal {}
      element selected urgent {}
      element selected active {}
    '';

    config = pkgs.writeText "config.rasi" ''
      configuration {
        location: 0;
        xoffset: 0;
        yoffset: 0;
      }

      @theme "${theme}"
    '';
    wrapper = pkgs.runCommand "rofi-wrapper" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir --parents $out/bin
      makeWrapper ${pkgs.rofi-wayland}/bin/rofi $out/bin/rofi \
        --add-flags "-config ${config}"
    '';
  in {
    packages.x86_64-linux.rofi = pkgs.symlinkJoin {
      name = "rofi";
      paths = [ wrapper pkgs.rofi-wayland ]; # first ./bin/rofi takes precedence
    };

    packages.x86_64-linux.drun = pkgs.writeShellScriptBin "drun" ''
      ${inputs.self.packages.x86_64-linux.rofi}/bin/rofi -show drun -i -drun-display-format {name} -theme-str 'entry { placeholder: "Launch"; }'
    '';

    packages.x86_64-linux.default = inputs.self.packages.x86_64-linux.rofi;

  };
}
