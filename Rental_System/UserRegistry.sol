// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract UserRegistry {
    enum UserType { Unregistered, Landlord, Renter }

    struct User {
        address userAddress;
        string name;
        UserType userType;
        bool isRegistered;
    }

    mapping(address => User) public users;

    event UserRegistered(address indexed userAddress, string name, UserType userType);

    /// @dev Register a new user as Landlord (1) or Renter (2)
    function registerUser(string memory name, uint8 userType) external {
        require(userType > 0 && userType <= 2, "Invalid user type");  // ✅ Fixed condition
        require(!users[msg.sender].isRegistered, "User already registered");

        users[msg.sender] = User({
            userAddress: msg.sender,
            name: name,
            userType: UserType(userType),  // ✅ Correct conversion
            isRegistered: true
        });

        emit UserRegistered(msg.sender, name, UserType(userType));
    }

    /// @dev Check if user is registered
    function isUserRegistered(address user) external view returns (bool) {
        return users[user].isRegistered;
    }

    /// @dev Get user type (Landlord or Renter)
    function getUserType(address user) external view returns (UserType) {
        require(users[user].isRegistered, "User not registered");
        return users[user].userType;
    }
}
