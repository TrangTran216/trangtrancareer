document.querySelectorAll('[data-current-year]').forEach((element) => {
  element.textContent = new Date().getFullYear();
});

document.querySelectorAll('a[target="_blank"]').forEach((link) => {
  const current = link.getAttribute('aria-label');
  if (!current) link.setAttribute('aria-label', `${link.textContent.trim()} (opens in a new tab)`);
});
