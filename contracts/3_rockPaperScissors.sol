pragma solidity =0.8.7;

import "./2_rpsToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract rockPaperScissors   {

    
    address public _zero = 0x0000000000000000000000000000000000000000;

    address private _rpsToken;

    IERC20 public iRPS = IERC20(_rpsToken);

    event newGame(address challenger, address challenged, uint betAmount);
    event player1Wins(address player1, Move player1Move, address player2, Move player2Move, uint potAmount);
    event player2Wins(address player2, Move player2Move, address player1, Move player1Move, uint potAmount);
    event noWinner(Move player1Move, uint betAmount);
    event gameAccepted(address player2, uint gameID);

    mapping(address => uint) internal _playerWinnings;
    mapping(address => uint) internal _currentGameID;
    mapping(address => uint) internal _challengeGameID;

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

    uint private _decimals = 10^18;

    constructor(address rps){
        _rpsToken = rps;
    }

    modifier checkIfInGame {
       require(_getGameID() == 0, "Please finish your current game before starting a new one.");
       _;
   }



    function _checkAllowance(uint _bet) internal view {
        require(iRPS.allowance(msg.sender, address(this)) >= _bet * _decimals , "You must increase your RPS approval first.");
    }

    function _checkWinnings(uint _bet) internal view {
        require(_playerWinnings[msg.sender] >= _bet * _decimals , "You don't have enough tokens in your winnings.");
    }

    function _addWinnings(address _playerAddress, uint _amount) internal {
        _playerWinnings[_playerAddress] += _amount * _decimals;
    }

    function _resetAssignedGameBoth(address _player1Address, address _player2Address) internal {
        _currentGameID[_player1Address] = 0;
        _currentGameID[_player2Address] = 0;
    }


//clean this up, possibly too many game id mappings, might need only one which would also reduce functions
//or have currentGameID, challengedGameID, and once challenge game is accepted, challengedGameID should be cleared
//just seems weird and messy when brain not working as good
    
    function _getGameID() internal view returns(uint) {
       return _currentGameID[msg.sender];
    }

    function _getChallengeGameID() internal view returns(uint) {
        _challengeGameID[msg.sender];
    }

   
    

    function _createGame(address _secondPlayer, uint _bet) internal{        
        games.push(Game(msg.sender, _secondPlayer, Move.NONE, Move.NONE, _bet, block.timestamp, 0, Result.NONE));
        uint gameID = games.length - 1;
        _challengeGameID[_secondPlayer] = gameID;
        _currentGameID[msg.sender] = gameID;
        emit newGame(msg.sender, _secondPlayer, _bet);

    }

    function _checkChallengePlayer(address _player2) internal view {
        require(_challengeGameID[_player2] == 0, "Player already has open challenge");
        require(_currentGameID[_player2] == 0, "Player currently already in a game.");

    }

    function openGameWallet(uint bet) public checkIfInGame {
        _checkAllowance(bet);
        _createGame(_zero, bet);
    }

    function challengGameWallet(address secondPlayer, uint bet) public checkIfInGame {
        _checkAllowance(bet);
        _checkChallengePlayer(secondPlayer);
        _createGame(secondPlayer, bet);
    }

    function openGameWinnings(uint bet) public checkIfInGame {
        _checkWinnings(bet);
        _createGame(_zero, bet);
    }

    function challengGameWinnings(address secondPlayer, uint bet) public checkIfInGame {
        _checkWinnings(bet);
        _checkChallengePlayer(secondPlayer);
        _createGame(secondPlayer, bet);
    }

    function _joinGame(Game storage _currentGame, uint _gameID) internal {
        require(_currentGame.player2Address == msg.sender || _currentGame.player2Address == _zero, "Unable to join this game");
        _currentGameID[msg.sender] = _gameID;
        _challengeGameID[msg.sender] = 0;
        emit gameAccepted(msg.sender, _gameID);
    }

    function acceptChallengeWallet() public checkIfInGame{
        uint _challengeID = _getChallengeGameID();
        Game storage _challengeGame = games[_challengeID];
        uint _bet = _challengeGame.bet;
        _checkAllowance(_bet);
        _joinGame(_challengeGame, _challengeID);
    }

    function acceptChallengeWinnings() public checkIfInGame{
        uint _challengeID = _getChallengeGameID();
        Game storage _challengeGame = games[_challengeID];
        uint _bet = _challengeGame.bet;
        _checkWinnings(_bet);
        _joinGame(_challengeGame, _challengeID);
    }

    function findGameWallet(uint gameID) public checkIfInGame{
        Game storage _currentGame = games[gameID];
        uint _bet = _currentGame.bet;
        _checkAllowance(_bet);
        _joinGame(_currentGame, gameID);
    }

