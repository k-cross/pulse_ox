pulse:
	cd pulse_ox_platform && mix deps.get && mix compile && mix ecto.migrate && cd assets && npm install

clean:
	cd pulse_ox_platform && rm -rf deps _build assets/node_modules
