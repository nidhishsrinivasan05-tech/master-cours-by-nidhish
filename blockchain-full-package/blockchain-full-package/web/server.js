const http = require("http");

const html = `
<!doctype html>
<html>
  <head><title>Blockchain Dashboard</title></head>
  <body>
    <h1>Blockchain Dashboard</h1>
    <p>Connect wallet and extend this dashboard with ethers.js or viem.</p>
  </body>
</html>
`;

http.createServer((_, res) => {
  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(html);
}).listen(3000, () => console.log("Dashboard running on http://localhost:3000"));
