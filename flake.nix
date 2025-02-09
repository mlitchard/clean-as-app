{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ps-tools.follows = "purs-nix/ps-tools";
    purs-nix.url = "github:purs-nix/purs-nix/ps-0.15";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, utils, ... }@inputs:
    utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ps-tools = inputs.ps-tools.legacyPackages.${system};
        purs-nix = inputs.purs-nix { inherit system; };

        ps = purs-nix.purs {
          dependencies = [
            "aff"
            "affjax"
            "affjax-web"
            "argonaut-core"
            "arrays"
            "bifunctors"
            "codec"
            "codec-argonaut"
            "datetime"
            "debug"
            "dom-indexed"
            "effect"
            "either"
            "enums"
            "foldable-traversable"
            "formatters"
            "halogen"
            "halogen-formless"
            "halogen-store"
            "http-methods"
            "lists"
            "maybe"
            "newtype"
            "now"
            "ordered-collections"
            "parallel"
            "precise-datetime"
            "prelude"
            "profunctor"
            "profunctor-lenses"
            "remotedata"
            "routing"
            "routing-duplex"
            "safe-coerce"
            "slug"
            "strings"
            "transformers"
            "tuples"
            "typelevel-prelude"
            "web-events"
            "web-html"
            "web-storage"
            "web-uievents"
          ];

          dir = ./.;
        };

        serve = pkgs.writeShellApplication {
          name = "serve-clean-as-app";
          runtimeInputs = [ pkgs.simple-http-server ];
          text =
            "simple-http-server --ip 0.0.0.0 -p 8080 --nocache -i -- dist";
        };
      in 
      rec 
      { 
        packages =
             with ps;
             { default = app { name = "hello"; };
               bundle = bundle {};
               output = output {};
             };
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            entr
            nodejs
            nodePackages.purs-tidy
            (ps.command {bundle.esbuild.format = "iife";})
            ps-tools.for-0_15.purescript-language-server
            purs-nix.esbuild
            purs-nix.purescript
            simple-http-server
          ];

          shellHook = ''
            alias watch="find src | entr -s 'echo bundling; purs-nix bundle'"
          '';
        };

        formatter = pkgs.nixfmt;
      });
}
