const button = document.getElementById("changeBtn");
const message = document.getElementById("message");

button.addEventListener("click", () => {
  message.textContent = "The text changed. Your starter pack is alive.";
});
