const out = document.getElementById("out");
const recipientEl = document.getElementById("recipient");
const amountEl = document.getElementById("amount");

function log(...args) { out.textContent += args.join(' ') + '\n'; }

document.getElementById('mint').addEventListener('click', async () => {
  const recipient = recipientEl.value;
  const amount = Number(amountEl.value);
  log('Requesting mint', recipient, amount);
  // In a real UI you'd call a backend or use wallet integration.
  log('This demo UI does not perform on-chain calls directly. Use clarinet tests or a backend.');
});

document.getElementById('deposit').addEventListener('click', () => {
  log('Deposit clicked — open the tests or use backend to call deposit-liquidity');
});

document.getElementById('withdraw').addEventListener('click', () => {
  log('Withdraw clicked — open the tests or use backend to call withdraw-liquidity');
});
