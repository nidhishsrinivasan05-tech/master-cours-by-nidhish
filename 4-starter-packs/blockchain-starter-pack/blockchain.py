import hashlib
import json
import time

class Block:
    def __init__(self, index, transactions, previous_hash, nonce=0):
        self.index = index
        self.timestamp = time.time()
        self.transactions = transactions
        self.previous_hash = previous_hash
        self.nonce = nonce

    def compute_hash(self):
        block_string = json.dumps(self.__dict__, sort_keys=True)
        return hashlib.sha256(block_string.encode()).hexdigest()

class Blockchain:
    difficulty = 3

    def __init__(self):
        self.chain = []
        self.create_genesis_block()

    def create_genesis_block(self):
        genesis = Block(0, [], "0")
        self.chain.append(genesis)

    @property
    def last_block(self):
        return self.chain[-1]

    def proof_of_work(self, block):
        block.nonce = 0
        computed_hash = block.compute_hash()
        while not computed_hash.startswith("0" * self.difficulty):
            block.nonce += 1
            computed_hash = block.compute_hash()
        return computed_hash

    def add_block(self, transactions):
        block = Block(len(self.chain), transactions, self.last_block.compute_hash())
        proof = self.proof_of_work(block)
        self.chain.append(block)
        return proof

if __name__ == "__main__":
    chain = Blockchain()
    chain.add_block([{"from": "Alice", "to": "Bob", "amount": 10}])
    chain.add_block([{"from": "Bob", "to": "Charlie", "amount": 4}])

    for block in chain.chain:
        print(vars(block))
        print("hash:", block.compute_hash())
        print("-" * 40)
