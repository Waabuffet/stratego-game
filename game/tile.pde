class Tile{
    PVector coords;
    boolean isPath = false;
    boolean isRiver = false;
    Piece piece;

    Tile(PVector coords){
        this.coords = coords;
    }

    void makePath(){
        if(!this.isRiver){
            println("making path on " + this.coords.x + " - " + this.coords.y);
            this.isPath = true;
        }
    }

    int getX(){
        return Math.round(this.coords.x);
    }
    int getY(){
        return Math.round(this.coords.y);
    }

    void removePath(){
        this.isPath = false;
    }

    void addRiver(){
        this.isRiver = true;
    }

    boolean addPiece(Piece piece){
        if(this.isRiver){
            return false;
        }
        this.piece = piece;
        this.piece.coords = this.coords;
        return true;
    }

    void removePiece(){
        this.piece = null;
    }

    boolean hasPiece(){
        return this.piece != null;
    }

    void show(int square_width){
        stroke(0);
    
        fill(255, 0.2);
        square(this.coords.x * square_width, this.coords.y * square_width, square_width);
        if(this.hasPiece()){
            this.piece.show(square_width);
        }// no else here since it can be both a piece and a path
        if(this.isPath){
            fill(0, 255, 0);
            circle((this.coords.x * square_width) + (square_width / 2), (this.coords.y * square_width) + (square_width / 2), square_width / 4);
        }
        
    }
}