# Event Management Smart Contract

This smart contract allows the creation and management of branches, membership invitations, and ownership transfers within a decentralized event management system.

## Table of Contents
- [Overview](#overview)
- [Events](#events)
- [State Variables](#state-variables)
- [Functions](#functions)
  - [Ownership Management](#ownership-management)
  - [Branch Management](#branch-management)
  - [Member Management](#member-management)
  - [Invitation Management](#invitation-management)
- [Deployment](#deployment)

---

## Overview

The **Event Management Smart Contract** is designed to handle the creation, modification, and deletion of branches, manage invitations for membership, and allow ownership transfer. Events are logged to track important actions such as branch creation, membership invitations, and changes in ownership.

---

## Events

The following events are emitted by the contract to log important actions:

- **BranchCreated**: Emitted when a new branch is created.
  - `branch_id`: The ID of the branch.
  - `branch_owner`: The address of the branch owner.
  - `metadata`: A string containing metadata about the branch.

- **MemberInvited**: Emitted when a member is invited to a branch.
  - `branch_id`: The ID of the branch.
  - `member`: The address of the invited member.

- **MemberJoined**: Emitted when a member successfully joins a branch.
  - `branch_id`: The ID of the branch.
  - `member`: The address of the member who joined.

- **MemberRemoved**: Emitted when a member is removed from a branch.
  - `branch_id`: The ID of the branch.
  - `member`: The address of the removed member.

- **BranchDeleted**: Emitted when a branch is deleted.
  - `branch_id`: The ID of the branch.

- **InvitationRevoked**: Emitted when an invitation is revoked.
  - `branch_id`: The ID of the branch.
  - `member`: The address of the member whose invitation was revoked.

- **OwnershipTransferred**: Emitted when the ownership of the contract is transferred.
  - `previous_owner`: The address of the previous owner.
  - `new_owner`: The address of the new owner.

---

## State Variables

- **owner**: The address of the contract owner.
- **branches**: A mapping from branch ID (`uint256`) to branch information (`BranchInfo` struct) containing the branch owner and metadata.
- **branch_members**: A mapping from branch ID (`uint256`) to the current number of members in the branch.
- **max_members_per_branch**: The maximum number of members allowed per branch.
- **invitations**: A mapping from member address (`address`) to branch ID (`uint256`) representing the invitations extended to members.
- **is_executing**: A reentrancy guard flag to prevent reentrancy attacks during critical functions.

---

## Functions

### Ownership Management

- **`transfer_ownership(new_owner: address)`**: Allows the current contract owner to transfer ownership to a new address.
  - Only the current owner can call this function.
  - Emits the `OwnershipTransferred` event.

### Branch Management

- **`create_branch(branch_id: uint256, branch_owner: address, metadata: String[100])`**: Allows the contract owner to create a new branch with a specified ID, owner, and metadata.
  - Emits the `BranchCreated` event.
  - Only the contract owner can create branches.

- **`delete_branch(branch_id: uint256)`**: Deletes a branch if it has no active members.
  - Only the branch owner can delete the branch.
  - Emits the `BranchDeleted` event.

### Member Management

- **`remove_member(branch_id: uint256, member: address)`**: Removes a member from a branch.
  - Only the branch owner can remove members.
  - Emits the `MemberRemoved` event.

- **`join_branch()`**: Allows an invited member to join a branch.
  - The invitation must be valid and the branch must have space for more members.
  - Emits the `MemberJoined` event.

### Invitation Management

- **`invite_member(branch_id: uint256, member: address)`**: Allows a branch owner to invite a member to their branch.
  - The branch must not exceed the member limit.
  - The invited member must not already have an active invitation.
  - Emits the `MemberInvited` event.

- **`revoke_invitation(branch_id: uint256, member: address)`**: Revokes an invitation for a member to join a branch.
  - Only the branch owner can revoke invitations.
  - Emits the `InvitationRevoked` event.

---

## Deployment

To deploy the contract, follow these steps:

1. **Compile the contract**: Use a Solidity compiler to compile the smart contract.
2. **Deploy the contract**: Deploy the contract to a blockchain testnet Sepolia(ETH) using Infura project_id and metamask wallet.
3. **Interact with the contract**: After deployment, use a blockchain wallet (e.g., MetaMask) or a front-end application to interact with the contract functions.

Make sure to set the `max_members` parameter when deploying to control the maximum number of members per branch.

---

## Example Use Case

1. The contract owner creates a branch with a unique ID and owner address.
2. The branch owner invites members to join the branch.
3. Members can accept invitations and join the branch.
4. Branch owners can remove members or delete the branch if it has no members.
5. The contract owner can transfer ownership of the contract to another address.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
