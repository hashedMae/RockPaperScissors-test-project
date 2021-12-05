pragma solidity >=0.8.0, <0.9.0;

import "./2_rpsToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract 3_rockPaperScissors is IERC20 {

    

    constructor 3_rockPaperScissors() {

        struct Game{
        address player1Address;
        address player2Address;
        Move player1Move;
        Move player2Move;
        uint bet;
        uint timeStart;
        uint pot;
        Result gameResult;
        }

        Game[] public games;

        games.push(0,0,0,0,0,0,0)
    }

    IERC20 private iRPS = IERC20(_rpsToken);

    event newGame(address challenger, address challenged, uint betAmount);
    event player1Wins(address player1, Move player1Move, address player2, Move player2Move, uint potAmount);
    event player2Wins(address player2, Move player2Move, address player1, Move player2Move, uint potAmount);
    event noWinner(Move player1Move, uint betAmount);

    mapping(address => uint) internal _playerWinnings;
    mapping(address => uint) internal _playerMove;
    mapping(address => uint) internal _currentGameID;
    mapping(address => uint) internal _challengGameID;

    enum Move{
        NONE,
        ROCK,
        PAPER,
        SCISSORS
    }

    enum Result{
        NONE,
        DRAW,
        PLAYER1WINS,
        PLAYER2WINS
    }

    Move constant defaultMove = Move.NONE;

    uint internal _decimals = 10^18;

    function approveRPS(uint amount) public {
        iRPS.approve(msg.sender, amount);
    }

    function _checkAllowance(uint _bet) internal{
        require(iRPS.allowance(msg.sender, this) >= _bet * _decimals , "You must increase your RPS approval first.");
    }

    function _checkWinnings() internal{
        require(_playerWinnings[msg.sender >= _bet * _decimals, "You don't have enough tokens in your winnings."]);
    }

    function _addWinnings(address _playerAddress, uint _amount) internal {
        _playerWinnings[_playerAddress] += _amount;
    }

    function _resetAssignedGame(address _playerAddress) internal {
        _currentGameID[_playerAddress] = 0;
    }


//clean this up, possibly too many game id mappings, might need only one which would also reduce functions
//or have currentGameID, challengedGameID, and once challenge game is accepted, challengedGameID should be cleared
//just seems weird and messy when brain not working as good
    
    function _getGameID() internal view returns(uint) {
       return _currentGameID[msg.sender];
    }

    function _getChallengGameID() internal view returns(uint) {
        _challengGameID[msg.sender];
    }

   modifier checkIfInGame {
       require(_getGameID() == 0, "Please finish your current game before starting a new one.");
       _;
   }
    

    function _createGame(address _secondPlayer, uint _bet) internal{
        //change this require into a function and add to each create game type
        
        uint gameID = games.push(address msg.sender, _secondPlayer, 0, 0, _bet);
        _isPlayerInAGame[msg.sender] = true;
        _challengGameID[_secondPlayer] = gameID;
        emit newGame(msg.sender, _secondPlayer, _bet);
    }

    function openGameWallet(uint _bet) public checkIfInGame {
        _checkAllowance();
        createGame(_bet);
    }

    function challengGameWallet(address _secondPlayer, uint _bet) public checkIfInGame {
        _checkAllowance();
        createGame(_secondPlayer, _bet);
    }

    function openGameWinnings(uint _bet) public checkIfInGame {
        _checkWinnings();
        createGame(_bet);
    }

    function challengGameWinnings(address _secondPlayer, uint _bet) public checkIfInGame {
        _checkWinnings();
        createGame(_secondPlayer, _bet);
    }

    function acceptChallenge() public{
        _checkGameAssigned();
        Game storage challengGame = games[_getGameID()];
        challengeGame.player2Address = msg.sender;
    }

    function _makeMove(Game _currentGame, uint _playerMove) internal {
        require(_currentGame.player2Address != 0, "Can't make your move before another player joins.");
        if(_currentGame.player1Address == msg.sender){
            require(_currentGame.player1Move == 0, "You've already made your move!");
            _currentGame.player1Move = _playerMove;
        } else if(_currentGame.player2Address == msg.sender){
             require(_currentGame.player2Move == 0, "You've already made your move!");
            _currentGame.player2Move = _playerMove;
        } else {
            return "Not your game!"
        }
    }
/**
   complete _checkWinner() - is used to compare moves to find winner or draw - needs to check that both players have made their moves (1move != 0 && 2move != 0)
        increase player winnings if wins
        reset mappings for playerGameID and check if boolean mapping necessary, might be replicating same function in multiple ways
        */
     

    function _transferToPot(Game _currentGame, uint _bet) internal {
        iRPS.transferFrom(msg.sender, this, _bet);
        _currentGame.pot += _bet;
    }

    function makeMoveWallet(uint8 _playerMove) public {
        _id = getGameID();
        Game storage _currentGame = games[_id];
        _pot = _currentGame.pot;
        _bet = _currentGame.bet;
        _checkAllowance();
        _transferToPot(_currentGame, _bet);
        _makeMove(_currentGame, _playerMove);
    }

    function checkWinner() public{
        _id = getGameID();
        Game storage _currentGame = games[_id];
        _player1Address = _currentGame.player1Address;
        _player2Address = _currentGame.player2Address;
        _player1Move = _currentGame.player1Move;

        if(_player1Move == 0 || _player2Move == 0) {
            return "Waiting for otherplayer to make move."
        } else if(_player1Move == player2Move){
            currentGame.gameResult = 1;
        } else if(_player1Move == 1 && _player2Move == 2){
            currentGame.gameResult = 3;
        } else if(_player1Move ==1 && _player2Move == 3){
            currentGame.gameResult =2;
        } else if(_player1Move == 2 && _player2Move == 1){
            currentGame.gameResult = 2;
        } else if(_player1Move == 2 && _player2Move == 3){
            currentGame.gameResult = 3;
        } else if(_player1Move == 3 && _player2Move == 1){
            currentGame.gameResult = 3;
        } else if(_player1Move == 3 && _player2Move == 2){
            currentGame.gameResult = 2;
        } else {
            revert;
        }
    }

    function _announceWinner(Game _currentGame, address _player1Address, address _player2Address, Move _player1Move, Move player2Move,
                             uint _bet, uint _pot) internal{
        require(_currentGame.gameResult != 0, "Game not finished");
        if(_currentGame.gameResult == 1){
            _addWinnings(_player1Address, _bet);
            _addWinnings(_player2Address, _bet);
            _currentGame.pot = 0;
            _resetAssignedGameBoth(_player1Address, _player2Address);
            emit noWinner(_player1Move, _bet);
        } else if {_currentGame.gameResult == 2} {
            _addWinnings(_player1Address, _pot);
            _currentGame.pot = 0;
            _resetAssignedGameBoth(_player1Address, _player2Address);
            emit player1Wins(_player1Address, _player1Move, _player2Address, _player2Address, _pot);
        } else if {_currentGame.gameResult == 3} {
            _addWinnings(_player2Address, _pot);
            _currentGame.pot = 0;
            _resetAssignedGameBoth(_player1Address, _player2Address);
            emit player2Wins(_player2Address, _player2Move, _player1Address, _player1Address, _pot);
        } else {
            revert;
        }
    }

    /*
        NOTES to pick up

     

        implement _checkWinner() at bottom of makeMoveWallet()

        implement _makeMoveWinnings() - same as makeMoveWallet() but pulls from winnings
    */