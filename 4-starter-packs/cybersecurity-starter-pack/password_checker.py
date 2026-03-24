def check_password_strength(password: str) -> str:
    score = 0

    if len(password) >= 8:
        score += 1
    if any(c.islower() for c in password):
        score += 1
    if any(c.isupper() for c in password):
        score += 1
    if any(c.isdigit() for c in password):
        score += 1
    if any(not c.isalnum() for c in password):
        score += 1

    if score <= 2:
        return "Weak"
    if score == 3:
        return "Medium"
    return "Strong"

if __name__ == "__main__":
    sample = input("Enter password to test: ")
    print(check_password_strength(sample))
