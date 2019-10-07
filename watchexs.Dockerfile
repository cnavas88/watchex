FROM elixir:1.8
MAINTAINER cnavas88

WORKDIR /watchexs

COPY . .

RUN mix local.hex --force

RUN mix local.rebar --force

RUN mix deps.get

RUN mix compile