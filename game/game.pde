import websockets.*;
WebsocketClient wsc;

boolean testing = true,
        debugging = true;

String serverProtocol = "ws",
        serverHost = "localhost",
        serverPort = "8025";
int scene_height = 2000,
    scene_width = scene_height + 700,
    square_count = 10,
    square_width = scene_height / square_count;

Board board;
String messageToShow = "Waiting for other player";
PImage bg;

// preparing stage
int selectedPieceIndex = -1,
    prep_width_start = scene_height + 50,
    prep_height_start = 200,
    prep_row_height = 80,
    prep_col_width = (scene_width - prep_width_start) / 3,
    prep_text_size = 45;
ArrayList<String> piecesToPlace;
String[] ptp = {
    "Marshal-10-1", 
    "General-9-1",
    "Colonel-8-2",
    "Major-7-3",
    "Captain-6-4",
    "Lieutenant-5-4",
    "Sergeant-4-4",
    "Miner-3-5",
    "Scout-2-8",
    "Spy-1-1",
    "Bomb-0-6",
    "Flag-F-1"
};

//battle stage
Piece[] battlePiecesToShow;
int battlePieceHeight = 200,
    battleWidthSecondStartY;
float battleWidthStartX = prep_width_start / battlePieceHeight,
    battleWidthStartY = 300 / battlePieceHeight;

void settings(){
    size(scene_width, scene_height);
}

void setup(){
    wsc = new WebsocketClient(this, serverProtocol + "://" + serverHost + ":" + serverPort + "/");
    piecesToPlace = new ArrayList<String>();
    for(int i = 0; i < ptp.length; i++){
        piecesToPlace.add(ptp[i]); // convert them to arraylist
    }
    battlePiecesToShow = new Piece[2];
    bg = loadImage("img/bg.jpg");
    bg.resize(square_width * square_count, square_width * square_count);
    board = new Board(square_count, debugging);
    wsc.sendMessage("init");
}

void draw(){
    background(255);
    imageMode(CORNER);
    image(bg, 0, 0);
    board.show(square_width);
    if(board.state == State.PREPARING && !testing){
        showPreparing();
    }
    showMessage();

    // if(battlePiecesToShow[0] != null && battlePiecesToShow[1] != null){
    //     battlePiecesToShow[0].show(battlePieceHeight);
    //     battlePiecesToShow[1].show(battlePieceHeight);
    // }
}

void showMessage(){
    fill(0);
    textSize(prep_text_size);
    textAlign(CORNER);
    text(messageToShow, prep_width_start, prep_row_height);
}

void randomPieces(){
    println("placing random pieces");
    for(int i = 0; i < square_count; i++){
        for(int j = 6; j < square_count; j++){
            placePiece(0, i, j);
        }
    }
}

void showPreparing(){
    stroke(0);
    fill(255);
    rect(prep_width_start, prep_height_start, prep_col_width, prep_row_height);
    fill(0);
    stroke(2);
    textSize(prep_text_size);
    textAlign(CENTER);
    text("Piece", prep_width_start + (prep_col_width / 2), (prep_row_height / 2) + prep_height_start);

    stroke(0);
    fill(255);
    rect(prep_width_start + prep_col_width, prep_height_start, prep_col_width, prep_row_height);
    fill(0);
    stroke(2);
    textSize(prep_text_size);
    textAlign(CENTER);
    text("Rank", prep_width_start + prep_col_width + (prep_col_width / 2), (prep_row_height / 2) + prep_height_start);

    stroke(0);
    fill(255);
    rect(prep_width_start + (prep_col_width * 2), prep_height_start, prep_col_width, prep_row_height);
    fill(0);
    stroke(2);
    textSize(prep_text_size);
    textAlign(CENTER);
    text("Rest", prep_width_start + (prep_col_width * 2) + (prep_col_width / 2), (prep_row_height / 2) + prep_height_start);

    stroke(0);
    for(int i = 0; i < piecesToPlace.size(); i++){
        String[] pieceDetails = piecesToPlace.get(i).split("-");
        String name = pieceDetails[0];
        String rank = pieceDetails[1];
        String count = pieceDetails[2];

        if(selectedPieceIndex == i){ //show selected piece
            fill(255,255,0); // yellow
        }else{
            fill(255);
        }
        rect(prep_width_start, ((prep_row_height * i) + prep_row_height + prep_height_start), prep_col_width, prep_row_height);
        fill(0);
        textSize(prep_text_size);
        textAlign(CENTER);
        text(name, prep_width_start + (prep_col_width / 2), ((prep_row_height * i) + prep_row_height + (prep_row_height / 2) + prep_height_start));

        if(selectedPieceIndex == i){ //show selected piece
            fill(255,255,0); // yellow
        }else{
            fill(255);
        }
        rect(prep_width_start + prep_col_width, ((prep_row_height * i) + prep_row_height + prep_height_start), prep_col_width, prep_row_height);
        fill(0);
        textSize(prep_text_size);
        textAlign(CENTER);
        text(rank, prep_width_start + prep_col_width + (prep_col_width / 2), ((prep_row_height * i) + prep_row_height + (prep_row_height / 2) + prep_height_start));

        if(selectedPieceIndex == i){ //show selected piece
            fill(255,255,0); // yellow
        }else{
            fill(255);
        }
        rect(prep_width_start + (prep_col_width * 2), ((prep_row_height * i) + prep_row_height + prep_height_start), prep_col_width, prep_row_height);
        fill(0);
        textSize(prep_text_size);
        textAlign(CENTER);
        text(count, prep_width_start + (prep_col_width * 2) + (prep_col_width / 2), ((prep_row_height * i) + prep_row_height + (prep_row_height / 2) + prep_height_start));
    }
}

