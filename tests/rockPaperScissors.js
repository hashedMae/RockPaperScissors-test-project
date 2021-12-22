const { expect } = require("chai");
const { experimentalAddHardhatNetworkMessageTraceHook } = require("hardhat/config");

describe("rockPaperScissors Contract", function () {

    let rockPaperScissors;
    let rpsGame;
    let rpsToken;
    let gameToken;
    let addr1;
    let addr2;
    let addr3;
    let addrs

    beforeEach(async function () {
        rockPaperScissors = await ethers.getContractFactory("rockPaperScissors");
        rpsToken = await ethers.getContractFactory("rpsToken")
        [addr1, addr2, addr3, ...addrs] await ethers.getSigners();

        rpsGame = await rockPaperScissors.deploy();
        gameToken = wait rpsToken.deploy();
    });

    describe("Deployment", function () {
        it("should assign all tokens to addr1", async function () {
            const addr1Balance = await gameToken.balanceOf(addr1.address);
            expect(await gameToken.totalSupply()).to.equal(addr1balance);
        });
    });

    describe("Transfer", function () {
        it("should transfer tokens between accounts"), async function ()
        const gameToken.transfer(addr2.address, 200);
        const addr2Balance = await gameToken.balanceOf(addr2.address);
        expect(addr2Balance).to.equal(200);

        await gameToken.connect(addr2).transfer(addr3.address, 99);
        const addr3Balance = await gameToken.balanceOf(addr3.address);
        expect(addr3Balance).to.equal(99);
    });


});