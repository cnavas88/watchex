# Watchexs

Watchexs is a package for recompile and reload files in real time 
of execution.

## Installation

Add to dependencies.

```elixir
def deps do
  [
    {:watchexs, git: "git@github.com:cnavas88/watchex.git"}
  ]
end
```

## Use watchex

if you want recompile and reload the test in real time, you can execute
the next command:

```elixir
mix test.watch
```

if you want recompile and reload the other files you must add the next lines
in your config file:

```elixir
config :watchexs, watch_dirs: ["lib/", "test/", "web/"]

config :watchexs, enabled: true
```

 The watch_dirs is a list with the folders that you want recompile and reload
 in real time.
 The Enabled is a boolean, this variable will be true if you want enabled the
 watchex function for you specific environment. if this variable is false
 the watchex functions will be disabled.

 if you execute iex -S mix, with the enabled watchex config variable true
 the watchex begins to recompile and reload.

## Coverage - 84.8