# NetSuite
[![Build
Status](https://travis-ci.org/davidlaprade/netsuite_elixir.svg?branch=master)](https://travis-ci.org/davidlaprade/netsuite_elixir)

Elixir client for NetSuite's SuiteTalk SOAP API, with support for some built-in
REST endpoints as well.

## Features

  Ever seen this error before?

  ```xml
    <soapenv:Body>
      <soapenv:Fault>
        <faultcode>soapenv:Server.userException</faultcode>
        <faultstring>Only one request may be made against a session at a time</faultstring>
        <detail>
          <platformFaults:exceededRequestLimitFault xmlns:platformFaults="urn:faults_2012_1.platform.webservices.netsuite.com">
            <platformFaults:code>WS_CONCUR_SESSION_DISALLWD</platformFaults:code>
            <platformFaults:message>Only one request may be made against a session at a time</platformFaults:message>
          </platformFaults:exceededRequestLimitFault>
          <ns1:hostname xmlns:ns1="http://xml.apache.org/axis/">sb-partners-java051.svale.netledger.com</ns1:hostname>
        </detail>
      </soapenv:Fault>
    </soapenv:Body>

  ```

  Out of the box, the SuiteTalk API does not allow concurrency.
  Given that it can take upwards of 2 seconds to fetch a single record (!),
  this is nothing short of depressing.

  `netsuite_elixir` aims to improve this. It allows you to store and draw from a
  pool of NetSuite credentials when making your requests. Simply set your
  configs [here](https://github.com/davidlaprade/netsuite_elixir/blob/master/config/config.exs#L3),
  and view the connection processes running them:

  ```elixir
    NetSuite.Connections.Pool.list
  ```

  Did someone say [OTP](https://en.wikipedia.org/wiki/Open_Telecom_Platform)?
  Yes. Yes, please.

  Process NetSuite calls asynchronously then fetch the responses at a later
  time:

  ```elixir
    {:ok, ticket} = NetSuite.call_async(fn(config) ->
      NetSuite.Rest.Roles.get(config)
    end)

    NetSuite.get(ticket)
    => {:pending, nil}

    # time passes ...

    NetSuite.get(ticket)
    => {:ok, {200, [%{"account" => %{"internalId" => "TSTDRV12314", ... }

  ```

  Or, process them the old-fashioned way, one at a time:

  ```elixir
    NetSuite.call(fn(config) ->
      NetSuite.Rest.Roles.get(config)
    end)
    => {:ok, {200, [%{"account" => %{"internalId" => "TSTDRV12314", ... }
  ```

## Installation

  1. Add netsuite_elixir to your list of dependencies in `mix.exs`:

        def deps do
          [{:netsuite_elixir, github: "davidlaprade/netsuite_elixir"}]
        end

  2. Ensure netsuite_elixir is started before your application:

        def application do
          [applications: [:netsuite_elixir]]
        end

  3. Run `mix deps.get`

  4. Compile: `mix compile`

## Usage

  Load the app into the elixir REPL:

  ```shell
    iex -S mix
  ```

  Once in the REPL, set your credentials:

  ```elixir

    NetSuite.Configuration.set %{
      email:       ...,  # String, required
      password:    ...,  # String, required
      account:     ...,  # String, optional
      wsdl:        ...,  # String, optional but has default
      api_version: ...,  # String, optional but has default "2012_1"
      production:  true  # Boolean, optional but defaults to true
    }

  ```

  Test that your credentials are working:

  ```elixir
    NetSuite.Rest.Roles.get
  ```
