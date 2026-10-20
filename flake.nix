{
  description = "Dendritic NixOS config";

  inputs = {
    # Swap to "github:NixOS/nixpkgs/nixos-26.05" (and home-manager "release-26.05") for stable.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    zen-browser.url = "github:youwen5/zen-browser-flake/458cd16116c362a5e92d5db6bdc3599e4e8b1f4a";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v1.2.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Every .nix file under ./modules is a flake-parts module and is imported automatically.
  # Files or directories starting with "_" are skipped (used for hardware-configuration).
  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
