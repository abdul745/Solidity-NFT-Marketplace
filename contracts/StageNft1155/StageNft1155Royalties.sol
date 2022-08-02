// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract StageNftErc20 {

    event RoyaltiesTransfer(uint, uint, uint);
    struct royaltyInfo {
        address payable recipient;
        uint24 percentage;
    }
    mapping (address => uint) deposits;
    mapping(uint256 => royaltyInfo) _royalties;
    //mapping (address=>bool) StageNFTWhiteList;
    function _setTokenRoyalty(uint256 tokenId,address payable recipient,uint256 value) internal {
        require((value >= 0 && value < 100), "Royalties must be Between 0 and 99");
        _royalties[tokenId] = royaltyInfo(recipient, uint24(value));
    }
    
    function _royaltyAndStageNFTFee (uint _NftPrice, uint percentage, address payable minterAddress, address payable NftSeller, uint8 serviceFee) internal  {
        
        require(msg.value==_NftPrice,"Not enough Amount provided"); 
        uint _TotalNftPrice = msg.value;                                // require(msg.value >= NftPrice[NftId], "Error! Insufficent Balance");
        uint _StageNFTFee = _calculateStageNFTFee(_NftPrice, serviceFee);
        uint _minterFee = _calculateAndSendMinterFee(_NftPrice , percentage,  minterAddress);
        _TotalNftPrice = _TotalNftPrice - _StageNFTFee - _minterFee;    //Remaining Price After Deduction  
        _transferAmountToSeller( _TotalNftPrice, NftSeller);            // Send Amount to NFT Seller after Tax deduction
        emit RoyaltiesTransfer(_StageNFTFee,_minterFee, _TotalNftPrice);
    }
    function _calculateStageNFTFee(uint Price, uint8 serviceFee) internal pure returns(uint) {
        require((Price/10000)*10000 == Price, "Error!Price Too small");
        return (Price*serviceFee)/1000;
    }
    

    function _transferAmountToSeller(uint amount, address payable seller) internal {
        seller.transfer(amount);
    }

    function _calculateAndSendMinterFee(uint _NftPrice, uint Percentage, address payable minterAddr) internal returns(uint) {
        uint AmountToSend = (_NftPrice*Percentage)/100;           //Calculate Minter percentage and Send to his Address from Struct
        minterAddr.transfer(AmountToSend);                       // Send this Amount To Transfer Address from Contract balacne
        return AmountToSend;
    }
    function depositAmount(address payee,uint amountToDeposit) internal {
        require(msg.value == amountToDeposit, "Error while Deposit");
        deposits[payee] += amountToDeposit;
    }
    function deductAmount(address from, uint amount) internal {
        require(deposits[from]>0, "0 Deposit");
        require(amount <= deposits[from] , "amountToDeposit > deposits[from]");
        deposits[from] -= amount;
    }


}