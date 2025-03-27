// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    address public admin;
    mapping(string => uint256) private votes;
    mapping(address => bool) private hasVoted;
    string[] private candidates;

    event VoteCast(address indexed voter, string candidate);

    constructor() {
        admin = msg.sender;
    }

    function vote(string memory _candidate) public {
        require(!hasVoted[msg.sender], "You have already voted"); // Restricts one vote per user

        if (votes[_candidate] == 0) {
            candidates.push(_candidate); // Store new candidate
        }

        votes[_candidate]++;
        hasVoted[msg.sender] = true; // Mark voter as voted
        emit VoteCast(msg.sender, _candidate);
    }

    function getVotes(string memory _candidate) public view returns (uint256) {
        return votes[_candidate];
    }

    function resetVotes() public {
        require(msg.sender == admin, "Only admin can reset votes");

        for (uint256 i = 0; i < candidates.length; i++) {
            votes[candidates[i]] = 0;
        }

        // Reset all voters' status
        for (uint256 i = 0; i < candidates.length; i++) {
            hasVoted[address(uint160(i))] = false; // Reset votes for all possible addresses
        }
    }
}
