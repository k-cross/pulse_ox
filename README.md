# Pulse Oximeter Platform

## Goals and Project Explanation

The main goal is to provide a way to store, analyze, and visualize the data off of medical grade pulse oximeter devices.
The only one that this application actually supports is the Masimo RAD8 because that's the one that my son uses.
Insurance companies and RAD8 don't provide the software required to monitor and perform analysis out of the box and costs money.
Their software also only supports windows.
The RAD8 medical device itself only provides storage for 72 hours worth of historical data.

This application will:
* store pulse ox data
* live monitor
* have a web interface

I would like for it to:
* retrieve data (csv format which is good to share with doctors/pulmonary experts)
* visualize data
  * live
  * historical
* query or analyze data
* be extensible for others to add more devices
* have options for multiple datastores including purely on disk so people do not need to understand how to setup a database.

I am on a clock and can't promise the features will ever be developed on the second list.

## How to run

The application has been tested on both MacOS and Linux.
I am pretty sure it will also run on Windows but make no promises about handling the serial devices properly.

Note: unfortunately the db setup scripts are broken but they contain the steps to perform manually

### Hardware

1. make sure RAD8 is unlocked
1. set the device's serial output to ASCII 1

### Software

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Resources

For more information about developing this application further, go to [phoenix](https://phoenixframework.org)'s website.

For more information about setting up the RAD8, refer to its manual.
I believe page 42 explained how to unlock it and navigate the menu, understanding what all the symbol shorthand represents to properly change settings.
