pragma solidity ^0.4.24;

/// @title LinkedList - Manages a set of owners and a threshold to perform actions.
/// @author Andy Chorlian - <andychorlian@gmail.com>
contract CircularDoubleLinkedList {

    event AddressAdded(address _address);
    event AddressRemoved(address _address);

    struct node {
        address previous;
        address next;
    }

    address public tail = 0x0;

    mapping(address => node) internal _addresses;
    uint256 addressCount;

    /// @dev Setup function sets initial storage of contract.
    /// @param _addressList List of addresses to start with.
    function initialize(address[] _addressList)
        internal
    {
        // Initializing.
        address previousAddress = _addressList[_addressList.length  - 1];
        address currentAddress = _addressList[0];
        for (uint256 i = 1; i < _addressList.length; i++) {
            // address cannot be null.
            address newAddress = _addressList[i];
            require(newAddress != 0 && newAddress != _addressList[0], "Invalid new address provided");
            // No duplicate addresses allowed.
            require(
                _addresses[newAddress].previous == 0 && _addresses[newAddress].next == 0,
                "Duplicate new address provided"
            );
            _addresses[currentAddress].previous = previousAddress;
            _addresses[currentAddress].next = newAddress;
            previousAddress = currentAddress;
            currentAddress = newAddress;
        }
        _addresses[currentAddress].previous = previousAddress;
        _addresses[currentAddress].next = _addressList[0];
        tail = currentAddress;
        addressCount = _addressList.length;
    }

    /// @dev Allows to add a new owner to the Safe and update the threshold at the same time.
    ///      This can only be done via a Safe transaction.
    /// @param _address New owner address.
    function add(address _address)
        public
    {
        // Owner address cannot be null.
        require(_address != 0, "Invalid owner address provided");
        // No duplicate owners allowed.
        require(_addresses[_address].previous == 0 && _addresses[_address].next == 0, "Address is already added");
        _addresses[_address].previous = tail;
        _addresses[_address].next = _addresses[tail].next;
        _addresses[tail].next = _address;
        addressCount++;
        emit AddressAdded(_address);
    }

    /// @dev Allows to remove an address.
    /// @param _address address to be removed.
    function remove(address _address)
        public
    {
        // Validate address and check that it corresponds to index.
        require(_address != 0, "Invalid owner address provided");
        address prevAddress = _addresses[_address].previous;
        address nextAddress = _addresses[_address].next;

        if (_address == tail){
            tail == prevAddress;
        }

        _addresses[prevAddress].next = nextAddress;
        _addresses[nextAddress].previous = prevAddress;
        _addresses[_address].previous = 0;
        _addresses[_address].next = 0;
        addressCount--;
        emit AddressRemoved(_address);
    }

    /// @dev Allows to swap/replace an address with another address.
    /// @param oldAddress Owner address to be replaced.
    /// @param newAddress New owner address.
    function swapAddress(address oldAddress, address newAddress)
        public
    {
        // Owner address cannot be null.
        require(newAddress != 0, "Invalid new address provided");
        // No duplicate owners allowed.
        require(_addresses[newAddress].previous == 0 && _addresses[newAddress].next == 0, "Address is already added");
        // Validate oldOwner address and check that it corresponds to owner index.
        require(oldAddress != 0, "Invalid old address provided");

        if (oldAddress == tail){
            tail == newAddress;
        }

        address prevAddress = _addresses[oldAddress].previous;
        address nextAddress = _addresses[oldAddress].next;

        _addresses[prevAddress].next = newAddress;
        _addresses[nextAddress].previous = newAddress;

        _addresses[newAddress].previous = prevAddress;
        _addresses[newAddress].next = nextAddress;

        _addresses[oldAddress].previous = 0;
        _addresses[oldAddress].next = 0;

        emit AddressRemoved(oldAddress);
        emit AddressAdded(newAddress);
    }

    function contains(address _address)
        public
        view
        returns (bool)
    {
        return _addresses[_address].next != 0 || _addresses[_address].previous != 0;
    }

    /// @dev Returns array of owners.
    /// @return Array of Safe owners.
    function getAddresses()
        public
        view
        returns (address[])
    {
        address[] memory array = new address[](addressCount);

        // populate return array
        uint256 index = 0;
        address currentAddress = _addresses[tail].next;
        while(currentAddress != _addresses[tail].next) {
            array[index] = currentAddress;
            currentAddress = _addresses[currentAddress].next;
            index ++;
        }
        return array;
    }
}
