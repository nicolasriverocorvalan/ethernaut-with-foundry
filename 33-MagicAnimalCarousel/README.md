# Magic Animal Carousel

Welcome, dear Anon, to the Magic Carousel, where creatures spin and twirl in a boundless spell. In this magical, infinite digital wheel, they loop and whirl with enchanting zeal.

Add a creature to join the fun, but heed the rule, or the game’s undone. If an animal joins the ride, take care when you check again, that same animal must be there!

Can you break the magic rule of the carousel?

## Vulnerability

The MagicAnimalCarousel contract simulates a magical carousel where "animals" are stored in "crates" that form a circular, linked list. The core "magic rule" is that if an animal joins the ride, it must remain there upon subsequent checks, implying the integrity and predictable flow of the carousel must be maintained. The challenge is to "break the magic rule of the carousel."

### Contract's Data Storage

The contract stores each crate's information (animal name, the ID of the next crate in the sequence, and the owner's address) within a single uint256 variable in its carousel mapping. This is done through a technique called `bit packing`:

* Owner Address: Occupies bits 0 through 159.
* Next Crate ID: Occupies bits 160 through 175 (a uint16 value, representing a crate ID from 0 to 65535).
* Animal Name: Occupies bits 176 through 255.

### Inconsistent Bit Packing & Overflow

The vulnerability arises from a subtle inconsistency in how animal names are handled by two key functions: `setAnimalAndSpin()` and `changeAnimal()`.

`1. setAnimalAndSpin(string animal):`

* This function is used to add a new animal to the carousel.
* It processes the animal string and effectively stores its name (limited to 8 bytes/64 bits) into bits 176-239 of the crate's uint256 value.
* Crucially, it has a require check `(require(encodedAnimal <= uint256(type(uint80).max)))` that, in practice, restricts the animal name to 8 bytes to pass compilation/runtime checks in typical environments.

`2. changeAnimal(string animal, uint256 crateId):`

* This function allows the owner of a crate to change its animal name.
* It processes the animal string and stores its name (up to 12 bytes/96 bits) into bits 160-255 of the crate's uint256 value.
* `CRITICALLY`: This function does NOT have the strict require check `(encodedAnimal <= uint256(type(uint80).max))` found in `setAnimalAndSpin()`. This is the core oversight.
* It uses a `bitwise OR (|)` operation to update the animal name.

### The Overflow

When `changeAnimal()` is called with a 12-byte animal name:

* The `changeAnimal()` function shifts the entire 12-byte (96-bit) encoded animal name left by 160 bits (encodedAnimal << 160).
* This means the last 2 bytes (16 bits) of the 12-byte animal name land directly into bits 160-175.
* Bits 160-175 are precisely where the nextCrateId pointer is stored.
* Because `changeAnimal` uses an OR operation for the update, these overflowing 2 bytes from the animal name will overwrite (by ORing with) the existing nextCrateId value, corrupting it.

## Attack

The goal is to force the `nextCrateId` of a crate to point to 65535 (the maximum uint16 value, which is MAX_CAPACITY - 1). When the carousel next "spins" from this crate, (65535 + 1) % MAX_CAPACITY will result in 0, causing the carousel to jump back to crateId 0 unexpectedly. This breaks the expected sequential flow of the carousel.

1. Deploy `MagicAnimalCarouselAttack` and the attack will be executed.

```bash
forge script script/MagicAnimalCarouselAttack.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
```

```bash
== Logs ==
  Adding 'Firulais' to the carousel...
  Animal at crate 1 after setting Firulais: 
  0x466972756c6169730000000264dd9d94818a2ca2e95c31b084aef0cc92e86da2
  Current crate ID:  7
  
Manipulating nextCrateId of crate 7 with exploit string...
  Animal at crate 7 after manipulating:
  0x10000000000000000000ffff64dd9d94818a2ca2e95c31b084aef0cc92e86da2
  Current crate ID:  7
  
Adding 'Firulais' to the now-redirected crate (should be crate 0)...
  Animal at crate 1 after setting Firulais (initial):
  0x466972756c6169730000000264dd9d94818a2ca2e95c31b084aef0cc92e86da2
  Animal at crate 65535 (just before wrap-around) after manipulation:
  0x466972756c6169730000000164dd9d94818a2ca2e95c31b084aef0cc92e86da2
  Animal at crate 0 (after wrap-around) after setting Firulais:
  0x0000000000000000000000010000000000000000000000000000000000000000
  Current crate ID:  65535
  
Carousel loop successfully broken by redirecting to crate 0!
```