function findGameWinnings(uint gameID) public checkIfInGame{
        Game storage _currentGame = games[gameID];
        uint _bet = _currentGame.bet * _decimals;
        _checkWinnings(_bet);
        _joinGame(_currentGame, gameID);
    }

    function _makeMove(Game storage _currentGame, Move _playerMove) internal {
        require(_currentGame.player1Address == msg.sender || _currentGame.player2Address == msg.sender, "This isn't your game!");
        require(_currentGame.player2Address != _zero, "Can't make your move before another player joins.");
        if(_currentGame.player1Address == msg.sender){
            require(_currentGame.player1Move == Move.NONE, "You've already made your move!");
            _currentGame.player1Move = _playerMove;
        } else if(_currentGame.player2Address == msg.sender){
             require(_currentGame.player2Move == Move.NONE, "You've already made your move!");
            _currentGame.player2Move = _playerMove;
        } else {
            revert();
        }
    }

    function _transferToPot(Game storage _currentGame, uint _bet) internal {
        iRPS.transferFrom(msg.sender, address(this), _bet * _decimals);
        _currentGame.pot += _bet * _decimals;
    }

    function makeMoveWallet(Move playerMove) public {
        uint _id = _getGameID();
        Game storage _currentGame = games[_id];
       // uint _pot = _currentGame.pot;
        uint _bet = _currentGame.bet;
        _checkAllowance(_bet);
        _transferToPot(_currentGame, _bet);
        _makeMove(_currentGame, playerMove);
    }

    function makeMoveWinnings(Move playerMove) public {
        uint _id =_getGameID();
        Game storage _currentGame = games[_id];
       // uint _pot = _currentGame.pot;
        uint _bet = _currentGame.bet;
        _checkWinnings(_bet);
        _currentGame.pot += _bet;
        _playerWinnings[msg.sender] -= _bet;
        _makeMove(_currentGame, playerMove);
    }

     function _announceWinner(Game storage _currentGame, 
        address _player1Address, 
        address _player2Address, 
        Move _player1Move, 
        Move _player2Move, 
        uint _bet, 
        uint _pot) 
        internal{
        require(_currentGame.gameResult != Result.NONE, "Game not finished");
        if(_currentGame.gameResult == Result.DRAW){
            _addWinnings(_player1Address, _bet);
            _addWinnings(_player2Address, _bet);
            _currentGame.pot = 0;
            _resetAssignedGameBoth(_player1Address, _player2Address);
            emit noWinner(_player1Move, _bet);
        } else if(_currentGame.gameResult == Result.PLAYER1WINS) {
            _addWinnings(_player1Address, _pot);
            _currentGame.pot = 0;
            _resetAssignedGameBoth(_player1Address, _player2Address);
            emit player1Wins(_player1Address, _player1Move, _player2Address, _player2Move, _pot);
        } else if(_currentGame.gameResult == Result.PLAYER2WINS) {
            _addWinnings(_player2Address, _pot);
            _currentGame.pot = 0;
            _resetAssignedGameBoth(_player1Address, _player2Address);
            emit player2Wins(_player2Address, _player2Move, _player1Address, _player1Move, _pot);
        } 
    }

    function checkWinner() public{
        uint _id = _getGameID();
        Game storage _currentGame = games[_id];
        address _player1Address = _currentGame.player1Address;
        address _player2Address = _currentGame.player2Address;
        Move _player1Move = _currentGame.player1Move;
        Move _player2Move = _currentGame.player2Move;
        uint _bet = _currentGame.bet;
        uint _pot = _currentGame.pot;

        require(_player1Move != Move.NONE && _player2Move != Move.NONE, "Waiting for otherplayer to make move.");

        if(_player1Move == _player2Move){
            _currentGame.gameResult = Result.DRAW;
        } else if(_player1Move == Move.ROCK && _player2Move == Move.PAPER){
            _currentGame.gameResult = Result.PLAYER2WINS;
        } else if(_player1Move == Move.ROCK && _player2Move == Move.SCISSORS){
            _currentGame.gameResult = Result.PLAYER1WINS;
        } else if(_player1Move == Move.PAPER && _player2Move == Move.ROCK){
            _currentGame.gameResult = Result.PLAYER1WINS;
        } else if(_player1Move == Move.PAPER && _player2Move == Move.SCISSORS){
            _currentGame.gameResult = Result.PLAYER2WINS;
        } else if(_player1Move == Move.SCISSORS && _player2Move == Move.ROCK){
            _currentGame.gameResult = Result.PLAYER2WINS;
        } else if(_player1Move == Move.SCISSORS && _player2Move == Move.PAPER){
            _currentGame.gameResult = Result.PLAYER1WINS;
        } 
        _announceWinner(_currentGame, _player1Address, _player2Address, _player1Move, _player2Move, _bet, _pot);
    }

    function withdrawWinnings(uint withdrawalAmount) public {
        require(withdrawalAmount >= _playerWinnings[msg.sender], "Request exceeds balance.");
        iRPS.transferFrom(address(this), msg.sender, withdrawalAmount * _decimals);
        _playerWinnings[msg.sender] -= withdrawalAmount * _decimals;
    }
/*
    function cancelGame() public {
        uint _id = _getGameID();
        Game storage _currentGame = games[_id];

    } */
}