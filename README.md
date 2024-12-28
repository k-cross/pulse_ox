# Pulse Oximeter Platform

## Goals and Project Explanation

The main goal is to provide a way to store, analyze, and visualize the data off of medical grade pulse oximeter devices.
The only one that this application actually supports is the Masimo RAD8 because that's the one that my son uses.
Insurance companies and RAD8 don't provide the software required to monitor and perform analysis out of the box and costs money.
Their software also only supports windows.
The RAD8 medical device itself only provides storage for 72 hours worth of historical data.

This application will:

- [x] store pulse ox data
- [x] live monitor
- [x] have a web interface

I would like for it to:

- [ ] retrieve data (csv format which is good to share with doctors/pulmonary experts)
- [x] visualize data
    * live
    * historical
- [ ] query or analyze data
- [ ] be extensible for others to add more devices
- [ ] have options for multiple datastores including purely on disk so people do not need to understand how to setup a database.

I am on a clock and can't promise the features will ever be developed on the second list.

## Demo

[![Demo](https://hexdocs.pm/phoenix/assets/logo.png)(https://github.com/k-cross/pulse_ox/raw/refs/heads/main/demo.mov)

## Requirements and Dependencies

Things that are expected to already be setup

* postgresql
* erlang >= 21.0
* elixir >= 1.10
* nodejs >= 10.0

_Note_: Binaries can be built which removes the need for erlang, elixir, and nodejs for a running environment but I don't personally plan on providing this.

## How to run

The application has been tested on both MacOS and Linux.
I am pretty sure it will also run on Windows but make no promises about handling the serial devices properly.

Note: unfortunately the db setup scripts are broken but they contain the steps to perform manually

### Hardware

1. make sure RAD8 is unlocked
1. set the device's serial output to ASCII 1
1. connect the serial cable to the server and the RAD8

### Software

* build it using `make`
* run it with `make run`
* visit [`localhost:4000`](http://localhost:4000) from your browser.

## Resources

For more information about developing this application further, go to [phoenix](https://phoenixframework.org)'s website.

For more information about setting up the RAD8, refer to its manual.
I believe page 42 explained how to unlock it and navigate the menu, understanding what all the symbol shorthand represents to properly change settings.

## Development

For development I created a fake pulse oximeter device so that it is much easier to build the web interface and test graphing and other db queries.
Running the application in `dev` mode automatically configures the fake device so that a real pulse oximeter is not required, it's a PITA to setup a real one over serial all the time!
