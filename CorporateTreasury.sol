// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract corporateTreasury {
    enum Continent {
        None,
        NorthAmerica,
        Europe,
        Asia,
        Oceania,
        SouthAmerica,
        Africa
    }

    enum AssetClass {
        Equity,
        FixedIncome,
        Crypto,
        RealEstate
    }

    struct Investment{
        uint256 id;
        address investor;
        string assetName;
        uint256 principal;
        uint256 timestamp;
        Continent continent;
        AssetClass assetClass;
    }

    mapping(uint256 => Investment) public ledger;
    mapping(uint256 => bool) public idUsed;
    uint256 public totalInvestmentsCount;
    address public owner;
    uint totalSecondPerDay = 86_400;

    error CorporateTreasury_NotAutorized();
    error CorporateTreasury_InvalidAmount();
    error CorporateTreasury_SelectContinent();
    error CorporateTreasury_IDExist();
    error CorporateTreasury_InvstNotExist();

    event InvestmentRecorded(uint256 id, address investor, string assetName, uint256 principal, Continent continent);

    modifier onlyOwner {
        if(msg.sender != owner)  {
            revert CorporateTreasury_NotAutorized();
        }
        _;
    }
 
    function addInvestment(
        uint256 _id, 
        string memory _assetName, 
        Continent _continent, 
        AssetClass _assetClass
        ) external payable {
            if (msg.value == 0) {
                revert CorporateTreasury_InvalidAmount();
            }

            if (_continent == Continent.None) {
                revert CorporateTreasury_SelectContinent();
            }

            if (idUsed[_id] == true) {
            revert CorporateTreasury_IDExist();
        }

        ledger[_id] = Investment ({
            id: _id,
            investor: msg.sender,
            assetName: _assetName,
            principal: msg.value,
            timestamp: block.timestamp,
            continent: _continent,
            assetClass: _assetClass
        });

        idUsed[_id] = true;

        totalInvestmentsCount++;

        emit InvestmentRecorded(_id, msg.sender, _assetName, msg.value, _continent); 
    }

    function getDaysUnderManagement(uint256 _id) public view returns (uint256 daysUnderMgmt) {
            if(!idUsed[_id]) {
                revert CorporateTreasury_InvstNotExist();
            }
            daysUnderMgmt = (block.timestamp - ledger[_id].timestamp) / totalSecondPerDay;
            return daysUnderMgmt;
        }

    function calculateYield(uint256 _id) public view returns (uint256 accruedYield) {
        if(!idUsed[_id]) {
                revert CorporateTreasury_InvstNotExist();
        }
        accruedYield = (ledger[_id].principal * 5 * getDaysUnderManagement(_id)) / 3600; 
        return accruedYield;
    }

    function getInvestmentSummary(uint256 _id) external view returns ( address investor, uint256 principal, Continent continent ) {
        if(!idUsed[_id]) {
                revert CorporateTreasury_InvstNotExist();
        }
        return (ledger[_id].investor, ledger[_id].principal, ledger[_id].continent);
    }


}