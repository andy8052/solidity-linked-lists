pragma solidity ^0.4.24;

/// @title LinkedList - Manages a set of objects.
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

    /// @dev Allows to add a new object
    /// @param _object New address
    function add(address _object)
        public
    {
        require(_object != 0 && _object != SENTINEL, "Invalid address provided");
        require(objects[_object] == 0, "Address is already added");

        objects[_object] = objects[SENTINEL];
        objects[SENTINEL] = _object;
        addressCount++;
        emit AddressAdded(_object);
    }

    /// @dev Allows to remove an address.
    /// @param _prevAddress address that pointed to the address to be removed in the linked list
    /// @param _address address to be removed.
    function remove(address _previous, address _object)
        public
    {
        // Validate address and check that it corresponds to index.
        require(_object != 0 && _object != SENTINEL, "Invalid address provided");
        require(objects[_previous] == _object, "Invalid _previous, _object pair provided");

        objects[_previous] = objects[_object];
        objects[_object] = 0;
        addressCount--;
        emit AddressRemoved(_object);
    }

    /// @dev Allows to swap/replace an address with another address.
    /// @param _previous object that pointed to the object to be replaced in the linked list
    /// @param _old object to be replaced.
    /// @param _new New object
    function swap(address _previous, address _old, address _new)
        public
    {
        require(_new != 0 && _new != SENTINEL, "Invalid _new address provided");
        require(objects[_new] == 0, "Address is already added");
        require(_old != 0 && _old != SENTINEL, "Invalid _old address provided");
        require(objects[_previous] == _old, "Invalid _previous, _old pair provided");

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

    /// @dev Returns array of objects.
    /// @return Array of addresses.
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
