import websockets.*;

WebsocketServer ws;
int numberOfPlayersConnected = 0;
int numberOfPlayersReady;
int port = 8025;
String messageToShow = "Server is up\nWaiting for players to connect";

void setup(){
    size(800,800);
    ws= new WebsocketServer(this, port, "/");
}

void draw(){
    background(0);
    fill(255);
    textSize(50);
    textAlign(CENTER);
    text(messageToShow, width / 2, height / 2);
}

void webSocketServerEvent(String msg){
    println(msg);
    String[] msgDetails = msg.split("-");
    switch(msgDetails[0]){
        case "init":
            if(numberOfPlayersConnected == 0){
                numberOfPlayersConnected++;
                ws.sendMessage("initReturn-r");
            }else{
                numberOfPlayersConnected++;
                ws.sendMessage("initReturn-b");
                ws.sendMessage("initReturn-r");
            }
            break;
        case "playerReady":
            if(numberOfPlayersReady == 1){
                numberOfPlayersReady++;
                messageToShow = "Game On";
                ws.sendMessage("allPlayersReady");
            }else{
                numberOfPlayersReady++;
                messageToShow = "1 player ready";
            }
            break;
        case "pieceMove":

            break;
        default :
            messageToShow = msg;
            ws.sendMessage(msg);
    }
}