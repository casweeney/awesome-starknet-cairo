import { Account, CallData, Contract, RpcProvider, stark } from "starknet";
import * as dotenv from "dotenv";
import { getCompiledCode } from "./utils";
dotenv.config();

async function main() {
    const provider = new RpcProvider({
        nodeUrl: process.env.RPC_ENDPOINT,
    });

  // initialize existing predeployed account 0
    console.log("ACCOUNT_ADDRESS=", process.env.DEPLOYER_ADDRESS);
    console.log("ACCOUNT_PRIVATE_KEY=", process.env.DEPLOYER_PRIVATE_KEY);
    const privateKey0 = process.env.DEPLOYER_PRIVATE_KEY ?? "";
    const accountAddress0: string = process.env.DEPLOYER_ADDRESS ?? "";
    const account0 = new Account(provider, accountAddress0, privateKey0);
    console.log("Account connected.\n");

    // Declare & deploy contract
    let sierraCode, casmCode;

    try {
        ({ sierraCode, casmCode } = await getCompiledCode(
        "synthetix_staking_StakingRewards"
        ));
    } catch (error: any) {
        console.log("Failed to read contract files");
        console.log(error);
        process.exit(1);
    }

    const myCallData = new CallData(sierraCode.abi);
    
    const constructor = myCallData.compile("constructor", {
        owner: process.env.DEPLOYER_ADDRESS ?? "",
        staking_token: "0x227e1a8c4ee85feccab767c584c0b46f5c4062e97a9219a91ec75c86ce0a840",
        reward_token: "0x702d2721fdcb98fae346bf1398e0702b27c8ccc97e75e632ff93653ece67253"
    });

    const deployResponse = await account0.declareAndDeploy({
        contract: sierraCode,
        casm: casmCode,
        constructorCalldata: constructor,
        salt: stark.randomAddress(),
    });

    // Connect the new contract instance :
    const myTestContract = new Contract(
        sierraCode.abi,
        deployResponse.deploy.contract_address,
        provider
    );
    console.log(
        `✅ Contract has been deploy with the address: ${myTestContract.address}`
    );
}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
