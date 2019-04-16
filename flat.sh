if [ ! -d ./dist ]; then
  # Control will enter here if directory doesn't exists.
  echo "Creating dist directory..."
  mkdir dist
fi

truffle-flattener ./contracts/backend/ZtickyStake.sol > ./dist/ZtickyStake.sol
truffle-flattener ./contracts/backend/ZtickyCoinZ.sol > ./dist/ZtickyCoinZ.sol
truffle-flattener ./contracts/backend/ZtickyBank.sol > ./dist/ZtickyBank.sol
truffle-flattener ./contracts/ZtickerZ.sol > ./dist/ZtickerZ.sol
