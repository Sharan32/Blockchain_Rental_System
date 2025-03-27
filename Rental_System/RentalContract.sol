// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract RentalContract {
    struct Rental {
        uint256 rentalId;
        address payable owner;
        address payable renter;
        uint256 rentAmount;
        uint256 deposit;
        uint256 duration; // Lease duration in seconds
        uint256 startTime;
        uint256 endTime;
        bool isActive;
    }

    mapping(uint256 => Rental) public rentals;
    uint256 public rentalCounter;

    event RentalCreated(uint256 rentalId, address indexed owner, uint256 rentAmount);
    event RentalStarted(uint256 rentalId, address indexed renter);
    event RentalEnded(uint256 rentalId, bool depositRefunded);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    /// @dev Landlord creates a rental listing.
    function createRental(uint256 rentAmount, uint256 deposit, uint256 duration) external {
        rentalCounter++;
        rentals[rentalCounter] = Rental({
            rentalId: rentalCounter,
            owner: payable(msg.sender),
            renter: payable(address(0)),
            rentAmount: rentAmount,
            deposit: deposit,
            duration: duration,
            startTime: 0,
            endTime: 0,
            isActive: false
        });

        emit RentalCreated(rentalCounter, msg.sender, rentAmount);
    }

    /// @dev Tenant starts renting, paying deposit & first rent.
    function startRental(uint256 rentalId) external payable {
        Rental storage rental = rentals[rentalId];
        require(rental.owner != address(0), "Rental does not exist");
        require(rental.renter == address(0), "Already rented");
        require(msg.value == rental.rentAmount + rental.deposit, "Incorrect payment");

        rental.renter = payable(msg.sender);
        rental.startTime = block.timestamp;
        rental.endTime = block.timestamp + rental.duration;
        rental.isActive = true;

        emit RentalStarted(rentalId, msg.sender);
    }

    /// @dev Ends the rental agreement and refunds deposit.
    function endRental(uint256 rentalId, bool refundDeposit) external {
        Rental storage rental = rentals[rentalId];
        require(msg.sender == rental.renter, "Only renter can end rental");
        require(rental.isActive, "Rental is not active");

        rental.isActive = false;
        if (refundDeposit) {
            rental.renter.transfer(rental.deposit);
        } else {
            rental.owner.transfer(rental.deposit);
        }

        emit RentalEnded(rentalId, refundDeposit);
    }

    /// @dev Landlord withdraws rent payments.
    function withdrawFunds(uint256 rentalId) external {
        Rental storage rental = rentals[rentalId];
        require(msg.sender == rental.owner, "Only owner can withdraw funds");
        require(!rental.isActive, "Rental is still active");

        uint256 amount = rental.rentAmount;
        rental.rentAmount = 0;
        rental.owner.transfer(amount);

        emit FundsWithdrawn(msg.sender, amount);
    }
}
