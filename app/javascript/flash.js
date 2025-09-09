document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.flash-modal').forEach(modal => {
        setTimeout(() => {
            modal.classList.add('opacity-0');
            setTimeout(() => modal.remove(), 500);
        }, 5000);
    });
});
document.addEventListener('turbo:load', () => {
    document.querySelectorAll('.flash-modal').forEach(modal => {
        setTimeout(() => {
            modal.classList.add('opacity-0');
            setTimeout(() => modal.remove(), 500);
        }, 5000);
    });
});