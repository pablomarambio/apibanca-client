# Cliente Ruby de API-Banca

`Apibanca::Client` es el cliente de Ruby para `API-Banca`, el wrapper REST sobre los sitios web de los bancos de Chile.

## API-Banca

API-Banca es un wrapper de servicios web REST que simplifica el acceso automatizado a los sitios web de los bancos chilenos. Soporta operaciones como la descarga de cartola y transferencias recibidas. Los bancos soportados por ahora son: `BICE` (banca personas) y `SCOTIA` (banca empresas). Obtén una llave para pruebas ingresando a http://api-banca.herokuapp.com

## Instalación

Agrega esta línea a tu Gemfile

    gem 'apibanca-client'

Y luego ejecuta:

    $ bundle

O bien instálala tú mismo:

    $ gem install apibanca-client

## Uso

### Instanciar el cliente

Para realizar cualquier operación desde la gema, hay que autentificarse con la API-Key obtenida en http://api-banca.herokuapp.com.

```ruby
# Obtenida desde http://api-banca.herokuapp.com
API_KEY = "b3e0f65c-dea6-4003-d9d0-9a8745d9988"
client = Apibanca::Client.new(API_KEY)
```

### Crear un banco

Los bancos pueden ser creados a través de la interfaz web o desde esta gema. Para crear un banco desde la gema, hay que proveer todos los parámetros solicitados por la clase `Apibanca::Bank::BankCreationParams`.

```ruby
params = Apibanca::Bank::BankCreationParams.new(name: "BICE", user: "<rut del usuario>", pass: "<password para la web del banco>", account: "<número de cuenta>"
# => #<Apibanca::Bank::BankCreationParams account="..." name="BICE" pass="..." user="...">
banco = Apibanca::Bank.create(client, params)
# -> POST http://api-banca.herokuapp.com/api/2013-11-4/banks/ [{:bank=>{"name"=>"BICE", "user"=>"...", "pass"=>"...", "account"=>"..."}} params]
# Banco BICE / 157768441 / unica
```