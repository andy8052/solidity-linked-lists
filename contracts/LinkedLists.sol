pragma solidity ^0.4.24;

/// @title LinkedList - Manages a set of owners and a threshold to perform actions.
/// @author Andy Chorlian - <andychorlian@gmail.com>
contract LinkedList {

    event Added(address added);
    event Removed(address removed);

    address public constant SENTINEL = 1;

    mapping(address => address) internal objects;
    uint256 count;

    /// @dev Setup function sets initial storage of contract.
    /// @param _addressList List of addresses to start with.
    function initialize(address[] _list)
        internal
    {
        // Initializing.
        address current = SENTINEL;
        for (uint256 i = 0; i < _list.length; i++) {
            // address cannot be null.
            address next = _list[i];
            require(next != 0 && next != SENTINEL, "Invalid new address provided");
            // No duplicate addresses allowed.
            require(objects[next] == 0, "Duplicate new address provided");
            objects[current] = next;
            current = next;
        }
        objects[current] = SENTINEL;
        count = _list.length;
    }

    /// @dev Allows to add a new owner to the Safe and update the threshold at the same time.
    ///      This can only be done via a Safe transaction.
    /// @param _address New owner address.
    function add(address _added)
        public
    {
        // Owner address cannot be null.
        require(_added != 0 && _added != SENTINEL, "Invalid owner address provided");
        // No duplicate owners allowed.
        require(objects[_added] == 0, "Address is already an owner");
        objects[_added] = objects[SENTINEL];
        objects[SENTINEL] = _added;
        addressCount++;
        emit AddressAdded(_added);
    }

    /// @dev Allows to remove an address.
    /// @param _prevAddress address that pointed to the address to be removed in the linked list
    /// @param _address address to be removed.
    function remove(address _previous, address _removed)
        public
    {
        // Validate address and check that it corresponds to index.
        require(_removed != 0 && _removed != SENTINEL, "Invalid owner address provided");
        require(objects[_previous] == _removed, "Invalid prevOwner, owner pair provided");
        objects[_previous] = objects[_removed];
        objects[_removed] = 0;
        addressCount--;
        emit AddressRemoved(_removed);
    }

    /// @dev Allows to swap/replace an address with another address.
    /// @param prevAddress Owner that pointed to the owner to be replaced in the linked list
    /// @param oldAddress Owner address to be replaced.
    /// @param newAddress New owner address.
    function swap(address _previous, address _old, address _new)
        public
    {
        // Owner address cannot be null.
        require(_new != 0 && _new != SENTINEL, "Invalid owner address provided");
        // No duplicate owners allowed.
        require(objects[_new] == 0, "Address is already an owner");
        // Validate oldOwner address and check that it corresponds to owner index.
        require(_old != 0 && _old != SENTINEL, "Invalid owner address provided");
        require(objects[_previous] == _old, "Invalid prevOwner, owner pair provided");
        objects[_new] = objects[_old];
        objects[_previous] = _new;
        objects[_old] = 0;
        emit AddressRemoved(_old);
        emit AddressAdded(_new);
    }

    function contains(address _object)
        public
        view
        returns (bool)
    {
        return objects[_object] != 0;
    }

    /// @dev Returns array of owners.
    /// @return Array of Safe owners.
    function getAll()
        public
        view
        returns (address[])
    {
        address[] memory array = new address[](count);

        // populate return array
        uint256 index = 0;
        address current = objects[SENTINEL];
        while(current != SENTINEL) {
            array[index] = current;
            current = objects[current];
            index ++;
        }
        return array;
    }
}