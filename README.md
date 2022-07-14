# Stratego Game
This is the Stratego board gaming coded in JAVA Processing.

# Requirements
- JAVA
- Processing

# Setup
To start the game, you need to first start the socket server then the game twice (once for each player).
It is better to have multiple computers to have the best game experience since no player should know the other player's pieces.

Make sure to change the `serverHost` variable value on the computer that does not have the server running on. (should point to the IP of the machine that has the server).

# Startup
Start the server by going to the `server` directory and execute:
```
<PROCESSING_DIR>/processing-java --sketch=$PWD --run
```

Do the same for the game, go to the `game` directory and execute the same command above.

You can always start the Processing IDE and open both projects from it and run using the `play` button.

# Gameplay
Each player starts by placing his pieces on his side of the board the way he desires.
Once both players have finished placing all their pieces, the game starts.
The player who's flag is captured or has no more moves to make loses.

# Game Rules
Each piece has a rank. In general, the piece with the higher rank wins over the other piece.
There are some exceptions:
- the Spy (rank 1) wins over the marshal (rank 10)
- the Bomb (rank 0) wins over every pieces except for the Miner (rank 3)

The Bomb (rank 0) and Flag (rank -1) cannot move.

Every other piece can move one tile in any direction (except diagonally).

The Scout (rank 2) can move an unlimited number of tiles as long as there is nothing blocking their way.

# Some cool rules that can be implemented

## Aggressor Advantage
When pieces of the same rank battle, the attacking piece wins.

## Silent Defense
When an attack is made the attacker is the only player who has to declare the rank of his/her piece.

The defender does not reveal the rank of his/her piece, but resolves the attack by removing whatever piece is lower-ranking from the gameboard.

Players keep their own captured pieces. Exception: when a Scout attacks, the defender must reveal the rank of his/her piece.

## Rescue
When you move onto a square in your opponent's back row you have the option of rescuing one of your captured pieces. Immediately pick any piece from the pieces your opponent has captured and return it to the gameboard.

Place your rescued piece on any unoccupied space on your half of the gameboard and your turn is over.

### Restrictions:

- Scouts cannot make a rescue.
- You cannot rescue a Bomb.
- Only two rescues can be made by each player.
- The same playing piece cannot make both rescues.

# Strategy Hints
- Place Bombs around the Flag to protect it. But place a Bomb or two elsewhere to confuse your opponent.
- Put a few high-ranking pieces in the front line, but be careful! If you lose them early in the game you're in a weak position.
- Scouts should be in the front lines to help you discover the strength of opposing pieces.
- Place some Miners in the rear for the end of the game, where they will be needed to defuse Bombs.