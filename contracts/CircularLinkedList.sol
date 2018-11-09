pragma solidity ^0.4.24;

/// @title CircularLinkedList - Manages a set of objects.
/// @author Andy Chorlian - <andychorlian@gmail.com>
contract CircularLinkedList {

    event Added(address added);
    event Removed(address removed);

    address public tail = 0x0;
    mapping(address => address) internal objects;
    uint256 count;

    /// @dev Setup function sets initial storage of contract.
    /// @param _list List of addresses to start with.
    function initialize(address[] _list)
        internal
    {
        // Initializing.
        address current = _list[0];
        for (uint256 i = 1; i < _list.length; i++) {
            // address cannot be null.
            address next = _list[i];
            require(next != 0 && next != _list[0], "Invalid new address provided");
            // No duplicate addresses allowed.
            require(objects[next] == 0, "Duplicate new address provided");
            objects[current] = next;
            current = next;
        }
        objects[current] = _list[0];
        tail = current;
        count = _list.length;
    }

    /// @dev Allows to add a new address
    /// @param _object New address.
    function add(address _object)
        public
    {
        // address cannot be null.
        require(_object != 0, "Invalid address provided");
        // No duplicate addresses allowed.
        require(objects[_object] == 0, "Address is already added");

        // Insert new address to start of list
        address oldHead = objects[tail];
        objects[tail] = _object;
        objects[_object] = oldHead;

        count++;
        emit Added(_object);
    }

    /// @dev Allows to remove an address.
    /// @param _previous address that pointed to the address to be removed in the linked list
    /// @param _object address to be removed.
    function remove(address _previous, address _object)
        public
    {
        // Validate address and check that it corresponds to index.
        require(_object != 0, "Invalid address provided");
        require(objects[_previous] == _object, "Invalid prevAddress, address pair provided");

        if (_object == tail){
            tail == _previous;
        }

        objects[_previous] = objects[_object];
        objects[_object] = 0;
        count--;
        emit Removed(_object);
    }

    /// @dev Allows to swap/replace an address with another address.
    /// @param _previous address that pointed to the address to be replaced in the linked list
    /// @param _old address to be replaced.
    /// @param _new New address.
    function swap(address _previous, address _old, address _new)
        public
    {
        // address cannot be null.
        require(_new != 0, "Invalid address provided");
        // No duplicates allowed.
        require(objects[_new] == 0, "Address is already added");
        // Validate old address and check that it corresponds to an index.
        require(_old != 0, "Invalid address provided");
        require(objects[_previous] == _old, "Invalid _previous, _old pair provided");

        if (_new == tail){
            tail == _new;
        }

        objects[_new] = objects[_old];
        objects[_previous] = _new;
        objects[_old] = 0;
        emit Removed(_old);
        emit Added(_new);
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
        address current = objects[tail];
        while(current != objects[tail]) {
            array[index] = current;
            current = objects[current];
            index ++;
        }
        return array;
    }
}
