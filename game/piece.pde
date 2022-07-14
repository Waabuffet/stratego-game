class Piece{
   PVector coords;
   String name;
   int rank;
   Player player;
   PImage img;

   Piece(PVector coords, Player player, String name, int rank){
      this.coords = coords;
      this.player = player;
      this.name = name;
      this.rank = rank;
      this.img = loadImage("img/" + this.name + ".png");
   }

   Piece(PVector coords, Player player, String name, int rank, boolean debugging){
      this.coords = coords;
      this.player = player;
      this.name = name;
      this.rank = rank;
      println("coords: " + this.coords.x + "-" + this.coords.y + " | " + coords.x + "-" + coords.y + " | name: " + this.name + " | " + name);
      this.img = loadImage("img/" + this.name + ".png");
   }

   Piece(PVector coords, Player player){ // for other player
      this.coords = coords;
      this.player = player;
      this.img = loadImage("img/piece.png");
   }
   
   AttackState opponentWinsOver(int otherPieceRank){
      if(otherPieceRank == 10 && this.rank == 1){ // spy wins over marshal
         return AttackState.LOSE;
      }
      if(this.rank == 0 && otherPieceRank != 3){ //bomb wins over everything except miner (we are using peice.rank == 0 not this.rank == 0 since bomb can't attack)
         return AttackState.LOSE;
      }
      if(otherPieceRank == this.rank){
         return AttackState.DRAW;
      }
      return (otherPieceRank > this.rank)? AttackState.WIN : AttackState.LOSE;
   }

   void show(int square_width){

      int offset = square_width * 10/100;

      fill((this.player.playerColor == 'r')? 255 : 0, 0, (this.player.playerColor == 'b')? 255 : 0, 100);
      rect((this.coords.x * square_width) + offset, this.coords.y * square_width, square_width - (offset * 2), square_width);
      imageMode(CENTER);
      if(this.img == null){
         println("piece image null at " + this.coords.x + " - " + this.coords.y + " | name: " + this.name + " | player: " + this.player.playerColor);
      }
      this.img.resize(square_width - (offset * 2), square_width);
      image(this.img, (this.coords.x * square_width) + (square_width / 2), (this.coords.y * square_width) + (square_width / 2));
   }
}