# Russian Roulette Dapp

### Step-by-step to create hardhat project
1. Create a git project
2. Install npm and nodejs
3. Inside a project folder, execute `npm init` and `npm i hardhat`
4. With hardhat installed, execute `npx hardhat init` to start a hardhat project, choise the options as bellow:
```shell
✔ What do you want to do? · Create a TypeScript project
✔ Hardhat project root: · ${the root project path already come selected}
✔ Do you want to add a .gitignore? (Y/n) · y
✔ Do you want to install this sample project's dependencies with npm (@nomicfoundation/hardhat-toolbox)? (Y/n) · y
```
5. Install OpenZeppelin Contracts libraries `npm i @openzeppelin/contracts`
6. Running tests `npm run test` (configured on package.json scripts)
7. Running deploy `npm run deploy` (configured on package.json scripts)
8. Running verify `npm run verify -- ${DEPLOYED CONTRACT ADDRESS}` (configured on package.json scripts)