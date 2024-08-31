# I used chatgpt to generate this template and then just
# modified to how I normally use these things.
{
  description = "My Haskell project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-compat }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      result = (builtins.fetchGit {
                     url = "git@github.com:jappeace/katip";
                     rev = "8d61d9d8973c9448be9c20fa7a4a92605b1e92f2";
                     ref = "dont-leak-context";
                  });
      hpkgs = pkgs.haskellPackages.override {
        overrides = hnew: hold: {
          katip-profiling = hnew.callCabal2nix "katip-profiling" ./. { };
          katip  = (hold.callCabal2nix "katip" "${result}/katip"  {});
        };
      };
    in
    {
      defaultPackage.x86_64-linux =  hpkgs.katip-profiling;
      inherit pkgs;
      devShell.x86_64-linux = hpkgs.shellFor {
        packages = ps : [ ps."katip-profiling" ];
        withHoogle = false;

        buildInputs = [
          hpkgs.haskell-language-server
          pkgs.ghcid
          pkgs.cabal-install
          hpkgs.eventlog2html
        ];
      };
    };
}