void placePiece(int index, int x, int y){
    String[] pieceDetails = piecesToPlace.get(index).split("-");
    println(piecesToPlace.get(index), pieceDetails[1]);
    int rank = (pieceDetails[1].charAt(0) == 'F')? -1 : Integer.valueOf(pieceDetails[1]);

    if(board.addPiece(new PVector(x, y), pieceDetails[0], rank)){
        wsc.sendMessage("placedPiece-" + board.me.playerColor + "-" + x + "-" + y);

        // deduct remaining
        int remainingCount = Integer.valueOf(pieceDetails[2]) - 1;
        if(remainingCount > 0){
            piecesToPlace.set(index, pieceDetails[0] + "-" + pieceDetails[1] + "-" + remainingCount);
        }else{
            piecesToPlace.remove(index);
        }

        if(piecesToPlace.size() == 0){
            board.waitForOtherPlayer();
            println("all pieces placed");
            wsc.sendMessage("playerReady");
        }
    }
}


void webSocketEvent(String msg){
    println(msg);
    String[] msgDetails = msg.split("-");
    char colorReceived;

    switch(msgDetails[0]){
        case "initReturn":
            colorReceived = msgDetails[1].charAt(0);
            if(board.me == null){
                board.addMyself(colorReceived);
            }else if(board.otherPlayer == null){
                board.addPlayer(colorReceived);
                if(testing){
                    randomPieces();
                }
                messageToShow = "Select piece and place it on board";
            }
            break;
        case "placedPiece":
            colorReceived = msgDetails[1].charAt(0);
            if(colorReceived == board.otherPlayer.playerColor){ //ignore pieces placed by me
                board.addPieceOtherPlayer(Integer.valueOf(msgDetails[2]), Integer.valueOf(msgDetails[3]));
            }
            break;
        case "allPlayersReady":
            board.gameOn();
            messageToShow = "Game On";
            break;
        case "movedPiece":
            int fromX = Integer.valueOf(msgDetails[2]),
                fromY = Integer.valueOf(msgDetails[3]),
                toX = Integer.valueOf(msgDetails[4]),
                toY = Integer.valueOf(msgDetails[5]);
            board.movePiece(fromX, fromY, toX, toY, msgDetails[1].charAt(0));
            board.switchTurn();
            break;
        case "battle": //battle-color-name-x-y-rank-x-y
            String opponentPieceName = msgDetails[2];
            int opponentPieceX = Integer.valueOf(msgDetails[3]),
                opponentPieceY = Integer.valueOf(msgDetails[4]),
                opponentPieceRank = Integer.valueOf(msgDetails[5]),
                myPieceX = Integer.valueOf(msgDetails[6]),
                myPieceY = Integer.valueOf(msgDetails[7]);
            if(msgDetails[1].charAt(0) == board.otherPlayer.playerColor){
                messageToShow = "Enemy " + opponentPieceName + " (rank " + opponentPieceRank + ") attacking:\nfrom " + (square_count - 1 - opponentPieceX) + "-" + (square_count - 1 - opponentPieceY);
                messageToShow += " on " + (square_count - 1 - myPieceX) + "-" + (square_count - 1 - myPieceY);
                board.gettingAttacked(wsc, opponentPieceName, opponentPieceX, opponentPieceY, opponentPieceRank, myPieceX, myPieceY);
            }else{
                //* for some reason this is not working
                // // show pieces on the right, opponent up, me down
                // battlePiecesToShow[0] = new Piece(new PVector(battleWidthStartX, battleWidthStartY), board.otherPlayer, opponentPieceName, opponentPieceRank);
                // Piece myPiece = board.tiles[myPieceX][myPieceY].piece;
                // battlePiecesToShow[1] = new Piece(new PVector(battleWidthStartX,battleWidthSecondStartY), myPiece.player, myPiece.name, myPiece.rank);
                // // pieces here are new instances so we could put them on a different place on the right side of the board
            }
            break;
        case "battleResult"://battleResult-m-color-x-y-x-y or //battleResult-r-color-x-y
            char playerColor = msgDetails[2].charAt(0);
            int originX = Integer.valueOf(msgDetails[3]),
                originY = Integer.valueOf(msgDetails[4]),
                pieceRank = 0, defenderX, defenderY, destinationX, destinationY;
            String pieceName = "";

            switch(msgDetails[1].charAt(0)){  // attacker win state
                case 'w':
                    defenderX = Integer.valueOf(msgDetails[5]);
                    defenderY = Integer.valueOf(msgDetails[6]);
                    board.movePiece(originX, originY, defenderX, defenderY, playerColor);
                    pieceName = msgDetails[7];
                    pieceRank = Integer.valueOf(msgDetails[8]);
                    break;
                case 'l':
                    board.removePiece(originX, originY, playerColor);
                    pieceName = msgDetails[5];
                    pieceRank = Integer.valueOf(msgDetails[6]);
                    break;
                case 'd':
                    destinationX = Integer.valueOf(msgDetails[5]);
                    destinationY = Integer.valueOf(msgDetails[6]);
                    board.removePiece(originX, originY, playerColor);
                    board.removePiece(destinationX, destinationY, playerColor);
                    pieceName = msgDetails[7];
                    pieceRank = Integer.valueOf(msgDetails[8]);
                    break;
            }

            messageToShow = "Target piece was " + pieceName + " (rank " + pieceRank + ")";
            board.proceedPlaying();
            board.switchTurn();
            break;
        case "gameover": // when a player captures a flag
            String winnerColor = msgDetails[1];
            board.gameOver();
            messageToShow = "Game Over\nWinner is " + winnerColor;
            break;
            // another way a player could lose is when he has no more moves to make, nothing is checking this yet but he will no longer be able to play
    }
}

