var Cursor = Backbone.Model.extend({
  defaults: {
    screenPosition: [0, 0]
  },
  setScreenPosition: function(position) {
    this.set('screenPosition', position.slice(0));
  }
});

function shuffle(o){ //v1.0
  for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
  return o;
};

var GameState = Backbone.Model.extend({
  defaults: {
    state: "setup", // setup, playing, end
    turn: "player",  // player, cpu
    boards: [],
    waiting: true
  },

  initialize: function() {
    _.bindAll(this, 'waitingForPlayer', 'nextTurn');
    var shotSequence = [];
    for (var row = 0; row < NUMTILES; row++) {
      for (var col = 0; col < NUMTILES; col++) {
        shotSequence.push({row: row, col: col});
      }
    }
    shuffle(shotSequence);
    var shots = shotSequence.map(function(pos) { return new Shot({position: pos}); });
    this.set('cpuShots', new ShotSet(shots));
  },

  waitingForPlayer: function() {
    return this.get('waiting');
  },

  startGame: function() {
    if (this.get('state') == 'setup')
      this.set('state', 'playing');
    else
      alert("Not in setup mode, so can't start game");
  },

  endGame: function(winner) {
    if (this.get('state') == 'playing') {
      this.set('state', 'end');
      this.set('winner', winner);
    }
    else
      alert("Not playing, so can't end game");
  },

  nextTurn: function() {
    if (this.get('state') == 'playing') {
      this.set('turn', this.isPlayerTurn() ? "cpu" : "player");
      // At beginning of CPU turn, generate shot
      // At beginning of Player turn, waiting for player to fire
      this.set('waiting', this.isPlayerTurn());
    }
  },

  isCpuTurn: function() {
    return this.get('turn') == 'cpu';
  },

  isPlayerTurn: function() {
    return this.get('turn') == 'player';
  },

  getCpuShot: function() {
    return this.get('cpuShots').shift();
  },

  getTurnHTML: function() {
    var turnName = this.isPlayerTurn() ? "your" : "CPU";
    var boardName = this.isPlayerTurn() ? "CPU" : "your";

    return "<h3>"+turnName+" turn<h3><h3 style='color: #7CD3A2;'>"+boardName+" board <span class='glyphicon glyphicon-arrow-right'></span></h3>";
  },
});

var Shot = Backbone.Model.extend({
  defaults: {
    position: {row: 0, col: 0},
    isHit: false
  }
});
var ShotSet = Backbone.Collection.extend({model: Shot});

var Ship = Backbone.Model.extend({
  defaults: {
    length: 0,
    isDeployed: false,
    position: {row: 0, col: 0},
    screenPosition: [0, 0],
    startPosition: [0, 0],
    screenRotation: 0,
    isVertical: false,
    health: 0
  },

  initialize: function() {
    this.set("health", this.get("length"));
  },

  setScreenPosition: function(position) {
    this.set('screenPosition', position.slice(0));
  },

  setScreenRotation: function(rotation) {
    this.set('screenRotation', rotation);
  },

  setBoardPosition: function(position) {
    this.set('position', position);
  },

  resetShip: function() {
    this.set('screenPosition', this.get('startPosition').slice(0));
    this.set('screenRotation', 0);
    this.set('isVertical', false);
  },

  snapRotation: function() {
    var rotation = this.get('screenRotation');
    var diff1 = Math.abs( rotation - Math.PI/2 );
    var diff2 = Math.abs( rotation + Math.PI/2 );
    var isVertical = (diff1 < Math.PI/4 || diff2 < Math.PI/4);
    this.set('screenRotation', isVertical ? Math.PI/2 : 0);
    this.set('isVertical', isVertical);
  },

  getEndpoints: function() {
    var endpoint = {
      row: this.get('position').row,
      col: this.get('position').col
    };
    if (this.get('isVertical'))
      endpoint.row += this.get('length') - 1;
    else
      endpoint.col += this.get('length') - 1;
    return {start: this.get('position'), end: endpoint};
  },

  getScreenOrigin: function() {
    var origin = this.get('screenPosition').slice(0);
    if (this.get('isVertical')) {
      // Get vertical origin
      origin[0] += this.get('length') * TILESIZE/2;
      origin[1] -= this.get('length') * TILESIZE/2;
    }
    return origin;
  },

  overlaps: function(otherShip) {
    var a = this.getEndpoints();
    var b = otherShip.getEndpoints();

    return (a.start.row <= b.end.row
            && a.end.row >= b.start.row
            && a.start.col <= b.end.col
            && a.end.col >= b.start.col);
  }
});
var ShipSet = Backbone.Collection.extend({model: Ship});

