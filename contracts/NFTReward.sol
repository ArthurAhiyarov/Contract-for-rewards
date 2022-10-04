// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract NFTReward is Ownable {

    /* ========== STATE VARIABLES ========== */
    
    uint256 private fracReward; // reward amount in fracs
    uint256 private fracBalance; // amount of frac in contract's balance
    address private rewardNFTaddr;
    address private fracTokenAddr;

    ERC20 private fracToken;
    ERC721Burnable private rewardNFT;

    mapping(uint256 => bool) private isNftUsed; //NFT's ids to their exchanged state

    /* ========== EVENTS ========== */

    event rewardTransferred (address to, uint256 rewardAmt);

    constructor(address _fracTokenAddr, address _rewardNFTaddr, uint256 _reward) {
        fracTokenAddr = _fracTokenAddr;
        rewardNFTaddr = _rewardNFTaddr;
        fracReward = _reward;
        fracToken = ERC20(fracTokenAddr);
        rewardNFT = ERC721Burnable(rewardNFTaddr);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /** @dev Lets caller use their NFT to get the reward
      * @param _tokenId ID of an NFT caller wants to use
      * Emits the rewardTransferred event
     */

    function getRewardAndMarkNFT(uint256 _tokenId) public {
        address owner = rewardNFT.ownerOf(_tokenId);
        require(owner == msg.sender, "Only the owner of NFT can transfer or burn it");
        require(isNftUsed[_tokenId] == false, "You have already used your nft");
        require(fracBalance - fracReward > 0, "Not enough funds");
        isNftUsed[_tokenId] = true;
        fracBalance -= fracReward;
        fracToken.transfer(msg.sender, fracReward);

        emit rewardTransferred(msg.sender, fracReward);
    }

    /** @dev Marks a NFT as used and decreases fracBalance
      * @param _tokenId ID of an NFT caller wants to use
      * return true
     */

    function sendRewardAndMarkNft(uint256 _tokenId) public onlyOwner returns(bool) {
        require(isNftUsed[_tokenId] == false, "You have already used your nft");
        require(fracBalance - fracReward > 0, "Not enough funds");
        isNftUsed[_tokenId] = true;
        fracBalance -= fracReward;
        return true;
    }

    /** @dev Lets anybody fund this contract with frac
      * @param _fundAmt Amount of frac caller wants to fund
     */

    function fundWithFrac(uint256 _fundAmt) public {
        fracBalance += _fundAmt;
        fracToken.transferFrom(msg.sender, address(this), _fundAmt);
    }

    /** @dev Lets the owner withdraw frac tokens from the contract
      * @param _amount Amount of frac caller wants to withdraw
     */

    function withdrawFrac(uint256 _amount) public onlyOwner {
        require(fracBalance - _amount >= 0, "Cannot withdraw that much");
        fracBalance -= _amount;
        fracToken.transfer(owner(), _amount);
    }

    /** @dev Marks a NFT as used and decreases fracBalance
      * @param newReward ID of an NFT caller wants to use
      * return fracReward Updated fracReward
     */

    function changeFracRewardAmount(uint256 newReward) public onlyOwner returns(uint256) {
        fracReward = newReward;
        return fracReward;
    }

    /* ========== VIEWS ========== */

    /** @dev Shows if NFT has been used
      * @param _tokenId ID of an NFT caller wants to use
      * return bool Trus if it hasn't used, false if has
     */

    function getIsNftUsedValue(uint256 _tokenId) public view returns(bool) {
        address ownerAddr = rewardNFT.ownerOf(_tokenId);
        require(ownerAddr != address(0), "This Id doesn't exist");
        return isNftUsed[_tokenId];
    }

    /** @dev Shows amount of fracs on the contract
     */

    function getFracBalance() public view onlyOwner returns(uint256){
        return fracBalance;
    }

    /** @dev Shows reward level in fracs
     */

    function getFracReward() public view onlyOwner returns(uint256){
        return fracReward;
    }

    /** @dev Shows address of NFT contract used for rewarding
     */

    function getRewardNFTaddr() public view onlyOwner returns(address){
        return rewardNFTaddr;
    }

    /** @dev Shows address of frac token contract
     */

    function getFracTokenAddr() public view onlyOwner returns(address){
        return fracTokenAddr;
    }

    receive() external payable{}
}