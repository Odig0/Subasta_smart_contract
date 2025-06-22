
# AuctionBasic - Contrato Inteligente de Subasta

Implementa un sistema de subasta en Solidity versión `0.8.26` Licencia MIT

**Dirección en Sepolia:** `0x4e2c84ac7b384e299f9d719a08e36cbe8ba5ef97`
**Url del mismo** `https://sepolia.etherscan.io/address/0x4e2c84ac7b384e299f9d719a08e36cbe8ba5ef97#code `

##  Objetivo del Contrato
El objetivo de este contrato es permitir que los usuarios participen en una subasta descentralizada, donde:
- Los ofertantes compiten enviando ofertas en ETH.
- Cada nueva oferta debe superar en al menos un **5%** a la oferta más alta actual.
- La subasta tiene una **duración configurable** (establecida en el momento del despliegue).
- Se descuenta una **comisión del 2%** de la oferta ganadora.
- Los participantes que no ganen podrán **retirar sus fondos** una vez finalizada la subasta.

##  Funcionamiento General
### Constructor
```solidity
constructor(uint durationMinutes)
```
- Inicializa la subasta.
- Asigna al `owner` (propietario) como `msg.sender`.
- Calcula `auctionEndTime` sumando `durationMinutes` al tiempo actual.

### Variables Principales
- `owner`: dirección del creador del contrato y administrador de la subasta.
- `highestBidder`: dirección del postor con la oferta más alta.
- `highestBid`: valor de la oferta más alta (en wei).
- `auctionEndTime`: tiempo en que finaliza la subasta.
- `ended`: booleano que indica si la subasta ya terminó.
- `bids`: mapa de direcciones a montos ofertados.
- `bidders`: arreglo con las direcciones de quienes ofertaron.

### Constantes
- `COMMISSION_PERCENT`: porcentaje de comisión (2%).
- `MIN_INCREMENT_PERCENT`: incremento mínimo requerido (5%).

### Eventos
- `NewBid(address bidder, uint amount)`: emitido cuando se realiza una nueva oferta.
- `AuctionEnded(address winner, uint amount)`: emitido al finalizar la subasta.

### Modificadores
- `onlyOwner`: restringe funciones sólo al propietario del contrato.
- `auctionActive`: asegura que la subasta esté activa y no finalizada.

## 🔹 Funciones Principales
### bid()
```solidity
function bid() external payable auctionActive
```
- Permite a un usuario realizar una oferta.
- `msg.value` debe ser mayor que cero.
- La oferta debe superar la actual en al menos un 5%.
- Si la oferta se hace en los últimos 10 minutos, se extiende el tiempo 10 minutos más.

### endAuction()
```solidity
function endAuction() external onlyOwner
```
- Solo puede llamarse una vez superado el tiempo límite.
- Transfiere el 98% de la oferta ganadora al propietario.
- Emite el evento `AuctionEnded`.

### withdraw()
```solidity
function withdraw() external
```
- Permite a los participantes no ganadores recuperar su ETH.
- Sólo puede llamarse cuando la subasta haya finalizado.

### getBiddersAndBids()
```solidity
function getBiddersAndBids() external view returns (address[] memory, uint[] memory)
```
- Devuelve dos arrays: uno con las direcciones de los ofertantes y otro con sus respectivos montos.
- Útil para interfaces frontend o revisión administrativa.

## Flujo 
1. El propietario despliega el contrato con `durationMinutes = 1` (ideal para pruebas).
2. Los usuarios hacen ofertas mediante `bid()`.
3. Si una oferta entra en los últimos 10 minutos, el tiempo se extiende.
4. Tras finalizar el tiempo, el propietario llama a `endAuction()`.
5. Los usuarios que no ganaron pueden llamar a `withdraw()`.