void mousePressed(){
    if(board.state != State.GAMEOVER){
        for(int i = 0; i < square_count; i++){
            for(int j = 0; j < square_count; j++){
                int xStart = i * square_width,
                    xEnd = (i * square_width) + square_width,
                    yStart = j * square_width,
                    yEnd = (j * square_width) + square_width;

                if(mouseX > xStart && mouseX < xEnd && mouseY > yStart && mouseY < yEnd){
                    if(board.state == State.PREPARING){
                        if(selectedPieceIndex >= 0){
                            placePiece(selectedPieceIndex, i, j);
                            selectedPieceIndex = -1;
                        }
                    }else if(board.state == State.PLAYING){
                        if(this.board.isMyTurn() || testing){ // if testing any player can move on any turn
                            board.clickedTile(i, j, wsc);
                        }else{
                            println("not your turn");
                        }
                    }
                }
            }
        }

        if(board.state == State.PREPARING){
            if(mouseX > prep_width_start){
                for(int i = 0; i < piecesToPlace.size(); i++){
                    //select piece to place
                    int startY = (i * prep_row_height) + prep_row_height + prep_height_start; // the first row is just labels
                    int endY = (i * prep_row_height) + (prep_row_height * 2) + prep_height_start;
                    if(mouseY > startY && mouseY < endY){
                        selectedPieceIndex = i;
                        break;
                    }
                }
            }
        }
    }
}