{
  description = "Mac Mini hackathon setup — system-wide packages via Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages = {
        # System-wide packages for the hackathon environment.
        # Install with: nix profile install .#hackathon-packages
        hackathon-packages = pkgs.buildEnv {
          name = "hackathon-packages";
          paths = with pkgs; [
            # GUI applications (symlinked to /Applications by setup.sh)
            wezterm
            zed-editor

            # CLI tools (available on PATH from nix profile)
            imagemagick
            ffmpeg
            gh

            # mise is deliberately NOT included — it's installed standalone
            # (per-user, no nix overhead) so the son can manage runtimes
            # independently without learning nix.
          ];
          meta = {
            description = "System-wide packages for hackathon development";
            platforms = [ "aarch64-darwin" "x86_64-darwin" ];
          };
        };

        # Wrapper that symlinks .app bundles to /Applications
        # Run after nix profile install: nix run .#link-apps
        link-apps = pkgs.writeShellApplication {
          name = "link-apps";
          text = ''
            for app in WezTerm Zed; do
              src="$HOME/.nix-profile/Applications/$app.app"
              dst="/Applications/$app.app"
              if [ -d "$src" ] && [ ! -e "$dst" ]; then
                echo "  Linking $dst -> $src"
                ln -s "$src" "$dst"
              elif [ -d "$src" ]; then
                echo "  $dst already exists, skipping."
              else
                echo "  $app.app not found in nix profile - may need nix profile install first."
              fi
            done
          '';
        };
      };

      defaultPackage = self.packages.${system}.hackathon-packages;

      # Apps for convenience: nix run .#setup
      apps = {
        setup = flake-utils.lib.mkApp {
          drv = pkgs.writeShellApplication {
            name = "hackathon-setup";
            text = ''
              echo "━━━ Hackathon Setup ━━━"
              echo ""
              echo "Step 1: Installing system packages..."
              nix profile install ".#hackathon-packages" --impure
              echo ""
              echo "Step 2: Linking GUI apps to /Applications..."
              nix run ".#link-apps" --impure
              echo ""
              echo "Step 3: Run setup.sh for per-user configuration (mise, OMP, configs)."
              echo ""
              echo "  bash $(dirname $0)/setup.sh"
            '';
          };
        };
      };
    });
}
