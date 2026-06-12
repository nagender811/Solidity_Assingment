// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract EventTicketingPlatform {
    enum EventType {
        None,
        Conference,
        Workshop,
        Hackathon,
        Meetup,
        Webinar,
        Summit
    }

    enum TicketTier {
        Standard,
        Premium,
        VIP
    }

    struct Ticket {
        uint256 ticketId;
        address buyer;
        string eventName;
        uint256 purchaseAmount;
        uint256 purchaseTimestamp;
        uint256 eventTimestamp;
        EventType eventType;
        TicketTier ticketTier;
    }

    mapping(uint256 => Ticket) public tickets;
    mapping(uint256 => bool) public ticketsUsed;
    uint256 public totalTicketSold;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Authorized");
        _;
    }

    event TicketPurchased(
        uint indexed ticketId,
        address indexed buyer,
        string eventName,
        uint256 amountPaid,
        EventType eventType
    );

    error EventTicketingPlatform_InvalidAmount();
    error EventTicketingPlatform_SelectEventType();
    error EventTicketingPlatform_InvalidEventDate();
    error EventTicketingPlatform_TicketExists();
    error EventTicketingPlatform_TicketDoesNotExist();

    function _ticketDoesNotExist(uint256 _ticketId) view private {
        if(!ticketsUsed[_ticketId]) {
            revert EventTicketingPlatform_TicketDoesNotExist();
        }
    } 

    function purchaseTicket(
        uint256 _ticketId,
        string memory _eventName,
        uint256 _eventTimestamp,
        EventType _eventType,
        TicketTier _ticketTier
    ) external payable {
        if(msg.value == 0) {
            revert EventTicketingPlatform_InvalidAmount();
        }
        if(_eventType == EventType.None) {
            revert EventTicketingPlatform_SelectEventType();
        }
        if(_eventTimestamp <= block.timestamp) {
            revert EventTicketingPlatform_InvalidEventDate();
        }
        if(ticketsUsed[_ticketId]) {
            revert EventTicketingPlatform_TicketExists();
        }

        tickets[_ticketId] = Ticket({
            ticketId: _ticketId,
            buyer: msg.sender,
            eventName: _eventName,
            purchaseAmount: msg.value,
            purchaseTimestamp: block.timestamp,
            eventTimestamp: _eventTimestamp,
            eventType: _eventType,
            ticketTier: _ticketTier
        });

        ticketsUsed[_ticketId] = true;
        totalTicketSold++;

        emit TicketPurchased(_ticketId, msg.sender, _eventName, msg.value, _eventType);
    }

        function getDaysUntilEvent(uint256 _ticketId) public view returns(uint256 daysRemaining) {
        _ticketDoesNotExist(_ticketId);
        if (block.timestamp >= tickets[_ticketId].eventTimestamp) {
            return 0;
        }

        return (tickets[_ticketId].eventTimestamp - block.timestamp) / 1 days;
        
    }

    function _getRefundPercentage(uint256 _remainingDays) pure private returns(uint256 refundPercentage) {
        if(_remainingDays >= 30) {
            return 80;
        } else if(_remainingDays >= 15 && _remainingDays < 30) {
            return 50;
        } else if(_remainingDays >= 7 && _remainingDays < 15) {
            return 25;
        } else {
            return 0;
        }
    }

    function calculateRefundAmount(uint256 _ticketId) public view returns(uint256 refundAmount){
        _ticketDoesNotExist(_ticketId);
        uint256 remainingDays = getDaysUntilEvent(_ticketId);
        uint256 refundPercentage = _getRefundPercentage(remainingDays);
        refundAmount = (tickets[_ticketId].purchaseAmount * refundPercentage / 100);
        return refundAmount;
    }

    function getTicketSummary(uint256 _ticketId) external view returns(address buyer, uint256 purchaseAmount, TicketTier tier) {
        _ticketDoesNotExist(_ticketId);
        buyer = tickets[_ticketId].buyer;
        purchaseAmount = tickets[_ticketId].purchaseAmount;
        tier = tickets[_ticketId].ticketTier;
        return (buyer, purchaseAmount, tier);
    }
}
