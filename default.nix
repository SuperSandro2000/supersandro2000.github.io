with import <nixpkgs> { };
let
  jekyll_env = bundlerEnv rec {
    name = "jekyll";
    # ruby = ruby_2;
    gemdir = ./.;
    # gemfile = ./Gemfile;
    # lockfile = ./Gemfile.lock;
    # gemset = ./gemset.nix;
    gemConfig = pkgs.defaultGemConfig // {
      github-pages = attrs: {
        postInstall = ''
          installPath=$(cat $out/nix-support/gem-meta/install-path)
          sed -i 's/^.*"plugins_dir" =>.*$/      "plugins_dir" => "_plugins",/gm' $installPath/lib/github-pages/configuration.rb
          sed -i 's/^.*"safe" =>.*$/      "safe" => false,/gm' $installPath/lib/github-pages/configuration.rb
        '';
      };
    };
  };
in
stdenv.mkDerivation {
  name = "supersandro.de";
  src = ./.;

  nativeBuildInputs = [ jekyll gnumake gnused ];
  buildInputs = [ jekyll gnumake gnused ];

  buildPhase = ''
    export JEKYLL_ENV=production
    export LC_ALL=C.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
    jekyll build --trace
  '';

  installPhase = ''
    mkdir -p "$out/web"
    cp -ra * "$out/web"
  '';
}
