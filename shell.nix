{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    nodejs
    postgresql
    openssl
    prisma-engines
    prisma
    nixfmt
  ];

  shellHook = ''
  export PGDATA="$PWD/.tmp/mydb"
  
  function init() {
    if [ -e "$PGDATA" ];
      then return;
    else 
      mkdir -p "$PGDATA";
      initdb -D "$PGDATA";
    fi
  }
  

    # Prisma config for nix
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";
    export PRISMA_SCHEMA_ENGINE_BINARY="${pkgs.prisma-engines}/bin/schema-engine"
    export PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines}/bin/query-engine"
    export PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines}/lib/libquery_engine.node"
    export PRISMA_FMT_BINARY="${pkgs.prisma-engines}/bin/prisma-fmt"

    function startpg()
    {
    if [ "$(pgrep postgres)" ]; then
      echo "Postgres server already running";
    else
      pg_ctl                                                  \
      -D $PGDATA                                            \
      -l $PGDATA/postgres.log                               \
      -o "-c unix_socket_directories='$PGDATA'"             \
      -o "-c listen_addresses='*'"                          \
      -o "-c log_destination='stderr'"                      \
      -o "-c logging_collector=on"                          \
      -o "-c log_directory='log'"                           \
      -o "-c log_filename='postgresql-%Y-%m-%d_%H%M%S.log'" \
      -o "-c log_min_messages=info"                         \
      -o "-c log_min_error_statement=info"                  \
      -o "-c log_connections=on"                            \
      start
    fi
    }


    function cleanup()
    {
    if [ "$(pgrep postgres)" ]; then
      pg_ctl -D $PGDATA stop
    fi
    }
    
    # Initialize db if it doesnt already exist
    init;

    # Automatically start the postgres server
    startpg;

    trap cleanup EXIT;
  '';

  LOCALE_ARCHIVE =
    if pkgs.stdenv.isLinux then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";

}
