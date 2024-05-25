// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { LinkToken } from "../test/mocks/LinkToken.sol";
import { VRFCoordinatorV2Mock } from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        uint64 subscriptionId;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        address vrfCoordinatorV2;
        address link;
        uint256 deployerPrivateKey;
        address deployerAddress;
    }

    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6;
    address public DEFAULT_ANVIL_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    event HelperConfig__CreatedMockVRFCoordinator(address vrfCoordinator);

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaConfig() public view returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            subscriptionId: 0,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            callbackGasLimit: 500000,
            vrfCoordinatorV2: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            deployerPrivateKey: vm.envUint("PRIVATE_KEY"),
            deployerAddress: 0x115F6cdf65789EF751D0EB1Bfb40533Ae510f598
        });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
        // Check if has active network
        if (activeNetworkConfig.vrfCoordinatorV2 != address(0)) {
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;

        vm.startBroadcast(DEFAULT_ANVIL_PRIVATE_KEY);
        VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(baseFee, gasPriceLink);
        LinkToken link = new LinkToken();
        vm.stopBroadcast();

        emit HelperConfig__CreatedMockVRFCoordinator(address(vrfCoordinatorV2Mock));

        anvilNetworkConfig = NetworkConfig({
            subscriptionId: 0,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            callbackGasLimit: 500000,
            vrfCoordinatorV2: address(vrfCoordinatorV2Mock),
            link: address(link),
            deployerPrivateKey: DEFAULT_ANVIL_PRIVATE_KEY,
            deployerAddress: DEFAULT_ANVIL_ADDRESS
        });
    }
}