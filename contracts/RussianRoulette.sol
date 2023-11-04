// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RussianRoulette is ReentrancyGuard {
    uint8 private constant MAX_PLAYERS = 6;
    uint8 private constant ROOM_INCREMENT = 1;
    uint256 private MIN_BET = 0.01 ether;
    uint256 private constant OWNER_FEE_IN_PERCENTE = 10;

    uint256 public room;
    address payable[] public players;

    address public owner;

    event PlayerJoined(address indexed _player, uint256 _room);
    event VictimPlayer(address indexed _victimPlayer, uint256 _room);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "RussianRoulette: Only the owner can call this function"
        );
        _;
    }

    modifier onlyFeePaid() {
        string memory fee = string(
            abi.encodePacked(Strings.toString(MIN_BET), " ether")
        );
        string memory errorMessage = string(
            abi.encodePacked(
                "RussianRoulette: bet must be greater than or equal to ",
                fee
            )
        );

        require(msg.value >= MIN_BET, errorMessage);
        _;
    }

    modifier onlyRoomIsNotFull() {
        require(
            players.length < MAX_PLAYERS,
            "RussianRoulette: The game room is full"
        );
        _;
    }

    modifier onlyRoomIsFull() {
        require(
            players.length >= MAX_PLAYERS,
            "RussianRoulette: The game room is not full"
        );
        _;
    }

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }

    function getRoom() external view returns (uint256) {
        return room;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function changeMinBet(uint256 _minBet) external onlyOwner {
        MIN_BET = _minBet;
    }

    function enter() external payable onlyFeePaid onlyRoomIsNotFull {
        players.push(payable(msg.sender));
        room = room + ROOM_INCREMENT;

        emit PlayerJoined(msg.sender, room);

        if (players.length == MAX_PLAYERS) {
            play();
        }
    }

    function play() private onlyRoomIsFull {
        uint256 victimPlayer = random();
        distributeFunds(victimPlayer);

        emit VictimPlayer(players[victimPlayer], room);

        players = new address payable[](0);
        room = 0;
    }

    function distributeFunds(uint256 _victimPlayer) private nonReentrant {
        withdrawOwnerFeeGame(address(this).balance);

        (bool isOk, uint256 finalBalanceToDistribute) = Math.tryDiv(
            address(this).balance,
            (MAX_PLAYERS - 1)
        );

        require(
            isOk,
            "RussianRoulette: The balance cannot be calculate finalBalanceToDistribute, an error occurred when dividing"
        );

        address payable victimPlayer = players[_victimPlayer];

        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            if (players[i] != victimPlayer) {
                payable(players[i]).transfer(finalBalanceToDistribute);
            }
        }
    }

    function withdrawOwnerFeeGame(uint256 balance) private {
        uint256 ownerAmount = calculateOwnerAmount(balance);
        payable(owner).transfer(ownerAmount);
    }

    function calculateOwnerAmount(
        uint256 balance
    ) private pure returns (uint256) {
        return (balance * OWNER_FEE_IN_PERCENTE) / 100;
    }

    function random() private view returns (uint256) {
        return
            uint256(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            block.prevrandao,
                            block.timestamp,
                            block.number,
                            players.length,
                            room
                        )
                    )
                ) % MAX_PLAYERS
            );
    }
}
