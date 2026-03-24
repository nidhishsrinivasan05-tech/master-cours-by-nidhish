import hashlib

def sha256_hash(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()

if __name__ == "__main__":
    data = input("Enter text: ")
    print("SHA-256:", sha256_hash(data))
