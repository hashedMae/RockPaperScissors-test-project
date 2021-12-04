pragma solidity >=0.8.0, <0.9.0;

import "./2_rpsToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract 3_rockPaperScissors is IERC20 {

    IERC20 private iRPS = IERC20(_rpsToken);

    event newGame(address challenger, address challenged, uint betAmount);

    constructor 3_rockPaperScissors() {

        struct Game{
        address player1Address;
        address player2Address;
        Move player1Move;
        Move player2Move;
        address winner
        uint bet;
        uint timeStart;
        uint pot;
        }

        Game[] public games;

        games.push(0,0,0,0,0,0,0)
    }

    mapping(address => uint) internal _playerWinnings;
    mapping(address => uint) internal _playerMove;
    //are these mappings necessary????
    mapping(address => uint) internal _currentGameID;
    mapping(address => uint) internal _challengGameID;

    enum Move{
        NONE,
        ROCK,
        PAPER,
        SCISSORS
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
//clean this up, possibly too many game id mappings, might need only one which would also reduce functions
//or have currentGameID, challengedGameID, and once challenge game is accepted, challengedGameID should be cleared
//just seems weird and messy when brain not working as good
    function _getGameID() internal view returns(uint) {
       return _ChallengeGameID[msg.sender];
    }

    function 

    function _checkGameAssigned() internal{
        require(_getGameID() != 0, "Game not found")
    }

    function _createGame(address _secondPlayer, uint _bet) internal{
        //change this require into a function and add to each create game type
        require(_getGameID() = 0, "Please finish your current game before starting a new one.");
        uint gameID = games.push(address msg.sender, _secondPlayer, 0, 0, _bet);
        _isPlayerInAGame[msg.sender] = true;
        _challengGameID[_secondPlayer] = gameID;
        emit newGame(msg.sender, _secondPlayer, _bet);
    }

    function openGameWallet(uint _bet) public {
        _checkAllowance();
        createGame(_bet);
    }

    function challengGameWallet(address _secondPlayer, uint _bet) public {
        _checkAllowance();
        createGame(_secondPlayer, _bet);
    }

    function openGameWinnings(uint _bet) public {
        _checkWinnings();
        createGame(_bet);
    }

    function challengGameWinnings(address _secondPlayer, uint _bet) public {
        _checkWinnings();
        createGame(_secondPlayer, _bet);
    }

    function acceptChallenge() public{
        _checkGameAssigned();
        Game storage challengGame = games[_getGameID()];
        challengeGame.player2Address = msg.sender;
    }

    function _makeMove(uint _playerMove) internal {
        if(currentGame.player1Address = msg.sender){
            require(currentGame.player1Move = 0, "You've already made your move!");
            currentGame.player1Move = _playerMove;
        } else if(currentGame.player2Address = msg.sender){
             require(currentGame.player2Move = 0, "You've already made your move!");
            currentGame.player2Move = _playerMove;
        } else {
            return "Not your game!"
        }
    }
/**
   complete _checkWinner() - is used to compare moves to find winner or draw - needs to check that both players have made their moves (1move != 0 && 2move != 0)
        increase player winnings if wins
        reset mappings for playerGameID and check if boolean mapping necessary, might be replicating same function in multiple ways
        */
    function _checkWinner(uint _player1Move, uint _player2Move) internal{

    }

    function makeMoveWallet(uint _playerMove) public {
        _checkAllowance();
        //from here
        Game storage currentGame = games[_getGameID()];
        _bet = currentGame.bet();
        iRPS.transferFrom(msg.sender, this, );
        currentGame.pot += _bet;
        //to here can be made into a seperate function to avoid duplication in makeMoveWinnings()
        _makeMove(_playerMove);
    }

    /*
        NOTES to pick up

     

        implement _checkWinner() at bottom of makeMoveWallet()

        implement _makeMoveWinnings() - same as makeMoveWallet() but pulls from winnings
    */