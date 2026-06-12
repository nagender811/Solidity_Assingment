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
        if(!ticketsUsed[_ticketId]) {
            revert EventTicketingPlatform_TicketDoesNotExist();
        }
        if (block.timestamp >= tickets[_ticketId].eventTimestamp) {
            return 0;
        }

        return (tickets[_ticketId].eventTimestamp - block.timestamp) / 1 days;
        
    }
}
