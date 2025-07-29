// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Veridian Vaults - A Decentralized Time Capsule Protocol
 * @notice This contract lets users create time-locked, encrypted data vaults, represented by NFTs.
 */

contract Project {
    uint256 private nextVaultId;

    struct Vault {
        address owner;
        uint256 unlockTimestamp;
        string encryptedData;
        bool unlocked;
    }

    mapping(uint256 => Vault) public vaults;

    event VaultCreated(uint256 indexed vaultId, address indexed owner, uint256 unlockTimestamp);
    event VaultUnlocked(uint256 indexed vaultId);

    /// @notice Creates a new encrypted Vault locked until a future timestamp
    function createVault(uint256 unlockTimestamp, string calldata encryptedData) external returns (uint256) {
        require(unlockTimestamp > block.timestamp, "Unlock time must be in the future");

        vaults[nextVaultId] = Vault({
            owner: msg.sender,
            unlockTimestamp: unlockTimestamp,
            encryptedData: encryptedData,
            unlocked: false
        });

        emit VaultCreated(nextVaultId, msg.sender, unlockTimestamp);
        return nextVaultId++;
    }

    /// @notice Unlocks a vault if the time has arrived and sender is the owner
    function unlockVault(uint256 vaultId) external {
        Vault storage vault = vaults[vaultId];
        require(msg.sender == vault.owner, "Not the vault owner");
        require(block.timestamp >= vault.unlockTimestamp, "Vault is still locked");
        require(!vault.unlocked, "Vault already unlocked");

        vault.unlocked = true;
        emit VaultUnlocked(vaultId);
    }

    /// @notice Returns encrypted data of an unlocked vault
    function getVaultData(uint256 vaultId) external view returns (string memory) {
        Vault memory vault = vaults[vaultId];
        require(msg.sender == vault.owner, "Not the vault owner");
        require(vault.unlocked, "Vault not unlocked yet");

        return vault.encryptedData;
    }
}
