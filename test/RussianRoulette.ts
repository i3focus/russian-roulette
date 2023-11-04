import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

const MIN_BET_FEE = ethers.parseEther("0.01"); //0.01 ETH
const MAX_PLAYERS = 6;

describe("RussianRoulette", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    // retrieve accounts (wallets) from ethers
    const accounts = await ethers.getSigners();
    const owner = accounts[10];

    const RussianRouletteFactory = await ethers.getContractFactory("RussianRoulette");
    const RussianRoulette = await RussianRouletteFactory.connect(owner).deploy();

    console.table(RussianRoulette);

    return { RussianRoulette, accounts, owner };
  }

  describe("Lets to play Russian Roulette", function () {
    it("Should set run russion roulette game perfectly", async function () {
      const { RussianRoulette, accounts, owner } = await loadFixture(deployOneYearLockFixture);

      const balanceBefore: { [key: string]: string; } = {};
      const balanceAfter: { [key: string]: string; } = {};
      const provider = ethers.provider;

      console.log("Owner balance after");
      const ownerBalanceBefore = ethers.formatUnits(
        await provider.getBalance(owner.address),
        "ether"
      );
      console.table({ address: owner.address, balance: ownerBalanceBefore });

      for (let player = 1; player <= MAX_PLAYERS; player++) {
        const account = accounts[player - 1];

        balanceBefore[account.address] = ethers.formatUnits(
          await provider.getBalance(account.address),
          "ether"
        );

        if (player == MAX_PLAYERS) {
          await expect(
            RussianRoulette.connect(account).enter({ value: MIN_BET_FEE })
          )
            .to.emit(RussianRoulette, "PlayerJoined")
            .to.emit(RussianRoulette, "VictimPlayer");
        } else {
          await expect(
            RussianRoulette.connect(account).enter({ value: MIN_BET_FEE })
          ).to.emit(RussianRoulette, "PlayerJoined");
        }
      }

      for (let player = 1; player <= MAX_PLAYERS; player++) {
        const account = accounts[player - 1];

        balanceAfter[account.address] = ethers.formatUnits(
          await provider.getBalance(account.address),
          "ether"
        );
      }

      console.log("Balance Before");
      console.table(balanceBefore);
      console.log("Balance After");
      console.table(balanceAfter);

      console.log("Owner balance after");
      const ownerBalanceAfter = ethers.formatUnits(
        await provider.getBalance(owner.address),
        "ether"
      );
      console.table({ address: owner.address, balance: ownerBalanceAfter });
    });

    it("Should send fee less than the allowed min bet fee, then should be trown exception", async function () {
      const { RussianRoulette, accounts, owner } = await loadFixture(deployOneYearLockFixture);

      const notAllowedFee = ethers.parseEther("0.001"); //0.001 ETH

      for (let player = 1; player <= MAX_PLAYERS; player++) {
        const account = accounts[player - 1];

        await expect(
          RussianRoulette.connect(account).enter({ value: notAllowedFee })
        ).to.be.rejectedWith("RussianRoulette: bet must be greater than or equal to 10000000000000000 ether");
      }
    });
  });
});