var Board = Backbone.Model.extend({
  initialize: function() {
    this.set('shots', new ShotSet());

    var ships = new ShipSet();
    var shipLengths = {
      battleship: 3,
      //destroyer: 3,
      patrolBoat: 2
    };

    Object.keys(shipLengths).forEach(function(shipType, i) {
      var ship = new Ship({
        type: shipType,
        length: shipLengths[shipType],
        screenPosition: [0, (i+1)*100],
        startPosition: [0, (i+1)*100],
      });
      ships.add(ship);
    });
    this.set('ships', ships);

    if (this.get('autoDeploy'))
      this.autoDeploy();
  },

  deployShip: function(ship) {
    if (this.outOfBounds(ship))
      return false;

    var overlap = false;
    this.get('ships').forEach(function(otherShip) {
      if (ship.get('type') != otherShip.get('type') && ship.get('isDeployed'))
        overlap = otherShip.overlaps(ship);
    });

    // No overlaps and not out of bounds, so deploy
    if (! overlap)
      ship.set("isDeployed", true);

    return !overlap;
  },

  outOfBounds: function(ship) {
    var endpoints = ship.getEndpoints();
    var start = endpoints.start;
    var end = endpoints.end;
    return (start.row < 0 || start.row >= NUMTILES
      || start.col < 0 || start.col >= NUMTILES
      || end.row < 0 || end.row >= NUMTILES
      || end.col < 0 || end.col >= NUMTILES);
  },

  autoDeploy: function() {
    var self = this;
    var offset = this.get('name') == 'cpu' ? 1 : 0;
    this.get('ships').forEach(function(ship, i) {
      if (! ship.get('isDeployed')) {
        ship.set('position', {row: 2*i + offset, col: 0});
        ship.set('isDeployed', true);
      }
    });
  },

  resetBoard: function() {
    this.initialize();
  },

  fireShot: function(shot) {
    var position = shot.get('position');

    var shotStatus = true;
    // Check if already shot here
    this.get('shots').forEach(function(shot) {
      var otherPosition = shot.get('position');
      if (otherPosition.row == position.row && otherPosition.col == position.col)
        shotStatus = false;
    });
    if (! shotStatus)
      return false;

    // Otherwise, see if it's a hit
    var isGameOver = true;
    var sunkShip = null;
    this.get('ships').forEach(function(ship) {
      var endpoints = ship.getEndpoints();
      if (endpoints.start.row <= position.row
            && endpoints.end.row >= position.row
            && endpoints.start.col <= position.col
            && endpoints.end.col >= position.col) {

        ship.set('health', ship.get('health') - 1);
        if (ship.get('health') == 0)
          sunkShip = ship;

        shot.set('isHit', true);
      }

      if (ship.get('health') > 0)
      isGameOver = false;
    });

    var result = {shot: shot, isGameOver: isGameOver};
    if (sunkShip != null)
      result.sunkShip = sunkShip;

    this.get('shots').add(shot);

    return result;
  }
});

