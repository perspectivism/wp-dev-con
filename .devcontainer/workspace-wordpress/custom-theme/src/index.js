import './index.css';
import confetti from 'canvas-confetti';

document.addEventListener('DOMContentLoaded', () => {
  confetti({
    particleCount: 100,
    spread: 70,
    origin: { y: 0.6 }
  });
});
