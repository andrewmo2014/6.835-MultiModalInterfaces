// GAME SETUP
var initialState = SKIPSETUP ? "playing" : "setup";
var gameState = new GameState({state: initialState});
var cpuBoard = new Board({autoDeploy: true, name: "cpu"});
var playerBoard = new Board({autoDeploy: SKIPSETUP, name: "player"});
var cursor = new Cursor();

// UI SETUP
setupUserInterface();

// Constants
const CURSOR_Y_OFFSET = 200;
const CURSOR_X_OFFSET = -300;
const GRAB_THRESHOLD = .95;
const MIN_ROLL = -Math.PI/2;
const MAX_ROLL = 0;
const ROLL_INFLUENCE = 3;

// Customize CPU speech
var cpuPersonality = new CPUPersonality();

// selectedTile: The tile that the player is currently hovering above
var selectedTile = false;

// grabbedShip/Offset: The ship and offset if player is currently manipulating a ship
var grabbedShip = false;
var grabbedOffset = [0, 0];

// isGrabbing: Is the player's hand currently in a grabbing pose
var isGrabbing = false;

// MAIN GAME LOOP
// Called every time the Leap provides a new frame of data
Leap.loop({ hand: function(hand) {
  // Clear any highlighting at the beginning of the loop
  unhighlightTiles();

  // 4.1, Moving the cursor with Leap data
  // Use the hand data to control the cursor's screen position
  var cursorPosition = hand.screenPosition().slice(0,2);
  cursorPosition[0] = cursorPosition[0] + CURSOR_X_OFFSET;
  cursorPosition[1] = cursorPosition[1] + CURSOR_Y_OFFSET;
  cursor.setScreenPosition(cursorPosition);

  // 4.1
  // Get the tile that the player is currently selecting, and highlight it
  selectedTile = getIntersectingTile(cursorPosition);
  if (selectedTile) highlightTile(selectedTile, Colors.GREEN);

  // SETUP mode
  if (gameState.get('state') == 'setup') {
    background.setContent("<h1>battleship</h1><h3 style='color: #7CD3A2;'>deploy ships</h3>");
    // 4.2, Deploying ships
    //  Enable the player to grab, move, rotate, and drop ships to deploy them
      var checkGrabbingShip = getIntersectingShipAndOffset(cursorPosition);

      // First, determine if grabbing pose or not
    isGrabbing = (hand.grabStrength > GRAB_THRESHOLD);

      // Grabbing, but no selected ship yet. Look for one.
    // Update grabbedShip/grabbedOffset if the user is hovering over a ship
    if (!grabbedShip && isGrabbing) {
        grabbedShip = checkGrabbingShip["ship"];
        grabbedOffset = checkGrabbingShip["offset"];
    }

    // Has selected a ship and is still holding it
    // Move the ship
    else if (grabbedShip && isGrabbing) {
      grabbedShip.setScreenPosition([cursorPosition[0]-grabbedOffset[0], cursorPosition[1]-grabbedOffset[1]]);
      grabbedShip.setScreenRotation( clipRoll( hand.roll() * ROLL_INFLUENCE, MIN_ROLL, MAX_ROLL ) );
    }

    // Finished moving a ship. Release it, and try placing it.
    // Try placing the ship on the board and release the ship
    else if (grabbedShip && !isGrabbing) {
        placeShip(grabbedShip);
        grabbedShip = false;
        grabbedOffset = [0,0];
    }
  }

  // PLAYING or END GAME so draw the board and ships (if player's board)
  // Note: Don't have to touch this code
  else {
    if (gameState.get('state') == 'playing') {
      background.setContent("<h1>battleship</h1><h3 style='color: #7CD3A2;'>game on</h3>");
      turnFeedback.setContent(gameState.getTurnHTML());
    }
    else if (gameState.get('state') == 'end') {
      var endLabel = gameState.get('winner') == 'player' ? 'you won!' : 'game over';
      background.setContent("<h1>battleship</h1><h3 style='color: #7CD3A2;'>"+endLabel+"</h3>");
      turnFeedback.setContent("");
    }

    var board = gameState.get('turn') == 'player' ? cpuBoard : playerBoard;
    // Render past shots
    board.get('shots').forEach(function(shot) {
      var position = shot.get('position');
      var tileColor = shot.get('isHit') ? Colors.RED : Colors.YELLOW;
      highlightTile(position, tileColor);
    });

    // Render the ships
    playerBoard.get('ships').forEach(function(ship) {
      if (gameState.get('turn') == 'cpu') {
        var position = ship.get('position');
        var screenPosition = gridOrigin.slice(0);
        screenPosition[0] += position.col * TILESIZE;
        screenPosition[1] += position.row * TILESIZE;
        ship.setScreenPosition(screenPosition);
        if (ship.get('isVertical'))
          ship.setScreenRotation(Math.PI/2);
      } else {
        ship.setScreenPosition([-500, -500]);
      }
    });

    // If playing and CPU's turn, generate a shot
    if (gameState.get('state') == 'playing' && gameState.isCpuTurn() && !gameState.get('waiting')) {
      gameState.set('waiting', true);
      generateCpuShot();
    }
  }
}}).use('screenPosition', {scale: LEAPSCALE});

