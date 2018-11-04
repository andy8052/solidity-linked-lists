pragma solidity ^0.4.24;

/// @title LinkedList - Manages a set of owners and a threshold to perform actions.
/// @author Andy Chorlian - <andychorlian@gmail.com>
contract DoubleLinkedList {

  event Added(address added);
  event Removed(address removed);

  address public constant SENTINEL = 1;

    struct node {
        address previous;
        address next;
    }

    mapping(address => node) internal objects;
    uint256 count;

    /// @dev Setup function sets initial storage of contract.
    /// @param _list List of addresses to start with.
    function initialize(address[] _list)
        internal
    {
        // Initializing.
        address previous = 0;
        address current = SENTINEL;
        for (uint256 i = 0; i < _list.length; i++) {
            // address cannot be null.
            address next = _list[i];
            require(next != 0 && next != SENTINEL, "Invalid new address provided");
            // No duplicate addresses allowed.
            require(
                objects[next].previous == 0 && objects[next].next == 0,
                "Duplicate new address provided"
            );
            objects[current].previous = previous;
            objects[current].next = next;
            previous = current;
            current = next;
        }
        objects[current].previous = previous;
        objects[current].next = 0;
        count = _list.length;
    }

    /// @dev Allows to add a new owner to the Safe and update the threshold at the same time.
    ///      This can only be done via a Safe transaction.
    /// @param _object New owner address.
    function add(address _object)
        public
    {
        // Owner address cannot be null.
        require(_object != 0 && _object != SENTINEL, "Invalid owner address provided");
        // No duplicate owners allowed.
        require(objects[_object].previous == 0 && objects[_object].next == 0, "Address is already added");
        objects[_object].previous = SENTINEL;
        objects[_object].next = objects[SENTINEL].next;
        objects[SENTINEL].next = _object;
        count++;
        emit Added(_object);
    }

    /// @dev Allows to remove an address.
    /// @param _object address to be removed.
    function remove(address _object)
        public
    {
        // Validate address and check that it corresponds to index.
        require(_object != 0 && _object != SENTINEL, "Invalid owner address provided");
        address previous = objects[_object].previous;
        address next = objects[_object].next;
        objects[previous].next = next;
        objects[next].previous = previous;
        objects[_object].previous = 0;
        objects[_object].next = 0;
        count--;
        emit Removed(_object);
    }

    /// @dev Allows to swap/replace an address with another address.
    /// @param _old Owner address to be replaced.
    /// @param _new New owner address.
    function swap(address _old, address _new)
        public
    {
        // Owner address cannot be null.
        require(_new != 0 && _new != SENTINEL, "Invalid new address provided");
        // No duplicate owners allowed.
        require(objects[_new].previous == 0 && objects[_new].next == 0, "Address is already added");
        // Validate oldOwner address and check that it corresponds to owner index.
        require(_old != 0 && _old != SENTINEL, "Invalid old address provided");

        address previous = objects[_old].previous;
        address next = objects[_old].next;

        objects[previous].next = _new;
        objects[next].previous = _new;

        objects[_new].previous = previous;
        objects[_new].next = next;

        objects[_old].previous = 0;
        objects[_old].next = 0;

        emit Removed(_old);
        emit Added(_new);
    }

    function contains(address _object)
        public
        view
        returns (bool)
    {
        return objects[_object].next != 0 || objects[_object].previous != 0;
    }

    /// @dev Returns array of objects.
    /// @return Array of objects.
    function getAll()
        public
        view
        returns (address[])
    {
        address[] memory array = new address[](count);

        // populate return array
        uint256 index = 0;
        address current = objects[SENTINEL].next;
        while(current != 0) {
            array[index] = current;
            current = objects[current].next;
            index ++;
        }
        return array;
    }
}
