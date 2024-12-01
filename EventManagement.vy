# @version ^0.4.0 

# Events
event BranchCreated:
    branch_id: uint256
    branch_owner: address
    metadata: String[100]

event MemberInvited:
    branch_id: uint256
    member: address

event MemberJoined:
    branch_id: uint256
    member: address

event MemberRemoved:
    branch_id: uint256
    member: address

event BranchDeleted:
    branch_id: uint256

event InvitationRevoked:
    branch_id: uint256
    member: address

event OwnershipTransferred:
    previous_owner: address
    new_owner: address

# State Variables
owner: public(address)

# Define a struct for BranchInfo (Owner and Metadata)
struct BranchInfo:
    owner: address
    metadata: String[100]

branches: public(HashMap[uint256, BranchInfo])  # Branch ID -> BranchInfo (Owner, Metadata)
branch_members: public(HashMap[uint256, uint256])  # Branch ID -> Current Member Count
max_members_per_branch: public(uint256)
invitations: public(HashMap[address, uint256])  # Member Address -> Branch ID

# Reentrancy guard
is_executing: public(bool)

# Initialize contract
@deploy
def __init__(max_members: uint256):
    self.owner = msg.sender
    self.max_members_per_branch = max_members
    self.is_executing = False

# Transfer ownership
@external
def transfer_ownership(new_owner: address):
    assert msg.sender == self.owner, "Only the contract owner can transfer ownership"
    log OwnershipTransferred(self.owner, new_owner)
    self.owner = new_owner

# Create a branch with metadata
@external
def create_branch(branch_id: uint256, branch_owner: address, metadata: String[100]):
    assert msg.sender == self.owner, "Only the contract owner can create branches"
    assert self.branches[branch_id].owner == empty(address), "Branch ID already exists"
    assert len(metadata) > 0, "Branch metadata must not be empty"

    self.branches[branch_id] = BranchInfo(owner=branch_owner, metadata=metadata)
    self.branch_members[branch_id] = 0
    log BranchCreated(branch_id, branch_owner, metadata)

# Invite a member to a branch
@external
def invite_member(branch_id: uint256, member: address):
    assert msg.sender == self.branches[branch_id].owner, "Only the branch owner can invite members"
    assert self.branch_members[branch_id] < self.max_members_per_branch, "Branch is full"
    assert self.invitations[member] == 0, "Member already has an invitation or joined a branch"

    self.invitations[member] = branch_id
    log MemberInvited(branch_id, member)

# Revoke an invitation
@external
def revoke_invitation(branch_id: uint256, member: address):
    assert msg.sender == self.branches[branch_id].owner, "Only the branch owner can revoke invitations"
    assert self.invitations[member] == branch_id, "No active invitation for this member in the branch"

    self.invitations[member] = 0
    log InvitationRevoked(branch_id, member)

# Join a branch as a member
@external
@nonreentrant
def join_branch():
    branch_id: uint256 = self.invitations[msg.sender]
    assert branch_id != 0, "No invitation found for this address"
    assert self.branch_members[branch_id] < self.max_members_per_branch, "Branch is full"

    self.branch_members[branch_id] += 1
    self.invitations[msg.sender] = 0  # Clear the invitation
    log MemberJoined(branch_id, msg.sender)

# Remove a member from a branch
@external
def remove_member(branch_id: uint256, member: address):
    assert msg.sender == self.branches[branch_id].owner, "Only the branch owner can remove members"
    assert self.branch_members[branch_id] > 0, "Branch has no members to remove"

    self.branch_members[branch_id] -= 1
    log MemberRemoved(branch_id, member)

# Delete a branch
@external
def delete_branch(branch_id: uint256):
    assert msg.sender == self.branches[branch_id].owner, "Only the branch owner can delete the branch"
    assert self.branch_members[branch_id] == 0, "Cannot delete a branch with active members"

    # Reset the branch's data using keyword arguments
    self.branches[branch_id] = BranchInfo(owner=empty(address), metadata="")
    self.branch_members[branch_id] = 0
    log BranchDeleted(branch_id)

