# Synthetix Staking Contract
This repo contains the implementation of Synthetix staking rewards contract in Cairo lang.

## Challenges
The unit & integration test for this contract was done with manipulated block_timestamp because at the time of writing this contract, `get_block_timestamp()` function on Starknet test, returns `0` and most of the functions depended on that.

A confirmation test was done onchain, the contract was deployed on Starknet Sepolia and was tested via https://sepolia.voyager.online. Everything works fine as expected.

See interactions: https://sepolia.voyager.online/contract/0x06c9df27d399ec8c9d417aaee3a591aea21e41d0d4661252007327cd3dee22a5

<b>Staking token contract:</b> 0x227e1a8c4ee85feccab767c584c0b46f5c4062e97a9219a91ec75c86ce0a840 <br>
<b>Reward token contract:</b> 0x702d2721fdcb98fae346bf1398e0702b27c8ccc97e75e632ff93653ece67253 <br>
<b>Staking contract:</b> 0x6c9df27d399ec8c9d417aaee3a591aea21e41d0d4661252007327cd3dee22a5 <br>

## Deployment
`deploy-r-t`: deploys the reward token using: `npm run deploy-r-t` <br>
`deploy-s-t`: deploys the staking token using: `npm run deploy-s-t` <br>
`deploy`: deploys the Staking contract using: `npm run deploy` <br>
