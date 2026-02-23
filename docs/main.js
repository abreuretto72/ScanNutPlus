document.addEventListener('DOMContentLoaded', () => {
    const langSelect = document.getElementById('lang-select');

    // Check browser language or local storage
    const savedLang = localStorage.getItem('sn_lang');
    const browserLang = navigator.language.startsWith('es') ? 'es' : (navigator.language.startsWith('en') ? 'en' : 'pt-BR');
    const defaultLang = savedLang || browserLang;

    // Set initial select value
    if (['pt-BR', 'en', 'es'].includes(defaultLang)) {
        langSelect.value = defaultLang;
    }

    // Initial translation
    translatePage(langSelect.value);

    // Change event
    langSelect.addEventListener('change', (e) => {
        const lang = e.target.value;
        localStorage.setItem('sn_lang', lang);
        translatePage(lang);
    });
});

function translatePage(lang) {
    const dictionary = translations[lang];
    if (!dictionary) return;

    document.querySelectorAll('[data-i18n]').forEach(element => {
        const key = element.getAttribute('data-i18n');
        if (dictionary[key]) {
            // Check if it's raw HTML (like the hero title or list items)
            if (element.hasAttribute('data-i18n-html')) {
                element.innerHTML = dictionary[key];
            } else {
                // If it's a glowing icon blob, preserve the icon
                if (element.querySelector('i')) {
                    const iconHTML = element.querySelector('i').outerHTML;
                    element.innerHTML = iconHTML + '\n' + dictionary[key];
                } else {
                    element.textContent = dictionary[key];
                }
            }
        }
    });

    document.documentElement.lang = lang;
}
