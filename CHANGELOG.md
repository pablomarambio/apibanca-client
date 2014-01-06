# Bitácora de cambios

## 0.0.3

### Eliminación de rutinas
Para eliminar una rutina se debe invocar el método `delete` en ella.

## 0.0.2

### Configuración del cliente
El cliente ya no guarda el secreto y la URI de manera estática. En vez de eso, (a) dichos parámetros son argumentos del constructor, y (b) el cliente debe ser pasado como argumento en los métodos estáticos de `Apibanca::Bank`.

```ruby
# a)
# Antes: Apibanca::Client.configure { |c| c.secret = "API_KEY..."}
client = Apibanca::Client.new("API_KEY...")

# b)
# Antes: bank = Apibanca::Bank.create(params)
bank = Apibanca::Bank.create(client, params)
```

### Búsqueda de bancos
La función `Bank.index` ahora recibe un hash de parámetros opcionales. Ese hash soporta `name` y `user`.

```ruby
banks = Apibanca::Bank.index(client, name: "BICE") # retorna todos los bancos con name == BICE
```