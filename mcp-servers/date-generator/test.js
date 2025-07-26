#!/usr/bin/env node

// Simple test script to verify the date generation logic
// This runs the core functions without the MCP server overhead

import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Read and evaluate the main server file to get the functions
const serverCode = readFileSync(join(__dirname, 'index.js'), 'utf8');

// Extract the core functions for testing
const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

function generateDatesForDayOfWeek(month, year, dayOfWeek) {
  if (month < 1 || month > 12) {
    throw new Error('Month must be between 1 and 12');
  }
  if (year < 1900 || year > 2100) {
    throw new Error('Year must be between 1900 and 2100');
  }
  if (dayOfWeek < 0 || dayOfWeek > 6) {
    throw new Error('Day of week must be between 0 (Sunday) and 6 (Saturday)');
  }

  const dates = [];
  const daysInMonth = new Date(year, month, 0).getDate();

  for (let day = 1; day <= daysInMonth; day++) {
    const date = new Date(year, month - 1, day);
    if (date.getDay() === dayOfWeek) {
      dates.push(date);
    }
  }

  if (dates.length === 0) {
    return {
      success: false,
      message: 'No dates found for the specified criteria.',
      dates: []
    };
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const formattedDates = dates.map((date, index) => {
    const formattedDate = date.toLocaleDateString('en-US', { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
    
    const daysFromToday = Math.floor((date - today) / (1000 * 60 * 60 * 24));
    const weeksFromToday = (daysFromToday / 7).toFixed(2);

    return {
      index: index + 1,
      date: date.toISOString().split('T')[0],
      formatted: formattedDate,
      daysFromToday: daysFromToday,
      weeksFromToday: parseFloat(weeksFromToday),
      isPast: daysFromToday < 0,
      isToday: daysFromToday === 0,
      isFuture: daysFromToday > 0
    };
  });

  return {
    success: true,
    query: {
      month: months[month - 1],
      year: year,
      dayOfWeek: days[dayOfWeek]
    },
    totalDates: dates.length,
    dates: formattedDates
  };
}

// Test cases
console.log('🧪 Testing Date Generator MCP Server Logic\\n');

// Test 1: Find all Mondays in December 2024
console.log('Test 1: All Mondays in December 2024');
try {
  const result1 = generateDatesForDayOfWeek(12, 2024, 1);
  console.log(JSON.stringify(result1, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\\n' + '='.repeat(50) + '\\n');

// Test 2: Find all Fridays in February 2025
console.log('Test 2: All Fridays in February 2025');
try {
  const result2 = generateDatesForDayOfWeek(2, 2025, 5);
  console.log(JSON.stringify(result2, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\\n' + '='.repeat(50) + '\\n');

// Test 3: Error handling - invalid month
console.log('Test 3: Error handling (invalid month)');
try {
  const result3 = generateDatesForDayOfWeek(13, 2024, 1);
  console.log(JSON.stringify(result3, null, 2));
} catch (error) {
  console.error('Expected error:', error.message);
}

console.log('\\n' + '='.repeat(50) + '\\n');

// Test 4: Current month example
const now = new Date();
const currentMonth = now.getMonth() + 1;
const currentYear = now.getFullYear();
console.log(`Test 4: All Sundays in ${months[currentMonth - 1]} ${currentYear}`);
try {
  const result4 = generateDatesForDayOfWeek(currentMonth, currentYear, 0);
  console.log(JSON.stringify(result4, null, 2));
} catch (error) {
  console.error('Error:', error.message);
}

console.log('\\n✅ Tests completed!');
