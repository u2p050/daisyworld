// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing required library
import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

// DaisyworldNFT contract simulates the daisyworld model in an economic context
contract DaisyworldNFT is ERC721{
    // Enum to represent Daisy types
    enum DaisyType { Black, White }

    // Struct to represent a Daisy
    struct Daisy {
        DaisyType daisyType;
        uint256 birthBlock;
    }

    // State variables
    uint256 public globalTemperature;
    uint256 public totalBlackDaisies;
    uint256 public totalWhiteDaisies;
    uint256 public endDayNumberWhiteDaisies; 
    uint256 public endDayNumberBlackDaisies; 
    address private oracleAddress;
    address owner; 
    uint8 OPTIMAL_TEMPERATURE; 
    uint256 totalSupplyOfDaisies; 
    mapping(uint256 => Daisy) public daisies;
    uint256[] public blackDaisyIds;
    uint256[] public whiteDaisyIds;

    // Events
    event DaisyMinted(uint256 indexed tokenId, DaisyType daisyType);
    event DaisyBurned(uint256 indexed tokenId);

    // Constructor to initialize the contract
    constructor(address _oracle, uint8 _optimal_temperature) ERC721("Daisyworld", "DAISY") {
        oracleAddress = _oracle;
        owner = msg.sender; 
        // Setting up optimal temperature at the beginning of the simulation, tempature should be 100 because no  floating point. 
        OPTIMAL_TEMPERATURE = _optimal_temperature; 
    }

    // Modifier to restrict function access to contract owner
    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner"); 
        _; 
    }

    // Function to update the oracle address, only callable by the contract owner
    function setOracleAddress(address _newOracle) external onlyOwner {
        oracleAddress = _newOracle;
    }

    // Function to retrieve the current oracle address
    function getOracleAddress() external view returns (address) {
        return oracleAddress;
    }

    // Function to update the contract owner
    function updateOwner(address _newOwner) public onlyOwner {
        owner = _newOwner; 
    }

    // Function to update the simulation state, only callable by the oracle
    function updateSimulation() external {
        require(msg.sender == oracleAddress, "Caller is not the oracle");
        // Calculate temperature variation based on daisy population changes
        uint256 variationBlackDaisy = totalBlackDaisies - endDayNumberBlackDaisies; 
        uint256 variationWhiteDaisy = totalWhiteDaisies - endDayNumberWhiteDaisies; 
        uint256 CoefTemp = (variationBlackDaisy-variationWhiteDaisy); 
        globalTemperature += globalTemperature*CoefTemp; 
        
        // Adjust daisy populations to move towards optimal temperature
        if (globalTemperature > OPTIMAL_TEMPERATURE) {
            // If too hot, decrease black daisies
                burnRandomDaisy(DaisyType.Black);
        } else if (globalTemperature < OPTIMAL_TEMPERATURE) {
            // If too cold, decrease white daisies 
                burnRandomDaisy(DaisyType.White);
        }

        // Store the current daisy populations for future calculations
        endDayNumberBlackDaisies = totalBlackDaisies; 
        endDayNumberWhiteDaisies = totalWhiteDaisies; 
    }

    function totalSupply() private  view returns (uint256) {
        return totalSupplyOfDaisies; 
    }

    // Function to mint new daisies
    function mintDaisy(DaisyType _type) public {
        uint256 newTokenId = totalSupply() + 1;
        totalSupplyOfDaisies++; 
        _mint(msg.sender, newTokenId);

        // Create a new Daisy
        daisies[newTokenId] = Daisy({
            daisyType: _type,
            birthBlock: block.number
        });

        // Update the total count of each daisy type
        if (_type == DaisyType.Black) {
            totalBlackDaisies++;
            blackDaisyIds.push(newTokenId);
        } else {
            totalWhiteDaisies++;
            whiteDaisyIds.push(newTokenId);
        }

        // Emit an event for the minted daisy
        emit DaisyMinted(newTokenId, _type);
    }

    // Function to burn daisies
    function _removeAtIndex(uint256 index, uint256[] storage array) private {
        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        array.pop();
    }

    function burnRandomDaisy(DaisyType daisyType) private {
        uint256[] storage daisyIds = (daisyType == DaisyType.Black) ? blackDaisyIds : whiteDaisyIds;
        uint256 daisyCount = daisyIds.length;
        if (daisyCount == 0) {
            return; // No daisies of this type to burn
        }

        // Generate a random index
        uint256 randomIndex = _generateRandomIndex(daisyCount);
        // Find the token ID of the daisy to burn
        uint256 tokenId = daisyIds[randomIndex];

        // Burn the daisy if it exists
        if (tokenId != 0) {
            _burn(tokenId);
            emit DaisyBurned(tokenId);
            // Remove the burned daisy from the array
            _removeAtIndex(randomIndex, daisyIds);
        }
    }

    // Function to generate a random index
    function _generateRandomIndex(uint256 daisyCount) private view returns (uint256) {
        uint256 randomHash = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, daisyCount)));
        return randomHash % daisyCount;
    }
}