////////////////
//NEW 4.6
////////////////
var CPUPersonality = Backbone.Model.extend({
    defaults: {
        responseToPlayerAction: {
            START: ["welcome to battleship, also known as you're imminent doom. You go first"],
            OFF_BOARD: ["miss, can you see straight?",
                "do you need glasses?",
                "wow, it's amateur hour, keep it up",
            ],
            DUPLICATE: ["you already tried that, try something different for a change"],
            MISS: ["miss, what a pity",
                "miss, better luck next time",
                "miss, who am I playing against?",
                "should I leave?, miss",
                "good thing you are not an admiral",
                "so close yet so far",
                "thank you for your service"
            ],
            HIT: ["hit, don't get too excited",
                "hit, lucky shot",
                "hit, this is not good"
            ],
            SINK: ["Rats, you sunk my "],
            GAME_OVER: ['No, I am defeated. Game Over']
        },
        responseToCPUAction: {
            START: ["now it's my my turn"],
            OFF_BOARD: ["oops, my mistake",
                "I must be experiencing technical difficulties"
            ],
            DUPLICATE: ["just making sure you are paying attention"],
            MISS: ["I will get you on the next one",
                "you can't be hiding for long",
                "I can almost taste you",
                "where are you",
                "you can't be too far away",
                "this is harder than I thought",
                "not there"
            ],
            HIT: ["yes, got one",
                "are you getting scared?",
                "you are mine now"
            ],
            SINK: ["one down, one to go"],
            GAME_OVER: ["I win. Up for another?"]
        },
        responseToLying: [
            "try to be more honest next time.",
            "stop trying to trick me",
            "you are only cheating yourself",
            "what if I was lying, you better watch out",
            "I am disregarding your last statement"
        ],
        lyingCounter: 0,
        playerBoardCounter: 0,
        playerBoardState: "START",
        cpuBoardCounter: 0,
        cpuBoardState: "START",
        responseState: {
            START: "START",
            OFF_BOARD: "OFF_BOARD",
            DUPLICATE: "DUPLICATE",
            MISS: "MISS",
            HIT: "HIT",
            SINK: "SINK",
            GAME_OVER: "GAME_OVER"
        }
    },

    initialize: function() {
        this.set('lyingCounter', 0);
        this.set('playerBoardCounter', 0);
        this.set('playerBoardState', "START");
        this.set('cpuBoardCounter', 0);
        this.set('cpuBoardState', "START")
    },

    speechFromPlayerAction: function( addition ) {
        var responseList = this.get('responseToPlayerAction')[this.get('playerBoardState')];
        var maxIter = responseList.length;
        var index = Math.min( this.get('playerBoardCounter'), maxIter-1 );
        return generateSpeech(  this.get('responseToPlayerAction')[this.get('playerBoardState')][index] + ((addition) ? addition : "")
        );
    },

    speechFromCPUAction: function() {
        var responseList = this.get('responseToCPUAction')[this.get('cpuBoardState')];
        var maxIter = responseList.length;
        var index = Math.min( this.get('cpuBoardCounter'), maxIter-1 );
        return generateSpeech(this.get('responseToCPUAction')[this.get('cpuBoardState')][index]);
    },

    checkIfPlayerLying: function( response, actual ){
        var maxIter = this.get('responseToLying').length;
        var index = Math.min( this.get('lyingCounter'), maxIter-1 );
        if ((response != null) && (response != actual)){
            generateSpeech(this.get('responseToLying')[index]);
            this.set('lyingCounter', this.get('lyingCounter') + 1);
        }
        else{
            this.set('lyingCounter', 0);
        }
    },

    setResponse: function( response, reactionTo ) {

        if (reactionTo === 'player') {
            if (this.get('playerBoardState') == this.get('responseState')[response]) {
                this.set('playerBoardCounter', this.get('playerBoardCounter') + 1);
            }
            else {
                this.set('playerBoardState', this.get('responseState')[response]);
                this.set('playerBoardCounter', 0);
            }
        }
        else if( reactionTo === 'cpu'){
            if (this.get('cpuBoardState') == this.get('responseState')[response]) {
                this.set('cpuBoardCounter', this.get('cpuBoardCounter') + 1);
            }
            else {
                this.set('cpuBoardState', this.get('responseState')[response]);
                this.set('cpuBoardCounter', 0);
            }
        }
    }

});