// processSpeech(transcript)
//  Is called anytime speech is recognized by the Web Speech API
// Input: 
//    transcript, a string of possibly multiple words that were recognized
// Output: 
//    processed, a boolean indicating whether the system reacted to the speech or not
var processSpeech = function(transcript) {
  // Helper function to detect if any commands appear in a string

  var userSaid = function(str, commands) {
    for (var i = 0; i < commands.length; i++) {
      if (str.indexOf(commands[i]) > -1)
        return true;
    }
    return false;
  };

  var processed = false;
  if (gameState.get('state') == 'setup') {
    // 4.3, Starting the game with speech
    // Detect the 'start' command, and start the game if it was said

    if (userSaid('start', transcript) ) {
      gameState.startGame();
        cpuPersonality.speechFromPlayerAction();

        processed = true;
    }
  }

  else if (gameState.get('state') == 'playing') {


    if (gameState.isPlayerTurn()) {
      // 4.4, Player's turn
      // Detect the 'fire' command, and register the shot if it was said
      if (userSaid('fire', transcript)) {
        registerPlayerShot();

        processed = true;
      }
    }

    else if (gameState.isCpuTurn() && gameState.waitingForPlayer()) {
      // 4.5, CPU's turn
      // Detect the player's response to the CPU's shot: hit, miss, you sunk my ..., game over
      // and register the CPU's shot if it was said
      var response = null;

      if (userSaid('hit', transcript)){             response = "HIT";}
      else if (userSaid('miss', transcript)){       response = "MISS";}
      else if (userSaid('sunk', transcript)){       response = "SINK";}
      else if (userSaid('game over', transcript)){  response = "GAME_OVER";}

      registerCpuShot(response);
      processed = true;
    }
  }

  return processed;
};

// DONETODO: 4.4, Player's turn
// Generate CPU speech feedback when player takes a shot
var registerPlayerShot = function() {
  // CPU should respond if the shot was off-board
  if (!selectedTile) {
      cpuPersonality.setResponse( "OFF_BOARD", "player" );
      cpuPersonality.speechFromPlayerAction();

  }

  // If aiming at a tile, register the player's shot
  else {
    var shot = new Shot({position: selectedTile});
    var result = cpuBoard.fireShot(shot);

    // Duplicate shot
    if (!result) {
        cpuPersonality.setResponse( "DUPLICATE", "player" );
        cpuPersonality.speechFromPlayerAction();

        return;
    }

    // Generate CPU feedback in three cases
    // Game over
    if (result.isGameOver) {
        gameState.endGame("player");
        cpuPersonality.setResponse( "GAME_OVER", "player" );
        cpuPersonality.speechFromPlayerAction();

        return;
    }
    // Sunk ship
    else if (result.sunkShip) {
        var shipName = result.sunkShip.get('type');
        cpuPersonality.setResponse( "SINK", "player" );
        cpuPersonality.speechFromPlayerAction( shipName );

    }
    // Hit or miss
    else {
        var isHit = result.shot.get('isHit');

        cpuPersonality.setResponse( isHit ? "HIT" : "MISS", "player" );
        cpuPersonality.speechFromPlayerAction();

    }

    if (!result.isGameOver) {
        nextTurn();
    }
  }
};

// 4.5, CPU's turn
// Generate CPU shot as speech and blinking
var cpuShot;
var generateCpuShot = function() {
  // Generate a random CPU shot
  cpuShot = gameState.getCpuShot();
  var tile = cpuShot.get('position');
  var rowName = ROWNAMES[tile.row]; // e.g. "A"
  var colName = COLNAMES[tile.col]; // e.g. "5"

  // Generate speech and visual cues for CPU shot
    generateSpeech("fire " + rowName + " " + colName);
    blinkTile(tile);
};

// 4.5, CPU's turn
// Generate CPU speech in response to the player's response
// E.g. CPU takes shot, then player responds with "hit" ==> CPU could then say "AWESOME!"
var registerCpuShot = function(playerResponse) {
  // Cancel any blinking
  unblinkTiles();
  var result = playerBoard.fireShot(cpuShot);

  // NOTE: Here we are using the actual result of the shot, rather than the player's response
  // In 4.6, you may experiment with the CPU's response when the player is not being truthful!

  // Game over
  if (result.isGameOver) {
      cpuPersonality.checkIfPlayerLying( playerResponse, "GAME_OVER");

      gameState.endGame("cpu");
      cpuPersonality.setResponse( "GAME_OVER", "cpu" );
      cpuPersonality.speechFromCPUAction( "GAME_OVER" );

      return;
  }
  // Sunk ship
  else if (result.sunkShip) {
      var shipName = result.sunkShip.get('type');
      cpuPersonality.checkIfPlayerLying( playerResponse, "SINK");

      cpuPersonality.setResponse( "SINK", "cpu" );
      cpuPersonality.speechFromCPUAction( "SINK" );

  }
  // Hit or miss
  else {
      var isHit = result.shot.get('isHit');
      cpuPersonality.checkIfPlayerLying( playerResponse, isHit ? "HIT" : "MISS");

      cpuPersonality.setResponse( isHit ? "HIT" : "MISS", "cpu" );
      cpuPersonality.speechFromCPUAction( isHit ? "HIT" : "MISS" );
  }

  if (!result.isGameOver) {
    nextTurn();
  }
};

