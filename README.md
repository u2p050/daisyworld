# DaisyworldNFT

This project is a simulation of the Daisyworld model in an economic context, implemented as an Ethereum smart contract. The contract is written in Solidity and uses the ERC721 standard for non-fungible tokens (NFTs).

In this model, there are two types of daisies: Black and White. Each daisy is represented as an NFT, with its type and the block number at which it was born.

The global temperature of the Daisyworld is influenced by the population of daisies. The contract maintains a count of each type of daisy and adjusts the populations to move towards an optimal temperature. If the temperature is too hot, black daisies are burned, and if it's too cold, white daisies are burned.

The contract also includes an oracle system, where an external oracle can update the simulation state. The oracle address can be updated by the contract owner.

The contract provides functions to mint new daisies, burn existing daisies, and retrieve the current oracle address. It also emits events when daisies are minted or burned.
