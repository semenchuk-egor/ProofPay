// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../core/ProofToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ProofTokenTest is Test {
    ProofToken public token;
    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    
    function setUp() public {
        vm.startPrank(owner);
        
        ProofToken implementation = new ProofToken();
        bytes memory initData = abi.encodeWithSelector(
            ProofToken.initialize.selector
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        token = ProofToken(address(proxy));
        
        vm.stopPrank();
    }
    
    function testInitialSupply() public {
        assertEq(token.balanceOf(owner), 100_000_000 * 10**18);
    }
    
    function testAddMinter() public {
        vm.prank(owner);
        token.addMinter(user1);
        assertTrue(token.minters(user1));
    }
    
    function testMintByMinter() public {
        vm.startPrank(owner);
        token.addMinter(user1);
        vm.stopPrank();
        
        vm.prank(user1);
        token.mint(user2, 1000 * 10**18);
        
        assertEq(token.balanceOf(user2), 1000 * 10**18);
    }
    
    function testBatchTransfer() public {
        vm.startPrank(owner);
        
        address[] memory recipients = new address[](2);
        recipients[0] = user1;
        recipients[1] = user2;
        
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100 * 10**18;
        amounts[1] = 200 * 10**18;
        
        token.batchTransfer(recipients, amounts);
        
        assertEq(token.balanceOf(user1), 100 * 10**18);
        assertEq(token.balanceOf(user2), 200 * 10**18);
        
        vm.stopPrank();
    }
    
    function testMaxSupply() public {
        vm.startPrank(owner);
        token.addMinter(owner);
        
        uint256 currentSupply = token.totalSupply();
        uint256 maxSupply = token.MAX_SUPPLY();
        uint256 remaining = maxSupply - currentSupply;
        
        token.mint(user1, remaining);
        
        vm.expectRevert("Exceeds max supply");
        token.mint(user1, 1);
        
        vm.stopPrank();
    }
}
