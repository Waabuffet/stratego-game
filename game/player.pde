class Player{
    char playerColor;
    Player(char playerColor){
        this.playerColor = playerColor;
    }

    String getColorName(){
        return (this.playerColor == 'r')? "Red" : "Blue";
    }
}