# NetSuite

Elixir client for NetSuite's SuiteTalk SOAP API, with support for some built-in
REST endpoints as well.

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
