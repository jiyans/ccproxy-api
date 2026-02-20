{
  description = "ccproxy-api - local OAuth-based AI provider proxy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        py = pkgs.python3;
        pypkgs = py.pkgs;

        optional = name: builtins.hasAttr name pypkgs;
        opt = name: if optional name then [ pypkgs.${name} ] else [ ];
      in
      {
        packages.default = pypkgs.buildPythonPackage {
          pname = "ccproxy-api";
          version = "0.2.3";
          pyproject = true;
          src = ./.;

          nativeBuildInputs = with pypkgs; [
            hatchling
            hatch-vcs
          ];

          propagatedBuildInputs =
            with pypkgs; [
              aiofiles
              fastapi
              httpx
              pydantic
              pydantic-settings
              rich
              rich-toolkit
              structlog
              typer
              typing-extensions
              uvicorn
              packaging
              sortedcontainers
              pyjwt
              qrcode
              sqlalchemy
              sqlmodel
              prometheus-client
            ]
            ++ opt "duckdb-engine"
            ++ opt "duckdb"
            ++ opt "fastapi-mcp"
            ++ opt "textual"
            ++ opt "aioconsole"
            ++ opt "sse-starlette"
            ++ opt "claude-agent-sdk";

          doCheck = false;
          pythonImportsCheck = [ "ccproxy" ];

          # Hatch-vcs requires an explicit version when .git is not present in Nix builds.
          HATCH_VCS_VERSION = "0.2.3";
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/ccproxy";
        };
      });
}
