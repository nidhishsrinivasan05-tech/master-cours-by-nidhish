import socket

def is_port_open(port: int, host: str = "127.0.0.1") -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.settimeout(0.5)
        return sock.connect_ex((host, port)) == 0

if __name__ == "__main__":
    for port in [22, 80, 443, 8000]:
        print(f"Port {port}: {'open' if is_port_open(port) else 'closed'}")
