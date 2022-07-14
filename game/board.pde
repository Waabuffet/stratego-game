class Board{
    State state;
    Player me, otherPlayer, playerTurn;
    Tile[][] tiles;
    int square_count;
    Tile selectedTile;
    boolean debugging;

    Board(int square_count, boolean debugging){
        this.square_count = square_count;
        this.debugging = debugging;
        this.state = State.WAITING;
        this.tiles = new Tile[10][10];
        this.initTiles();
        this.addRiver();
    }

    void initTiles(){
        for(int i = 0; i < this.square_count; i++){
            for(int j = 0; j < this.square_count; j++){
                tiles[i][j] = new Tile(new PVector(i, j));
            }
        }
    }

    void addRiver(){
        for(int i = 4; i <= 5; i++){
            this.tiles[2][i].addRiver();
            this.tiles[3][i].addRiver();
            this.tiles[6][i].addRiver();
            this.tiles[7][i].addRiver();
        }
    }

    boolean addPiece(PVector coords, String name, int rank){
        if(coords.y < 6){
            return false;
        }
        return this.tiles[Math.round(coords.x)][Math.round(coords.y)].addPiece(new Piece(coords, this.me, name, rank));
    }

    void addPieceOtherPlayer(int x, int y){
        // we need to invert the coords before placing it
        int invertedX = (this.square_count - 1) - x; // -1 because index is between 0 and 9
        int invertedY = (this.square_count - 1) - y;
        this.tiles[invertedX][invertedY].addPiece(new Piece(new PVector(invertedX, invertedY), this.otherPlayer));
    }

    void gameOn(){
        this.state = State.PLAYING;
        if(this.me.playerColor == 'r'){
            this.playerTurn = this.me;
        }else{
            this.playerTurn = this.otherPlayer;
        }
    }

    void gameOver(){
        this.state = State.GAMEOVER;
    }

    void proceedPlaying(){
        this.state = State.PLAYING;
    }

    void waitForOtherPlayer(){
        this.state = State.WAITING;
    }

    void addMyself(char playerColor){
        println("added myself");
        this.me = new Player(playerColor);
    }

    void addPlayer(char playerColor){
        println("other player added");
        this.otherPlayer = new Player(playerColor);
        this.state = State.PREPARING;
    }

    void removePaths(){
        for(int i = 0; i < this.tiles.length; i++){
            for(int j = 0; j < this.tiles[i].length; j++){
                this.tiles[i][j].removePath();
            }
        }
    }

    boolean movePiece(int fromX, int fromY, int toX, int toY, char playerColor){
        Tile previousTile, newTile;
        if(playerColor == this.me.playerColor){
            previousTile = this.tiles[fromX][fromY];
            newTile = this.tiles[toX][toY];
        }else{ // invert coords
            previousTile = this.tiles[this.square_count - 1 - fromX][this.square_count - 1 - fromY];
            newTile = this.tiles[this.square_count - 1 - toX][this.square_count - 1 - toY];
        }
        boolean added = newTile.addPiece(previousTile.piece);
        if(added){
            if(debugging){println("piece moved and removed from old tile");}
            previousTile.removePiece();
        }
        return added;
    }

    void removePiece(int x, int y, char playerColor){
        if(playerColor == this.me.playerColor){
            this.tiles[x][y].removePiece();
        }else{
            this.tiles[this.square_count - 1 - x][this.square_count - 1 - y].removePiece();
        }
    }

    void tileMakePath(int x, int y){
        boolean canMoveThere = true;
        Tile targetTile = this.tiles[x][y];
        if(targetTile.hasPiece()){
            if(targetTile.piece.player == this.me){
                canMoveThere = false; // cant move where there are pieces for me
            }
        }
        if(canMoveThere){
            targetTile.makePath();
        }
    }

    void calculatePath(int x, int y){
        
        Tile tile = this.tiles[x][y];

        if(tile.piece.rank != 2){ // Scout can move unlimited tiles, all others can move only one
            if(debugging){println("piece not scount");}
            // UP (y - 1)
            if(y > 0){
                this.tileMakePath(x, y-1);
            }
            // DOWN (y + 1)
            if(y < (this.tiles.length - 1)){
                this.tileMakePath(x, y+1);
            }
            // LEFT (x - 1)
            if(x > 0){
                this.tileMakePath(x-1, y);
            }
            // RIGHT (x + 1)
            if(x < (this.tiles.length - 1)){
                this.tileMakePath(x+1, y);
            }
        }else{ // if river, tile will not make path
            if(debugging){println("piece is scount");}
            // UP
            if(y > 0){
                Tile nexTile;
                int newY = y-1;
                do{
                    nexTile = this.tiles[x][newY];
                    this.tileMakePath(x, newY);
                    newY -= 1;
                }while(newY >= 0 && !nexTile.hasPiece() && !nexTile.isRiver);
            }
            // DOWN
            if(y < (this.tiles.length - 1)){
                Tile nexTile;
                int newY = y+1;
                do{
                    nexTile = this.tiles[x][newY];
                    this.tileMakePath(x, newY);
                    newY += 1;
                }while(newY <= (this.tiles.length - 1) && !nexTile.hasPiece() && !nexTile.isRiver);
            }
            // LEFT
            if(x > 0){
                Tile nexTile;
                int newX = x-1;
                do{
                    nexTile = this.tiles[newX][y];
                    this.tileMakePath(newX, y);
                    newX -= 1;
                }while(newX >= 0 && !nexTile.hasPiece() && !nexTile.isRiver);
            }
            // RIGHT
            if(x < (this.tiles.length - 1)){
                Tile nexTile;
                int newX = x+1;
                do{
                    nexTile = this.tiles[newX][y];
                    this.tileMakePath(newX, y);
                    newX += 1;
                }while(newX <= (this.tiles.length - 1) && !nexTile.hasPiece() && !nexTile.isRiver);
            }
        }
        
        
    }

    boolean isMyTurn(){
        return this.playerTurn == this.me;
    }

    void switchTurn(){
        this.playerTurn = (this.playerTurn == this.me)? this.otherPlayer : this.me;
    }

    void clickedTile(int x, int y, WebsocketClient wsc){
        if(debugging){println("clicked tile " + x + " - " + y);}
        Tile tile = this.tiles[x][y];
        if(this.selectedTile != null && tile.isPath){// we have already calculated the tiles the piece can move to
            
            if(debugging){println("tile previously selected and path");}
            if(tile.hasPiece()){ // attack-name-x-y-rank-x-y
                this.waitForOtherPlayer();
                wsc.sendMessage("battle-" + this.selectedTile.piece.player.playerColor + "-" + this.selectedTile.piece.name + "-" + this.selectedTile.getX() + "-" + this.selectedTile.getY() + "-" + this.selectedTile.piece.rank + "-" + x + "-" + y);
            }else{ // move piece
                wsc.sendMessage("movedPiece-" + this.me.playerColor + "-" + this.selectedTile.getX() + "-" + this.selectedTile.getY() + "-" + x + "-" + y);
            }
            
            this.removePaths();
            this.selectedTile = null;
        }else{
            if(debugging){println("no tile selected previously");}
        
            this.removePaths();
            if(tile.hasPiece()){ // show path
                if(this.debugging){
                    println("tile has piece");
                    println("piece has rank " + tile.piece.rank);
                }
                
                if(tile.piece.rank > 0){ // bomb (0) and flag (-1) cannot move
                    if(this.debugging){println("tile rank higher than 0");}
                    this.selectedTile = tile;
                    this.calculatePath(x, y);
                }
            }
        }
    }

    void gettingAttacked(WebsocketClient wsc, String pieceName, int pieceX, int pieceY, int pieceRank, int targetX, int targetY){
        // we need to invert the coords since they are the opponent's perspective
        Tile tile = this.tiles[this.square_count - 1 - targetX][this.square_count - 1 - targetY];
        Tile tileOpponent = this.tiles[this.square_count - 1 - pieceX][this.square_count - 1 - pieceY];
        AttackState opponentAttackState = tile.piece.opponentWinsOver(pieceRank);
        String otherPieceName = tile.piece.name;
        int otherPieceRank = tile.piece.rank;
        switch(opponentAttackState){
            case WIN:
                if(tile.piece.rank == -1){
                    // game over, opponent wins the game
                    wsc.sendMessage("gameover-" + this.otherPlayer.getColorName());
                }
                wsc.sendMessage("battleResult-w-" + this.me.playerColor + "-" + tileOpponent.getX() + "-" + tileOpponent.getY() + "-" + tile.getX() + "-" + tile.getY() + "-" + otherPieceName + "-" + otherPieceRank);
                break;
            case DRAW:
                wsc.sendMessage("battleResult-d-" + this.me.playerColor + "-" + tileOpponent.getX() + "-" + tileOpponent.getY() + "-" + tile.getX() + "-" + tile.getY() + "-" + otherPieceName + "-" + otherPieceRank);
                break;
            case LOSE:
                if(tileOpponent.piece.rank == -1){
                    // game over, we win the game
                    wsc.sendMessage("gameover-" + this.me.getColorName());
                }
                wsc.sendMessage("battleResult-l-" + this.me.playerColor + "-" + tileOpponent.getX() + "-" + tileOpponent.getY() + "-" + otherPieceName + "-" + otherPieceRank);
                break;
        }
    }

    void show(int square_width){
        for(int i = 0; i < this.square_count; i++){
            for(int j = 0; j < this.square_count; j++){
                this.tiles[i][j].show(square_width);
            }
        }
    }
}