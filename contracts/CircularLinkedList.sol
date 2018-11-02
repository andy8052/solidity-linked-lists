pragma solidity ^0.4.24;

/// @title LinkedList - Manages a set of owners and a threshold to perform actions.
/// @author Andy Chorlian - <andychorlian@gmail.com>
contract CircularLinkedList {

    event AddressAdded(address _address);
    event AddressRemoved(address _address);

    address public tail = 0x0;
    mapping(address => address) internal _addresses;
    uint256 addressCount;

    /// @dev Setup function sets initial storage of contract.
    /// @param _addressList List of addresses to start with.
    function initialize(address[] _addressList)
        internal
    {
        // Initializing.
        address currentAddress = _addressList[0];
        for (uint256 i = 1; i < _addressList.length; i++) {
            // address cannot be null.
            address newAddress = _addressList[i];
            require(newAddress != 0 && newAddress != _addressList[0], "Invalid new address provided");
            // No duplicate addresses allowed.
            require(_addresses[newAddress] == 0, "Duplicate new address provided");
            _addresses[currentAddress] = newAddress;
            currentAddress = newAddress;
        }
        _addresses[currentAddress] = _addressList[0];
        tail = currentAddress;
        addressCount = _addressList.length;
    }

    /// @dev Allows to add a new owner to the Safe and update the threshold at the same time.
    ///      This can only be done via a Safe transaction.
    /// @param _address New owner address.
    function addAddress(address _address)
        public
    {
        // Owner address cannot be null.
        require(_address != 0, "Invalid address provided");
        // No duplicate addresses allowed.
        require(_addresses[_address] == 0, "Address is already an owner");

        // Insert new address to start of list
        address oldHead = _addresses[tail];
        _addresses[tail] = _address;
        _addresses[_address] = oldHead;

        addressCount++;
        emit AddressAdded(_address);
    }

    /// @dev Allows to remove an address.
    /// @param _prevAddress address that pointed to the address to be removed in the linked list
    /// @param _address address to be removed.
    function remove(address _prevAddress, address _address)
        public
    {
        // Validate address and check that it corresponds to index.
        require(_address != 0, "Invalid owner address provided");
        require(_addresses[_prevAddress] == _address, "Invalid prevAddress, address pair provided");

        if (_address == tail){
            tail == _prevAddress;
        }

        _addresses[_prevAddress] = _addresses[_address];
        _addresses[_address] = 0;
        addressCount--;
        emit AddressRemoved(_address);
    }

    /// @dev Allows to swap/replace an address with another address.
    /// @param prevAddress Owner that pointed to the owner to be replaced in the linked list
    /// @param oldAddress Owner address to be replaced.
    /// @param newAddress New owner address.
    function swapAddress(address prevAddress, address oldAddress, address newAddress)
        public
    {
        // Owner address cannot be null.
        require(newAddress != 0, "Invalid owner address provided");
        // No duplicate owners allowed.
        require(_addresses[newAddress] == 0, "Address is already added");
        // Validate oldOwner address and check that it corresponds to owner index.
        require(oldAddress != 0, "Invalid address provided");
        require(_addresses[prevAddress] == oldAddress, "Invalid prevOwner, owner pair provided");

        if (oldAddress == tail){
            tail == newAddress;
        }

        _addresses[newAddress] = _addresses[oldAddress];
        _addresses[prevAddress] = newAddress;
        _addresses[oldAddress] = 0;
        emit AddressRemoved(oldAddress);
        emit AddressAdded(newAddress);
    }

    function contains(address _address)
        public
        view
        returns (bool)
    {
        return _addresses[_address] != 0;
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
        address currentAddress = _addresses[tail];
        while(currentAddress != _addresses[tail]) {
            array[index] = currentAddress;
            currentAddress = _addresses[currentAddress];
            index ++;
        }
        return array;
    }
}
