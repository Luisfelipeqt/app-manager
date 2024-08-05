const searchBar = {
    mounted() {
        const searchBarContainer = this.el;
        document.addEventListener('keydown', (event: KeyboardEvent) => {
            if (event.key !== 'ArrowUp' && event.key !== 'ArrowDown') {
                return;
            }

            const focusElement = document.querySelector(':focus');

            if (!focusElement) {
                return;
            }

            if (!searchBarContainer.contains(focusElement as Node)) {
                return;
            }

            event.preventDefault();

            const tabElements = document.querySelectorAll('#search-input, #searchbox__results_list a');
            const focusIndex = Array.from(tabElements).indexOf(focusElement as Element);
            const tabElementsCount = tabElements.length - 1;

            if (event.key === 'ArrowUp') {
                (tabElements[focusIndex > 0 ? focusIndex - 1 : tabElementsCount] as HTMLElement).focus();
            }

            if (event.key === 'ArrowDown') {
                (tabElements[focusIndex < tabElementsCount ? focusIndex + 1 : 0] as HTMLElement).focus();
            }
        });
    },
};
export default searchBar;