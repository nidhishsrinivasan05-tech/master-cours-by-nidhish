const { expect } = require("chai");

describe("ProjectToken", function () {
  it("mints initial supply to owner", async function () {
    const [owner] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("ProjectToken");
    const token = await Token.deploy(owner.address);
    const balance = await token.balanceOf(owner.address);
    expect(balance).to.be.gt(0);
  });
});
