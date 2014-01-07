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
params = Apibanca::Bank::BankCreationParams.new(name: "BICE", user: "...", pass: "...", account: "...")
# => #<Apibanca::Bank::BankCreationParams account="..." name="BICE" pass="..." user="...">

banco = Apibanca::Bank.create(client, params)
# -> POST http://api-banca.herokuapp.com/api/2013-11-4/banks/ [{:bank=>{"name"=>"BICE", "user"=>"...", "pass"=>"...", "account"=>"..."}} params]
# => (Banco 3304) BICE / <usuario> / <cuenta>

banco.id
# => 3304
```

### Estatus del banco

Indica si los parámetros de acceso a la cuenta son correctos. Nota: asegúrate de que lo sean; de otra forma el banco puede bloquear el acceso a la cuenta.

```ruby
# banco = Apibanca::Bank.create(...)
banco.status # sólo se puede utilizar cuando cambie a 'ready'. Este cambio de estado toma 5 minutos aproximadamente.
# => idle

banco.refresh! # recarga el proxy desde el servidor
# -> GET http://api-banca.herokuapp.com/api/2013-11-4/banks/3304
# -> GET http://api-banca.herokuapp.com/api/2013-11-4/routines/23444
# => (Banco 3304) BICE / <usuario> / <cuenta>
banco.status
# => working

banco.refresh! # unos minutos más tarde...
# ...
banco.status
# => ready
```

### Rutinas

Permiten agendar una tarea periódica en un banco. Por ejemplo, leer la cartola.

```ruby
# Todos los bancos incluyen una rutina inicial que se ejecuta cuando el banco es creado.
banco.routines
# => [(Rutina 23444) Setup inicial

# Añadiremos una rutina para leer la cartola y crear depósitos
banco.add_routine Apibanca::Bank::RoutineCreationParams.new(nombre: "LectorDepósitos", target: "cartola", what_to_do: "acumular")
# => (Rutina 23449) LectorDepósitos acumular:cartola tasks=0

# Para que la rutina trabaje, hay que indicar la frecuencia
routine = bank.routines.last
# => (Rutina 23449) LectorDepósitos acumular:cartola tasks=0

routine.schedule Apibanca::Routine::ScheduleParams.new( unit: "minutes", interval: "60" )
# -> PATCH http://api-banca.herokuapp.com/api/2013-11-4/routines/23449/schedule [params]
# => (Rutina 23449) LectorDepósitos acumular:cartola tasks=3
```

### Descarga de depósitos

A medida que las rutinas de lectura de depósitos procesen la cartola y las transacciones, se puede invocar una función para descargar los depósitos leídos

```ruby
# arreglo con todos los depósitos
banco.load_deposits
# => [...]

banco.deposits.first
# => (Deposit 209070) 03/01/2014 / cheque / 79.695
```

### Otras funciones

#### Listado de bancos creados

Es posible cargar un arreglo con los bancos cargados en la cuenta

```ruby
banks = Apibanca::Bank.index(client)
# -> GET http://api-banca.herokuapp.com/api/2013-11-4/banks/ 
# => [(Banco 3304) BICE / <usuario> / <cuenta>, (Banco 3323) SCOTIA / <usuario> / <cuenta>]
banks.first.id
# => 3304
```