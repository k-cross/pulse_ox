pulse:
	cd pulse_ox_platform && MIX_ENV=prod mix do deps.get, compile, ecto.migrate && cd assets && npm install

run:
	cd pulse_ox_platform && MIX_ENV=prod mix phx.server

clean:
	cd pulse_ox_platform && rm -rf deps _build assets/node_modules
