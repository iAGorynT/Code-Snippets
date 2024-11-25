        // script.js

        // DOM element selections
        const modeToggle = document.getElementById('modeToggle');
        const monthSelect = document.getElementById('month');
        const dayOfWeekSelect = document.getElementById('dayOfWeek');
        const yearInput = document.getElementById('year');
        const generateButton = document.getElementById('generateButton');
        const output = document.getElementById('output');
        
        // Arrays for populating select elements
        const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        
        /**
         * Populates a select element with options
         * @param {HTMLSelectElement} select - The select element to populate
         * @param {string[]} options - Array of option texts
         */
        const populateSelect = (select, options) => {
            select.innerHTML = options.map((option, index) => 
                `<option value="${index}">${option}</option>`
            ).join('');
        };
        
        // Populate month and day of week selects
        populateSelect(monthSelect, months);
        populateSelect(dayOfWeekSelect, days);
        
        /**
         * Toggles between light and dark mode
         */
        const toggleMode = () => {
            document.body.classList.toggle('dark-mode');
        };
        
        /**
         * Checks system preference for dark mode and sets initial state
         */
        const checkSystemMode = () => {
            const prefersDarkScheme = window.matchMedia("(prefers-color-scheme: dark)").matches;
            document.body.classList.toggle('dark-mode', prefersDarkScheme);
            modeToggle.checked = prefersDarkScheme;
        };
        
        /**
         * Generates dates based on user input and displays them
         */
        const generateDates = () => {
            const month = parseInt(monthSelect.value) + 1;
            const year = parseInt(yearInput.value);
            const dayOfWeek = parseInt(dayOfWeekSelect.value);
        
            // Input validation
            if (isNaN(month) || isNaN(year)) {
                alert('Please enter a valid month and year.');
                return;
            }
        
            const dates = [];
            const daysInMonth = new Date(year, month, 0).getDate();
        
            // Find all dates in the month that match the selected day of week
            for (let day = 1; day <= daysInMonth; day++) {
                const date = new Date(year, month - 1, day);
                if (date.getDay() === dayOfWeek) {
                    dates.push(date);
                }
            }
        
            if (dates.length === 0) {
                output.innerHTML = '<p>No dates found for the specified criteria.</p>';
                return;
            }
        
            const today = new Date();
            today.setHours(0, 0, 0, 0);
        
            // Display each found date using template literals and more compact logic
            output.innerHTML = dates.map((date, index) => {
                const formattedDate = date.toLocaleDateString('en-US', { 
                    weekday: 'long', 
                    year: 'numeric', 
                    month: 'long', 
                    day: 'numeric' 
                });
                
                const daysFromToday = Math.floor((date - today) / (1000 * 60 * 60 * 24));
                const weeksFromToday = (daysFromToday / 7).toFixed(2);
        
                return `<p>${index + 1}. ${formattedDate}${
                    daysFromToday > 0 
                        ? ` <span style="color: var(--accent-color);">(${daysFromToday} days / ${weeksFromToday} weeks from today)</span>`
                        : ''
                }</p>`;
            }).join('');
        };
        
        // Event listeners
        modeToggle.addEventListener('change', toggleMode);
        generateButton.addEventListener('click', generateDates);
        window.addEventListener('load', checkSystemMode);

